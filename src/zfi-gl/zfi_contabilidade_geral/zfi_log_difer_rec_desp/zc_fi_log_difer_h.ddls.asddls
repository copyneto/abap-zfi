@EndUserText.label: 'Log Diferimento - Header'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_LOG_DIFER_H as projection on ZI_FI_LOG_DIFER_H {
    key IdLog,
    @ObjectModel.text.element: ['CompanyCodeName']
    @Consumption.valueHelpDefinition: [{ entity : {name: 'I_CompanyCode', element: 'CompanyCode'  } }]    
    Empresa,
    Datalanc,
    Dataestorno,
    Gjahr,
    BelnrRecCli,
    descricao,
    BelnrRazRaz,
    @Consumption.valueHelpDefinition: [{ entity: { name: 'zi_fi_log_difer_vh_status', element: 'DomvalueL' } }]
    @ObjectModel.text.element: ['StText']
    Status,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    StCor,
    /* Associations */
    _CompanyCode.CompanyCodeName,
    StText,
    _LOG_DIFER_D : redirected to composition child ZC_FI_LOG_DIFER_D,
    _LOG_DIFER_M : redirected to composition child ZC_FI_LOG_DIFER_M
}
