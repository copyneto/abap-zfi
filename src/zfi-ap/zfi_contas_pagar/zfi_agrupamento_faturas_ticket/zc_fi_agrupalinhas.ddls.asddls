@EndUserText.label: 'Proj. Linhas do arquivo de agrupamento'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_AGRUPALINHAS
  as projection on ZI_FI_AGRUPALINHAS

  //  association [0..1] to ZI_CA_VH_COMPANY        as _Company
  //    on $projection.selcompanycode = _Company.CompanyCode
  //
  //  association [0..1] to ZI_FI_VH_FORN_AGRUPADOR as _FornAgrupador
  //    on $projection.selfornagrupa = _FornAgrupador.FornAgrupador
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
      @EndUserText.label: 'Status'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_VH_AGRUPA_ITEM_STATUS', element: 'StatusId' } }]
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
      @EndUserText.label: 'Fornecedor Destino'
      FornAgrupador,
      @EndUserText.label: 'Fatura Agrupada'
      FaturaAgrupada,
      @EndUserText.label: 'Referência Agrupada'
      RefAgrupada,
      //      selCompanyCode,
      //      selFornAgrupa,
      //      selDueDate,
      //      selReference,
      //      selPostingDate,
      //      selDocumentDate,
      //      selDocumentText,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      //      _Company,
      //      _FornAgrupador,
      _ItemStatus,
      _Arquivo : redirected to parent ZC_FI_AGRUPAFATURAS
}
