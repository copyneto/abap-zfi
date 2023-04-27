@EndUserText.label: 'Proj.Autom.txt contáb. Crit.sel.Conta'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_CFG_AUTOTXT_CRIT_CONTA
  as projection on ZI_FI_CFG_AUTOTXT_CRIT_CONTA
{
  key IdSelAccount,
      IdRegra,
      CritSelAccount,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_PARAM_SIGN', element: 'DomvalueL'  } } ]
      @ObjectModel.text.element: ['SignTextAccount']
      @UI.textArrangement: #TEXT_LAST
      SignAccount,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_PARAM_DDOPTION', element: 'DomvalueL' } } ]
      @ObjectModel.text.element: ['OptTextAccount']
      @UI.textArrangement: #TEXT_LAST
      OptAccount,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_FI_VH_SAKNR_PC3C', element: 'GLAccount' } } ]
      LowAccount,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_FI_VH_SAKNR_PC3C', element: 'GLAccount' } } ]
      HighAccount,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      SignTextAccount,
      OptTextAccount,
      /* Associations */
      _Regras : redirected to parent ZC_FI_CFG_AUTO_TEXTOS_REGRAS
}
