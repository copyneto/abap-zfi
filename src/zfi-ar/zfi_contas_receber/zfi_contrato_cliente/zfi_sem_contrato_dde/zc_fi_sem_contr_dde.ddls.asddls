@EndUserText.label: 'Projection Clientes Sem Contrato'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_SEM_CONTR_DDE as projection on ZI_FI_SEM_CONTR_DDE {
    @Consumption.valueHelpDefinition: [{entity: {name: 'I_COMPANYCODEVH', element: 'CompanyCode' }}]
    key Empresa,
    @Consumption.valueHelpDefinition: [{entity: {name: 'ZI_CA_VH_CUSTOMER', element: 'Customer' }}]
    key Cliente,
        GrpCondicoes,
    DiaMes,
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZI_FI_DIASEMANA', element: 'Diasemana' }}]    
//    @Consumption.valueHelpDefinition: [{entity: {name: 'ZI_FI_JANELASEMANA', element: 'JanelaSemana' }}]
//    @Consumption.valueHelpDefinition: [{entity: {name: 'ZI_CA_VH_CUSTOMER', element: 'Customer' }}]
    DiaSemana,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt
}
