@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Search Help - Documento'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_WF_DOC_SH
  as select from bseg as _Bseg
{
  key bukrs as Bukrs,
  key belnr as Belnr,
  key gjahr as Gjahr,
  key buzei as Buzei
}
