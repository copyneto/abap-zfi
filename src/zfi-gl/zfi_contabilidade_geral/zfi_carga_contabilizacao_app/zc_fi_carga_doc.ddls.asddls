@EndUserText.label: 'Carga Contabilização - Documento'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_CARGA_DOC
  as projection on ZI_FI_CARGA_DOC
{
  key DocUuidH,
  key DocUuidDoc,
      NumeroDoc,
      @ObjectModel.text.element: ['StatusText']
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZI_FI_STATUS_DOC_CARGA',
              element: 'StatusId'
          }
      }]
      Status,
      StatusText,
      StatusCriticality,
      Bukrs,
      Belnr,
      Blart,
      Bldat,
      Budat,
      Monat,
      Gjahr,
      Xblnr,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _H : redirected to parent ZC_FI_CARGA_H
}
