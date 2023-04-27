@EndUserText.label: 'Consumo Config. WF Documentos a pagar'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_WF_DOCPAGAR
  as projection on ZI_FI_WF_DOCPAGAR
{
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZI_CA_VH_DOCTYPE',
              element: 'DocType'
          }
      }]
      @ObjectModel.text.element: ['DocTypeText']
  key DocumentType,
  key Counter,
      DocumentText,
      DocTypeText,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
