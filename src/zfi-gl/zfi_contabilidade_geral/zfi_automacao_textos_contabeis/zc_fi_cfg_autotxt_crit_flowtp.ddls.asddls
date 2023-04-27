@EndUserText.label: 'Proj.Autom.txt contáb. Crit.Tipo Atualiz'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_CFG_AUTOTXT_CRIT_FLOWTP
  as projection on ZI_FI_CFG_AUTOTXT_CRIT_FLOWTP
{
  key IdSelTreasuryUpdateType,
      IdRegra,
      CritSelTreasuryUpdateType,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_PARAM_SIGN', element: 'DomvalueL'  } } ]
      @ObjectModel.text.element: ['SignTextTreasuryUpdateType']
      @UI.textArrangement: #TEXT_LAST
      SignTreasuryUpdateType,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_PARAM_DDOPTION', element: 'DomvalueL' } } ]
      @ObjectModel.text.element: ['OptTextTreasuryUpdateType']
      @UI.textArrangement: #TEXT_LAST
      OptTreasuryUpdateType,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_FI_VH_TREASURYUPDATETYPE', element: 'TreasuryUpdateType' }  } ]
      LowTreasuryUpdateType,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_FI_VH_TREASURYUPDATETYPE', element: 'TreasuryUpdateType' }  } ]
      HighTreasuryUpdateType,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      SignTextTreasuryUpdateType,
      OptTextTreasuryUpdateType,
      /* Associations */
      _Regras : redirected to parent ZC_FI_CFG_AUTO_TEXTOS_REGRAS
}
