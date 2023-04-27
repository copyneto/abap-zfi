@EndUserText.label: 'CDS de Projeção - Contabilização Cabeçalho'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_CONTAB_CAB
  as projection on ZI_FI_CONTAB_CAB
{
  key Id,
  key Identificacao,
      @EndUserText.label: 'Status'
      StatusText,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_VH_STATUS_CONTABILIZACAO', element: 'StatusCode' } } ]
      @ObjectModel.text.element: ['StatusText']
      StatusCode,
      @EndUserText.label: 'Status'
      StatusCriticality,
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_COMPANYCODEVH', element: 'CompanyCode' }}]
      Empresa,
      @Consumption.filter.selectionType: #INTERVAL
      DataDocumento,
      @Consumption.filter.selectionType: #INTERVAL
      DataLancamento,
      TipoDocumento,
      Referencia,
      TextCab,
      @EndUserText.label: 'Mensagem'
      TextStatus,
      /* Associations */
      _Item : redirected to composition child ZC_FI_CONTAB_ITEM
}
