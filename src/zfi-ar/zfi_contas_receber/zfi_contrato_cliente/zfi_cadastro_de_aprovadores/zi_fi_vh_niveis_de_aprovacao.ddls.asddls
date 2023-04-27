@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Help Search:  Níveis de Aprovação'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Search.searchable: true
define view entity ZI_FI_VH_NIVEIS_DE_APROVACAO
  as select from ZI_FI_NIVEIS_DE_APROVACAO
{

      @ObjectModel.text.element: ['Descricao']
      @Search.ranking: #MEDIUM
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key Nivel     as Nivel,

      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      @Search.fuzzinessThreshold: 0.7
      DescNivel as Descricao


}
