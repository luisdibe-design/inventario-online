import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const headers = {"Content-Type":"application/json","Cache-Control":"no-store","Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type","Access-Control-Allow-Methods":"POST, OPTIONS"};
const respond=(body:unknown,status=200)=>new Response(JSON.stringify(body),{status,headers});
const norm=(v:unknown)=>String(v??"").trim().toUpperCase();
const low=(v:unknown)=>String(v??"").trim().toLowerCase();
const SKU="CRCNGSILC", ITEM_ID="MLM1345474530", CONFIRM="UPDATE_VARIANT_CRCNGSILC_MLM1345474530";

function variationSku(v:any):string[] {
  const values:string[]=[];
  for (const x of [v?.seller_custom_field,v?.seller_sku,v?.sku]) if (x) values.push(String(x));
  for (const a of (Array.isArray(v?.attributes)?v.attributes:[])) {
    const id=norm(a?.id), name=norm(a?.name);
    if (["SELLER_SKU","SKU","SELLER_CUSTOM_FIELD"].includes(id) || ["SELLER SKU","SKU"].includes(name)) {
      if (a?.value_name) values.push(String(a.value_name));
      if (a?.value_id) values.push(String(a.value_id));
    }
  }
  return [...new Set(values.map(norm).filter(Boolean))];
}

Deno.serve(async(req:Request)=>{
  if(req.method==="OPTIONS") return new Response("ok",{status:200,headers});
  if(req.method!=="POST") return respond({error:"method_not_allowed"},405);
  try {
    const bearer=(req.headers.get("Authorization")||"").replace(/^Bearer\s+/i,"").trim();
    if(!bearer) return respond({error:"unauthorized"},401);
    const bbUrl=Deno.env.get("SUPABASE_URL"); let bbKey=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    try { const keys=Deno.env.get("SUPABASE_SECRET_KEYS"); if(keys) bbKey=JSON.parse(keys).default||bbKey; } catch {}
    const odklUrl=Deno.env.get("ODKL_SUPABASE_URL"), odklKey=Deno.env.get("ODKL_SERVICE_ROLE_KEY");
    if(!bbUrl||!bbKey||!odklUrl||!odklKey) return respond({error:"server_configuration_error"},500);
    const admin=createClient(bbUrl,bbKey), odkl=createClient(odklUrl,odklKey);
    const parts=bearer.split("."); if(parts.length!==3) return respond({error:"invalid_session"},401);
    let userId=""; try {const p=JSON.parse(atob(parts[1].replace(/-/g,"+").replace(/_/g,"/").padEnd(Math.ceil(parts[1].length/4)*4,"=")));userId=String(p.sub||"");}catch{return respond({error:"invalid_session"},401)}
    if(!userId) return respond({error:"invalid_session"},401);
    const {data:profile,error:pe}=await admin.from("profiles").select("role,active").eq("id",userId).maybeSingle();
    if(pe) return respond({error:"profile_lookup_failed",detail:pe.message},500);
    if(profile?.role!=="admin"||profile?.active===false) return respond({error:"admin_only"},403);
    const body=await req.json().catch(()=>({}));
    const mode=low(body?.mode||"preview");
    if(!["preview","apply_single"].includes(mode)) return respond({error:"mode_not_allowed"},400);
    if(norm(body?.sku||SKU)!==SKU || String(body?.ml_item_id||ITEM_ID)!==ITEM_ID) return respond({error:"target_not_authorized"},403);
    if(mode==="apply_single" && String(body?.confirm||"")!==CONFIRM) return respond({error:"explicit_confirmation_required"},403);

    const {data:connection,error:ce}=await admin.from("mercadolibre_connections").select("seller_id,access_token,refresh_token,expires_at").eq("base_key","bikebeat").eq("seller_id","155121724").order("connected_at",{ascending:false}).limit(1).maybeSingle();
    if(ce||!connection?.access_token) return respond({error:"mercadolibre_connection_missing"},409);
    if(connection.expires_at&&new Date(connection.expires_at).getTime()<=Date.now()+120000){
      const clientId=Deno.env.get("ML_CLIENT_ID"),clientSecret=Deno.env.get("ML_CLIENT_SECRET");
      if(!connection.refresh_token||!clientId||!clientSecret) return respond({error:"mercadolibre_token_expired"},409);
      const rr=await fetch("https://api.mercadolibre.com/oauth/token",{method:"POST",headers:{"Content-Type":"application/x-www-form-urlencoded",Accept:"application/json"},body:new URLSearchParams({grant_type:"refresh_token",client_id:clientId,client_secret:clientSecret,refresh_token:connection.refresh_token})});
      const rd=await rr.json().catch(()=>({})); if(!rr.ok||!rd.access_token) return respond({error:"token_refresh_failed",http_status:rr.status},409);
      const expiresAt=new Date(Date.now()+Number(rd.expires_in||0)*1000).toISOString();
      const {error}=await admin.from("mercadolibre_connections").update({access_token:rd.access_token,refresh_token:rd.refresh_token||connection.refresh_token,expires_at:expiresAt,updated_at:new Date().toISOString()}).eq("base_key","bikebeat").eq("seller_id",String(connection.seller_id));
      if(error) return respond({error:"token_store_failed",detail:error.message},500);
      connection.access_token=rd.access_token;
    }

    const [{data:bb,error:be},{data:od,error:oe}]=await Promise.all([
      admin.from("products").select("id,sku,name,stock,active").eq("active",true).ilike("sku",SKU),
      odkl.from("products").select("id,sku,name,stock,active").eq("active",true).ilike("sku",SKU)
    ]);
    if(be||oe) return respond({error:"inventory_read_failed",bikebeat:be?.message||null,odkl:oe?.message||null},500);
    const bbStock=(bb||[]).reduce((s:any,p:any)=>s+Number(p.stock||0),0),odklStock=(od||[]).reduce((s:any,p:any)=>s+Number(p.stock||0),0);
    const target=Math.max(0,Math.floor(bbStock+odklStock)-1);
    const mlHeaders={Authorization:`Bearer ${connection.access_token}`,Accept:"application/json"};
    const get=await fetch(`https://api.mercadolibre.com/items/${ITEM_ID}`,{headers:mlHeaders});
    const item=await get.json().catch(()=>({}));
    if(!get.ok) return respond({error:"item_fetch_failed",http_status:get.status,detail:item?.message||item?.error||null},502);
    const logistic=low(item?.shipping?.logistic_type||item?.logistic_type||item?.shipping_option?.logistic_type);
    if(!["xd_drop_off","drop_off"].includes(logistic)) return respond({error:"dropoff_not_confirmed",logistics:logistic||"unknown",queue_events_left_pending:true},409);
    const vars=Array.isArray(item?.variations)?item.variations:[];
    const matches=vars.filter((v:any)=>variationSku(v).includes(SKU));
    if(matches.length!==1) return respond({error:matches.length?"variant_sku_ambiguous":"variant_sku_not_found",sku:SKU,item_id:ITEM_ID,match_count:matches.length,variations:vars.map((v:any)=>({id:v?.id,skus:variationSku(v),available_quantity:v?.available_quantity,attribute_combinations:v?.attribute_combinations})),message:"No se modificó Mercado Libre. Se requiere una coincidencia única del SKU en las variantes."},409);
    const variant=matches[0],variantId=Number(variant.id),current=Number(variant.available_quantity);
    if(!Number.isFinite(variantId)||!Number.isFinite(current)) return respond({error:"variant_data_invalid"},409);
    const queueResp=await fetch(bbUrl+"/functions/v1/inventory-sync-event-preview",{method:"POST",headers:{Authorization:`Bearer ${bearer}`,apikey:req.headers.get("apikey")||bbKey,"Content-Type":"application/json"},body:JSON.stringify({sku:SKU,limit:100})});
    const queue=await queueResp.json().catch(()=>({}));
    if(!queueResp.ok) return respond({error:"queue_preview_failed",http_status:queueResp.status,detail:queue?.error||queue?.message||null},502);
    const qr=(queue?.previews||[]).find((x:any)=>norm(x.sku)===SKU)||null;
    const common={sku:SKU,item_id:ITEM_ID,variant_id:variantId,variant_skus:variationSku(variant),logistics:logistic,listing_status:item.status,listing_sub_status:item.sub_status??null,bb_stock:bbStock,odkl_stock:odklStock,combined_stock:bbStock+odklStock,reserve:1,target_quantity:target,current_variant_quantity:current,event_count:qr?.event_count??0,event_ids_by_database:qr?.event_ids_by_database??{BIKEBEAT:[],ODKL:[]}};
    if(mode==="preview") return respond({ok:true,mode,...common,action:current===target?"already_in_sync":"would_update",message:"Vista previa de variante; no se modificó Mercado Libre ni inventario interno."});
    let verified=item;
    if(current!==target){
      const put=await fetch(`https://api.mercadolibre.com/items/${ITEM_ID}`,{method:"PUT",headers:{...mlHeaders,"Content-Type":"application/json"},body:JSON.stringify({variations:[{id:variantId,available_quantity:target}]})});
      const pd=await put.json().catch(()=>({}));
      if(!put.ok) return respond({error:"variant_update_failed",http_status:put.status,detail:pd?.message||pd?.error||null,queue_events_left_pending:true},502);
      const check=await fetch(`https://api.mercadolibre.com/items/${ITEM_ID}`,{headers:mlHeaders});
      verified=await check.json().catch(()=>({}));
      if(!check.ok) return respond({error:"variant_verify_fetch_failed",http_status:check.status,queue_events_left_pending:true},502);
    }
    const verifiedVariant=(Array.isArray(verified?.variations)?verified.variations:[]).find((v:any)=>Number(v.id)===variantId);
    if(!verifiedVariant||Number(verifiedVariant.available_quantity)!==target||low(verified.status)!==low(item.status)) return respond({error:"variant_post_update_verification_failed",verified_quantity:verifiedVariant?.available_quantity??null,expected_quantity:target,original_status:item.status,verified_status:verified?.status??null,queue_events_left_pending:true},502);
    const ids=qr?.event_ids_by_database||{},acks:any={BIKEBEAT:0,ODKL:0};
    const bbIds=Array.isArray(ids.BIKEBEAT)?ids.BIKEBEAT:[],odIds=Array.isArray(ids.ODKL)?ids.ODKL:[];
    if(bbIds.length){const {data,error}=await admin.rpc("complete_inventory_sync_outbox_events",{p_ids:bbIds});if(error)return respond({error:"bikebeat_ack_failed",detail:error.message,marketplace_updated:true,queue_events_left_pending:true},500);acks.BIKEBEAT=Number(data||0)}
    if(odIds.length){const {data,error}=await odkl.rpc("complete_inventory_sync_outbox_events",{p_ids:odIds});if(error)return respond({error:"odkl_ack_failed",detail:error.message,acknowledgements:acks,marketplace_updated:true,queue_events_left_pending:true},500);acks.ODKL=Number(data||0)}
    return respond({ok:true,mode,...common,result:current===target?"already_in_sync":"updated",verified_variant_quantity:Number(verifiedVariant.available_quantity),verified_listing_status:verified.status,acknowledgements:acks,events_completed:acks.BIKEBEAT+acks.ODKL,internal_inventory_modified:false,marketplace_updates_performed:current!==target,message:current===target?"La variante ya tenía la cantidad correcta; no se envió PUT.":"Se actualizó únicamente la variante Negro. La publicación conservó su estado."});
  } catch(e) { return respond({error:"internal_error",detail:String(e).slice(0,260)},500); }
});
