@EndUserText.label: 'Consumption View - Log Totvs'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_FI_TOTVS_LOG
  as projection on ZI_FI_TOTVS_LOG
{
  key Identificacao,
      @ObjectModel.text.element: ['StatusText']
  key Status,
  key Data,
  key Hora,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      Mensagem,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      StatusCriticality,

      _Status.StatusText,

      _Status
}
