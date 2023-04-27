@EndUserText.label: 'Autom. Textos contáb.Campos das Regras'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_CFG_AUTO_TEXTOS_CAMPOS
  as projection on ZI_FI_CFG_AUTO_TEXTOS_CAMPOS
{
  key Id,
      IdRegra,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_FI_VH_AUTOTXT_CAMPOS', element: 'Valor' }  } ]
      @ObjectModel.text.element: ['NomeCampo']
      Campo,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_FI_VH_AUTOTXT_ORDEM_CAMPOS', element: 'Valor' }  } ]
      Ordenacao,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      NomeCampo,
      /* Associations */
      _Regras : redirected to parent ZC_FI_CFG_AUTO_TEXTOS_REGRAS,
      _NomeCampo


}
