@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'GKO - Incoming Invoice - Doc Contábil'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_TM_GKO_DOC_CONTABIL
  as select from j_1bnfdoc
{
  key docnum               as docnum,
      concat(belnr, gjahr) as awkey
}
