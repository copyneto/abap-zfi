@EndUserText.label: 'Proj.Autom.txt contáb. Crit.sel.Tp Doc'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_CFG_AUTOTXT_CRIT_TIPODOC
  as projection on ZI_FI_CFG_AUTOTXT_CRIT_TIPODOC
{
  key IdSelDocType,
      IdRegra,
      CritSelDocType,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_PARAM_SIGN', element: 'DomvalueL'  } } ]
      @ObjectModel.text.element: ['SignTextDocType']
      @UI.textArrangement: #TEXT_LAST
      SignDocType,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_PARAM_DDOPTION', element: 'DomvalueL' } } ]
      @ObjectModel.text.element: ['OptTextDocType']
      @UI.textArrangement: #TEXT_LAST
      OptDocType,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_FI_VH_AUTOTXT_DOCTYPE', element: 'DocType' }  } ]
      LowDocType,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_FI_VH_AUTOTXT_DOCTYPE', element: 'DocType' }  } ]
      HighDocType,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      SignTextDocType,
      OptTextDocType,
      /* Associations */
      _Regras : redirected to parent ZC_FI_CFG_AUTO_TEXTOS_REGRAS
}
