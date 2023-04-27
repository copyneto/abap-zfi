@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Carga de Contratos Header'
define root view entity ZI_FI_CARGA_CONTRATOH 
as select from ztfi_carga_conth
//association [0..1] to ZI_FI_TIPO_CARGA as _Carga on $projection.TipoCarga = _Carga.TipoCargaId
//composition of target_data_source_name as _association_name 
{
key doc_uuid_h as DocUuidH,
documentno as Documentno,
data_carga as DataCarga,
tipo_carga as TipoCarga,
//_Carga.TipoCargaText as TipoCargaText,
created_by as CreatedBy,
created_at as CreatedAt,
last_changed_by as LastChangedBy,
last_changed_at as LastChangedAt,
local_last_changed_at as LocalLastChangedAt

//_Carga
}
