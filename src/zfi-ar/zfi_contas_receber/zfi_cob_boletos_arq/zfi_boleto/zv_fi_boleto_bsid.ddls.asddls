@AbapCatalog.sqlViewName: 'ZV_FI_BOL_BSID'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Dados para preencher o boleto'
define view ZV_FI_BOLETO_BSID 

as select distinct from bsid_view
{
  key bukrs,
  key belnr,
  key gjahr,
  key buzei,
  xblnr,
  kunnr,
  gsber,
  hbkid,
  xref3,
  zuonr,
  bldat,
  waers,
  zbd1t,
  zbd2t,
  zbd3t,
  vbeln,
  bupla,
  zbd1p,
  zbd2p,
  zterm,
  zlsch,
  rebzg,
  rebzj,
  rebzz,
  zfbdt,
  madat,
  @Semantics.amount.currencyCode: 'WAERS'
  wrbtr,
  @Semantics.amount.currencyCode: 'WAERS'
  dmbtr
}
