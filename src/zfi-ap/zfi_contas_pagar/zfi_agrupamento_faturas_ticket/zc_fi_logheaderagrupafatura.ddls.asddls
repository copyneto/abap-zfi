@EndUserText.label: 'Proj. Log Agrupamento de faturas - Cab.'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_LOGHEADERAGRUPAFATURA
  as projection on ZI_FI_LOGHEADERAGRUPAFATURA
{
  key IdArquivo,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_FI_VH_ARQUIVO_AGRUPA', element: 'Arquivo' }  } ]
      Arquivo,
      @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
      @Semantics.dateTime: true
      DataImportacao,
      HoraImportacao,
      @EndUserText.label: 'Status'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_VH_AGRUPA_ARQ_STATUS', element: 'StatusId' } }]
      @ObjectModel.text.element: ['StatusText']
      StatusProcessamento,
      StatusCriticality,
      _Status.StatusText,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_COMPANY', element: 'CompanyCode' } }]
      CompanyCode,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_VH_FORN_AGRUPADOR', element: 'FornAgrupador' } }]
      FornAgrupador,
      @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
      @Semantics.dateTime: true
      Vencimento,
      Referencia,
      @Semantics.amount.currencyCode: 'Currency'
      Desconto,
      @Semantics.currencyCode: true
      Currency,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _Status,
      _ItemLog : redirected to composition child ZC_FI_LOGITEMAGRUPAFATURA
}
