@EndUserText.label: 'Proj. Log Agrupamento de faturas - Itens'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_LOGITEMAGRUPAFATURA
  as projection on ZI_FI_LOGITEMAGRUPAFATURA
{
  key IdArquivo,
  key Id,
      CompanyCode,
      Supplier,
      NotaFiscal,
      DataArquivo,
      TipoNF,
      ChaveAcesso,
      Cnpj,
      DueDate,
      @ObjectModel.text.element: ['StatusText']
      ItemStatus,
      ItemCriticality,
      _ItemStatus.StatusText,
      ValorNFArquivo,
      ValorNFFatura,
      CurrencyCode,
      AccountingDocument,
      FiscalYear,
      AccountingItem,
      DtEmissaoArquivo,
      DtEmissaoFatura,
      BusinessPlace,
      Assignment,
      ItemText,
      ProfitCenter,
      Msg,
      FornAgrupador,
      FaturaAgrupada,
      RefAgrupada,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _ItemStatus,
      _HeaderLog : redirected to parent ZC_FI_LOGHEADERAGRUPAFATURA
}
