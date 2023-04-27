@EndUserText.label: 'Codição de Deconto'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_FI_CONDICAO_DESCONTO
  as projection on ZI_FI_CONDICAO_DESCONTO
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.6
      @Search.ranking: #MEDIUM
//      @ObjectModel.text.element: ['Name']
//      @Consumption.valueHelpDefinition: [{
//          entity: {
//              name: 'I_SalesPricingConditionTypeVH',
//              element: 'ConditionType'
//          }
//      }]
@EndUserText.label: 'Condição de Desconto'
  key TipoCond,
//      Name,
@EndUserText.label: 'Denominação de Condição'
     Text,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
