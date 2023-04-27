@EndUserText.label: 'CDS de projeção - Faixa e Bônus - Cresci Contrato Cliente'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_FAIXA_CRESC
  as projection on ZI_FI_FAIXA_CRESC
{
  key DocUuidH,
  key DocUuidFaixa,
      Contrato,
      @EndUserText.label: 'Aditivo Contrato Cliente'
      Aditivo,
      @EndUserText.label: 'Moeda'
      Moeda,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_CODIGO_VALOR', element: 'TipoDescId'  }}]
      @ObjectModel.text: { element: ['CodFaixaText'] }
      @EndUserText.label: 'Código Faixa de Crescimento'
      CodFaixa,
      CodFaixaText,
      @EndUserText.label: '% Faixa de Crescimento Inicio'
      VlrFaixaIni,
      @EndUserText.label: '% Faixa de Crescimento Fim'
      VlrFaixaFim,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_COD_MONTANTE', element: 'TipoCodMont'  }}]
      @ObjectModel.text: { element: ['CodMontanteText'] }
      @EndUserText.label: 'Código Montante Faixa de Crescimento'
      CodMontante,
      CodMontanteText,
      @EndUserText.label: 'Montante Faixa de Crescimento Inicio'
      VlrMontIni,
      @EndUserText.label: 'Montante Faixa de Crescimento Fim'
      VlrMontFim,
      @EndUserText.label: '% Bonus de Crescimento'
      VlrBonusIni,
      @EndUserText.label: 'Montante Bonus de Crescimento'
      VlrMontbonusIni,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _Crescimento : redirected to parent ZC_FI_CONTRATO_CRESC
}
