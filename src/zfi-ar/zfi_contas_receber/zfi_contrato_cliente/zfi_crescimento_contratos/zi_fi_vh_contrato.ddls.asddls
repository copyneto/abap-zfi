@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Filtro Contrato'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Search.searchable: true
define view entity ZI_FI_VH_CONTRATO
  as select from ztfi_contrato
{
      @Search.ranking: #MEDIUM
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key contrato as Contrato,
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      @Search.fuzzinessThreshold: 0.7
  key aditivo  as Aditivo


}
group by
  contrato,
  aditivo
