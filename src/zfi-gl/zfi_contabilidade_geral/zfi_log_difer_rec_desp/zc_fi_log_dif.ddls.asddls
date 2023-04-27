@EndUserText.label: 'CDS de Projeção - Log Diferimento'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_LOG_DIF
  as projection on ZI_FI_LOG_DIF 
{
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_BUKRS', element: 'Empresa' } } ]
      @EndUserText.label: 'Empresa'
  key Empresa,
      @EndUserText.label: 'Numero documento'
  key NumDoc,
      @EndUserText.label: 'Ano'
  key Ano,
      @EndUserText.label: 'Status' 
      StatusText,
      @EndUserText.label: 'Status'
      StatusCriticality,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_LOG_DIFER_VH_STATUS', element: 'DomvalueL' } } ]
      @ObjectModel.text.element: ['StatusText']
      @EndUserText.label: 'Status'
      Status,
      @Semantics.user.createdBy: true
      Usuario,
      @Consumption.filter.selectionType: #INTERVAL
      @EndUserText.label: 'Data de execução'
      DtExec,
      @EndUserText.label: 'Hora de execução'
      HrExec,
      Descricao,
      
      _Mensagens : redirected to composition child ZC_FI_LOG_MSG
      
}
