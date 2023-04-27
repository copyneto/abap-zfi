@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Autom. textos contábeis - Documentos'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_AUTOTXT_DOCCONTABIL_1ITM
  as select from P_BSEG_COM1 as DocumentItem
{

  key bukrs,
  key belnr,
  key gjahr,
      max(projk) as projk,
      max(aufnr) as aufnr
}
group by
  bukrs,
  belnr,
  gjahr
  
