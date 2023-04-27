@EndUserText.label: 'Carga Contabilização - Header'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_FI_CARGA_H
  as projection on ZI_FI_CARGA_H
{
  key DocUuidH,
      Documentno,
      @Consumption.filter.selectionType: #INTERVAL
      DataCarga,
      @ObjectModel.text.element: ['StatusText']
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZI_FI_STATUS_CARGA',
              element: 'StatusId'
          }
      }]
      @EndUserText.label:'Status'
      Status,
      StatusText,
      StatusCriticality,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _Doc  : redirected to composition child ZC_FI_CARGA_DOC,
      _Item : redirected to composition child ZC_FI_CARGA_ITEM
}
