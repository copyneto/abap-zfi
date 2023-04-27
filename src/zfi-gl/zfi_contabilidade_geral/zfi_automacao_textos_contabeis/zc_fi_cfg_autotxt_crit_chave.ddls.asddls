@EndUserText.label: 'Proj.Autom.txt contáb. Crit.Chave Lancto'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_CFG_AUTOTXT_CRIT_CHAVE
  as projection on ZI_FI_CFG_AUTOTXT_CRIT_CHAVE
{
  key IdSelPostingKey,
      IdRegra,
      CritSelPostingKey,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_PARAM_SIGN', element: 'DomvalueL'  } } ]
      @ObjectModel.text.element: ['SignTextPostingKey']
      @UI.textArrangement: #TEXT_LAST
      SignPostingKey,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_PARAM_DDOPTION', element: 'DomvalueL' } } ]
      @ObjectModel.text.element: ['OptTextPostingKey']
      @UI.textArrangement: #TEXT_LAST
      OptPostingKey,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_VH_BSCHL', element: 'PostingKey' }  } ]
      LowPostingKey,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_VH_BSCHL', element: 'PostingKey' }  } ]
      HighPostingKey,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      SignTextPostingKey,
      OptTextPostingKey,
      /* Associations */
      _Regras : redirected to parent ZC_FI_CFG_AUTO_TEXTOS_REGRAS
}
