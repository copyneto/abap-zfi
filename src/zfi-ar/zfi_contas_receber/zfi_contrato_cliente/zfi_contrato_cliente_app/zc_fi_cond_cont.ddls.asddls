@EndUserText.label: 'Condições Desconto - Contrato'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_COND_CONT
  as projection on ZI_FI_COND_CONT
{
  key DocUuidH,
  key DocUuidCond,
      Contrato,
      Aditivo,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_COND_DESCONTO', element: 'TipoCond'  }}]
      @ObjectModel.text: { element: ['TipoCondText'] }
      @EndUserText.label: 'Condição de Desconto'
      TipoCond,
      TipoCondText,
      @EndUserText.label: 'Percentual'
      Percentual,
      @EndUserText.label: 'Montante Condição'
      Montante,
      Moeda,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_TP_APLIC_DESC', element: 'TipoAplicId' }}]
      @ObjectModel.text: { element: ['AplicacaoText'] }
      Aplicacao,
      AplicacaoText,
      PerVigencia,
      RecorrenciaAnual,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _Contrato : redirected to parent ZC_FI_CONTRATO
}
