@AbapCatalog.sqlViewName: 'ZVFI_PROVCOPAX'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Busca dados para provisão CO-PA'
define view ZI_FI_GET_PROV_DATA_AUX
  as select from ZI_FI_GET_PROV_DATA as _Base
    inner join   t2500               as _Fam on _Base.wwmt1_aux = _Fam.wwmt1
{
  bukrs,
  belnr,
  gjahr,
  buzei,
  kndnr,
  werks,
  vtweg,
  bzirk,
  wwmt1_aux
}
