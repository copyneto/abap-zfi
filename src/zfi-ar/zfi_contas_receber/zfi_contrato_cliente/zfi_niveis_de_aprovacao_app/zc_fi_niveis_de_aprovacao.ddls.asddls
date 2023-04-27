@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Cadastro de Níveis de Aprovação'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_FI_NIVEIS_DE_APROVACAO
  as projection on ZI_FI_NIVEIS_DE_APROVACAO
{
      @Search.defaultSearchElement: true
      @Search.ranking: #MEDIUM
  key Nivel,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.6
      @Search.ranking: #MEDIUM
      DescNivel,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
