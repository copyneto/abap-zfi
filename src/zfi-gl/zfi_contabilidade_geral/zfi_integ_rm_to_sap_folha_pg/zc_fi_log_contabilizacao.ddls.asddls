@EndUserText.label: 'CDS de Projeção - Log Contabilização'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_LOG_CONTABILIZACAO
  as projection on ZI_FI_LOG_CONTABILIZACAO
{
  key Id,
  key Identificacao,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_VH_LOG_STATUS_CONTAB', element: 'ObjectId' } } ]
      @ObjectModel.text.element: ['StatusText']
      StatusCode,
      @EndUserText.label: 'Status'
      StatusText,
      @EndUserText.label: 'Status'
      StatusCriticality,
      @Semantics.user.createdBy: true
      Usuario,
      @Consumption.filter.selectionType: #INTERVAL
      @EndUserText.label: 'Data de execução'
      DtExec,
      //      @Consumption.filter.selectionType: #INTERVAL
      @EndUserText.label: 'Hora de execução'
      HrExec,
      Descricao 
      
}
