@EndUserText.label: 'Consumo - Log WF'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_WF_LOG 
  as projection on ZI_FI_WF_LOG {
    key Uuid,
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_WF_WORKITEM_SH', element: 'WiID' } }]
    key WfId,
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_USER', element: 'Bname' } }]
    @ObjectModel.text: { element: ['AprovadorDesc'] }
    @EndUserText.label: 'Aprovador'
    key Aprovador,
    NivelAprovacao,
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_WF_WORKITEM_TASK_SH', element: 'WiID' } }]
    TaskId,    
    @UI.hidden: true
    AprovadorDesc,
    @Consumption.filter: { selectionType: #INTERVAL }
    @EndUserText.label: 'Data Execução'
    Data,
    @Consumption.filter: { selectionType: #INTERVAL }
    @EndUserText.label: 'Hora Execução'
    Hora,
    @Consumption.valueHelpDefinition: [{ entity : {name: 'I_CompanyCode', element: 'CompanyCode'  } }]
    //@Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_MM_VH_EMPRESA', element: 'companycode' } }]
    @ObjectModel.text: { element: ['EmpresaDesc'] }
    Empresa,
    @UI.hidden: true
    EmpresaDesc,
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_WF_DOC_SH', element: 'Belnr' } }]
    Documento,
    @Consumption.valueHelpDefinition: [ { entity: { name: 'C_CnsldtnFiscalYearVH', element: 'FiscalYear' } } ]
    Exercicio,
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_WF_DOC_SH', element: 'Buzei' } }]
    Item,
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_WF_STATUS_SH', element: 'StatusId' } }] 
    @ObjectModel.text: { element: ['StatusDesc'] }
    StatusAprovacao,
    @UI.hidden: true
    StatusDesc,
    @UI.hidden: true
    StatusCriticality
}
