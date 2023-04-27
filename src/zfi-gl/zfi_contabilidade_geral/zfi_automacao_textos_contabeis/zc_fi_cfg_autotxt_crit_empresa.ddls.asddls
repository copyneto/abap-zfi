@EndUserText.label: 'Proj.Autom.txt contáb. Crit.sel.Empresa'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_CFG_AUTOTXT_CRIT_EMPRESA
  as projection on ZI_FI_CFG_AUTOTXT_CRIT_EMPRESA
{
  key IdSelCompany,
      IdRegra,
      CritSelCompany,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_PARAM_SIGN', element: 'DomvalueL'  } } ]
      @ObjectModel.text.element: ['SignTextCompany']
      @UI.textArrangement: #TEXT_LAST
      SignCompany,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_PARAM_DDOPTION', element: 'DomvalueL' } } ]
      @ObjectModel.text.element: ['OptTextCompany']
      @UI.textArrangement: #TEXT_LAST
      OptCompany,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_VH_COMPANY', element: 'CompanyCode' }  } ]
      LowCompany,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_VH_COMPANY', element: 'CompanyCode' }  } ]
      HighCompany,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      SignTextCompany,
      OptTextCompany,
      /* Associations */
      _Regras : redirected to parent ZC_FI_CFG_AUTO_TEXTOS_REGRAS
}
