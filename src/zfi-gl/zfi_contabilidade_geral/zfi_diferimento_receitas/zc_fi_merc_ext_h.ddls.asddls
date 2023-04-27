@EndUserText.label: 'CDS de Projeção - Mercado Externo Header'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_MERC_EXT_H
  as projection on ZI_FI_MERC_EXT_H
{
      @Consumption.filter: { mandatory: true }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_BUKRS', element: 'Empresa' } } ]
      @EndUserText.label: 'Empresa'
  key Empresa,
      @EndUserText.label: 'Numero documento'
  key NumDoc,
      @EndUserText.label: 'Ano'
  key Ano,
      @EndUserText.label: 'Data documento'
      DataDocumento,
      @EndUserText.label: 'Data lançamento'
      DataLancamento,
      @EndUserText.label: 'Mês'
      Mes,
      @EndUserText.label: 'Tipo documento'
      TipoDocumento,

      Moeda,
      @EndUserText.label: 'Referência'
      Referencia,
      @EndUserText.label: 'Texto cabeçalho'
      TextoCab,
      @EndUserText.label: 'Nº da Remessa'
      ReferenceSDDocument,
      DataLanc,
      DataEstorno,
//      @Semantics.amount.currencyCode: 'TransactionCurrency'
      @EndUserText.label: 'Valor'
      TotalNetAmount,
      TransactionCurrency,
      @EndUserText.label: 'Valor'
      Amount,
      @EndUserText.label: 'Valor'
      TotalAmountBRL,
      @EndUserText.label: 'Moeda'
      CurrencyBRL,
      
      /* Associations */
      _MercExtItem : redirected to composition child ZC_FI_MERC_EXT_I
}
