@EndUserText.label: 'CDS de Projeção - Mercado Interno Header'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_MERC_INT_H
  as projection on ZI_FI_MERC_INT_H
{
      @Consumption.filter: { mandatory: true }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_BUKRS', element: 'Empresa' } } ]
      @EndUserText.label: 'Empresa'
  key Empresa,
      @EndUserText.label: 'Numero documento'
  key NumDoc,
      @EndUserText.label: 'Ano'
  key Ano,
      @EndUserText.label: 'Documento TM'
      OrdemFrete,
      @EndUserText.label: 'Data documento'
      DataDocumento,
      @EndUserText.label: 'Data lançamento'
      DataLancamento,
      @EndUserText.label: 'Mês'
      Mes,
      @EndUserText.label: 'Tipo documento'
      TipoDocumento,
      @EndUserText.label: 'Moeda'
      Moeda,
      @EndUserText.label: 'Referência'
      Referencia,
      @EndUserText.label: 'Texto cabeçalho'
      TextoCab,
      DataLanc,
      DataEstorno,
//      Dias,
      Remessa,
      @EndUserText.label: 'Nº da Remessa'
      ReferenceSDDocument,
      @EndUserText.label: 'Apto Diferimento'
      AptoDiferimento,
      @EndUserText.label: 'Data Diferimento'
      DataAtual,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      TotalNetAmount,
      @EndUserText.label: 'Valor'
      TotalDocument,
      TransactionCurrency,
      @EndUserText.label: 'Valor'      
      Amount,
      /* Associations */
      _MercIntItem: redirected to composition child ZC_FI_MERC_INT_I
}
