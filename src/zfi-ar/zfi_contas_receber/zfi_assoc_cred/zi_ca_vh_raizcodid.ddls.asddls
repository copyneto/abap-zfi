@AbapCatalog.sqlViewName: 'ZVCA_RAIZID'
//@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Search Help: Raiz ID'
@Search.searchable: true
define view ZI_CA_VH_RAIZCODID 
  as select from ZI_FI_CLIENTE_RAIZ as RaizId
{
      @EndUserText.label: 'Cliente'
//      @ObjectModel.text.element: ['Cliente']
      @Search.ranking: #MEDIUM
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key Cliente,
      @EndUserText.label: 'RaizId'
//      @ObjectModel.text.element: ['RaizId']
      @Search.ranking: #MEDIUM
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key RaizId,
      @EndUserText.label: 'Nome'
//      @ObjectModel.text.element: ['Nome']
      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      @Search.fuzzinessThreshold: 0.7
      Nome
}
