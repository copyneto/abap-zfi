@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View para daddos de cobrança-boleto'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_BOLETO_BSID
  as select from bsid_view
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
  rebzz,
  zfbdt,
  madat,
  @Semantics.amount.currencyCode: 'WAERS'
  wrbtr,
  @Semantics.amount.currencyCode: 'WAERS'
  dmbtr
}
