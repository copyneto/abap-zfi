@EndUserText.label: 'CDS de projeção - Crescimento'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_CAD_CRESCI
  as projection on ZI_FI_CAD_CRESCI
{
  key DocUuidH,
  key DocUuidCresc,
      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_CONTRATO', element: 'Contrato' } }]
      Contrato,
      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_CONTRATO', element: 'Aditivo' } }]
      @EndUserText.label: 'Aditivo Contrato Cliente'
      Aditivo,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CO_FAMILIA_CL', element: 'Wwmt1' }}]
      @ObjectModel.text: { element: ['FamiliaClTxt'] }
      FamiliaCl,
      FamiliaClTxt,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_TP_AP_IMPOST', element: 'TipoApDevoluc' }}]
      @ObjectModel.text: { element: ['TipoApDevolucText'] }
      TipoApDevoluc,
      TipoApDevolucText,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_TP_APU_IMP', element: 'TipoApImpId' }}]
      @ObjectModel.text: { element: ['TipoApImpText'] }
      TipoApImposto,
      TipoApImpText,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_TP_IMPOSTOS', element: 'TipoImpId' }}]
      @ObjectModel.text: { element: ['TipoImpostoText'] }
      TipoImposto,
      TipoImpostoText,
      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_FORMA_DESCONTO', element: 'TipoFormaId' } }]
      FormaDescont,
      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_AJUSTE_ANUAL', element: 'XFLD' } }]
      AjusteAnual,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_PERIODIC', element: 'TipoPeriodicidade' }}]
      @ObjectModel.text: { element: ['PeriodicidadeText'] }
      Periodicidade,
      PeriodicidadeText,
      @EndUserText.label: 'Início da Periodicidade'
      InicioPeriodic,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_KATR2', element: 'katr2' }}]
      @ObjectModel.text: { element: ['ClassificCnpjText'] }
      ClassificCnpj,
      ClassificCnpjText,
      @EndUserText.label: 'Classificação CNPJ(Todos)'
      FlagTdAtribut,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_TIPO_COMPARACAO', element: 'TipoComparacaoId' }}]
      @ObjectModel.text: { element: ['TipoComparacaoText'] }
      TipoComparacao,
      TipoComparacaoText,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _Crescimento : redirected to parent ZC_FI_CONTRATO_CRESC
}
