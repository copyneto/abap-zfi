@EndUserText.label: 'Manutenção de Contas'
@AccessControl.authorizationCheck: #CHECK
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZC_FI_MAN_CONTAS
  as projection on ZI_FI_MAN_CONTAS as Contas
{
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_AssetClassStdVH', element: 'AssetClass' }  } ]
      @Search.defaultSearchElement: true
  key Anlkl,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_DepreciationArea', element: 'AssetDepreciationArea' }  } ]
      @Search.defaultSearchElement: true
  key Afaber,
 //    @Consumption.filter : { defaultValue: 'PC3C' }
     @Consumption.valueHelpDefinition: [ { entity: { name: 'I_GLAccountStdVH', element: 'GLAccount' }  } ]
//     @Consumption.valueHelpDefinition.additionalBinding: [{ localElement: 'ChartOfAccounts', element: 'carrier_idChartOfAccounts' }]
      DeprecFiscal,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_GLAccountStdVH', element: 'GLAccount' }  } ]
      DespesaFiscal,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_GLAccountStdVH', element: 'GLAccount' }  } ]
      DeprecSocietaria,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_GLAccountStdVH', element: 'GLAccount' }  } ]
      DespesaSocietaria,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_GLAccountStdVH', element: 'GLAccount' }  } ]
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
