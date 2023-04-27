@EndUserText.label: 'Proj. Arquivo agrupamento de faturas'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_AGRUPAFATURAS
  as projection on ZI_FI_AGRUPAFATURAS

{
  key IdArquivo,

      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_FI_VH_ARQUIVO_AGRUPA', element: 'Arquivo' }  } ]
      Arquivo,
      @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
      @Semantics.dateTime: true
      DataImportacao,
      @EndUserText.label: 'Status'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_VH_AGRUPA_ARQ_STATUS', element: 'StatusId' } }]
      @ObjectModel.text.element: ['StatusText']
      StatusProcessamento,
      StatusCriticality,
      _Status.StatusText,
      selCompanyCode,
      selFornAgrupa,
      selDueDate,
      selReference,
      selPostingDate,
      selDocumentDate,
      selCostCenter,
      selDesconto,
      selCurrency,
      CompanyCode,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _Status,
      _Linhas : redirected to composition child ZC_FI_AGRUPALINHAS

}
