@EndUserText.label: 'Proj.Autom.txt contáb. Crit.Tipo Produto'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_CFG_AUTOTXT_CRIT_PRODTP
  as projection on ZI_FI_CFG_AUTOTXT_CRIT_PRODTP
{
  key IdSelFIProdType,
      IdRegra,
      CritSelFIProdType,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_PARAM_SIGN', element: 'DomvalueL'  } } ]
      @ObjectModel.text.element: ['SignTextFIProdtype']
      @UI.textArrangement: #TEXT_LAST
      SignFIProdType,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_PARAM_DDOPTION', element: 'DomvalueL' } } ]
      @ObjectModel.text.element: ['OptTextFIProdtype']
      @UI.textArrangement: #TEXT_LAST
      OptFIProdType,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_FI_VH_FIINSTRPRODTTYPE', element: 'FinancialInstrumentProductType' }  } ]
      LowFIProdType,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_FI_VH_FIINSTRPRODTTYPE', element: 'FinancialInstrumentProductType' }  } ]
      HighFIProdType,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      SignTextFIProdType,
      OptTextFIProdType,
      /* Associations */
      _Regras : redirected to parent ZC_FI_CFG_AUTO_TEXTOS_REGRAS
}
