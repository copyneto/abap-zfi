@EndUserText.label: 'Centro de custo - Cadastro'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_FI_CENTRO_DE_CUSTO
  as projection on ZI_FI_CENTRO_DE_CUSTO
{

      @ObjectModel.text.element: ['EmpresaTxt']
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.6
      @Search.ranking: #MEDIUM
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZI_CA_VH_BUKRS',
              element: 'Empresa'
          }
      }]
  key Bukrs,
      @ObjectModel.text.element: ['GsberTxt']
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.6
      @Search.ranking: #MEDIUM
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZI_FI_VH_GSBER',
              element: 'Gsber'
          }
      }]
  key Gsber,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.6
      @Search.ranking: #MEDIUM
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZI_CA_VH_BZIRK',
              element: 'RegiaoVendas'
          }
      }]
      @ObjectModel.text.element: ['RegionTxt']
  key Region,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.6
      @Search.ranking: #MEDIUM
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'I_CostCenterVH',
              element: 'CostCenter'
          }
      }]
      @ObjectModel.text.element: ['CostCenterTxt']
      Kostl,
      RegionTxt,
      EmpresaTxt,
      GsberTxt,
      CostCenterTxt,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
