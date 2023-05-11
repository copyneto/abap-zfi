@AbapCatalog.sqlViewName: 'ZVDDELC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Buscar documento LC'
define view ZI_FI_DDE_DOC_LC
  as select from bsid_view
{
  key bukrs,
  key kunnr,
  key gjahr,
  key belnr,
  key buzei,
      budat,
      anfbn,
      anfbj,
      anfbu

}
