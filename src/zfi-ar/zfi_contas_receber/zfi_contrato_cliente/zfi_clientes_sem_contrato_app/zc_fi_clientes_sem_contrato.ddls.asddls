@EndUserText.label: 'Clientes Sem Contrato'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_CLIENTES_SEM_CONTRATO
  as projection on ZI_FI_CLIENTES_SEM_CONTRATO
{
      @Consumption.valueHelpDefinition: [{
                entity: {
                    name: 'I_CompanyCodeVH',
                    element: 'CompanyCode'
                }
            }]
      @ObjectModel.text.element: ['CompanyCodeName']
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.6
      @Search.ranking: #MEDIUM
  key Bukrs,
      @Consumption.valueHelpDefinition: [{
              entity: {
                  name: 'I_Customer_VH',
                  element: 'Customer'
              }
          }]
      @ObjectModel.text.element: ['CustomerName']
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.6
      @Search.ranking: #MEDIUM
  key Kunnr,
      @Consumption.valueHelpDefinition: [{
            entity: {
                name: 'ZI_CA_VH_TVKGGT',
                element: 'Kdkgr'
            }
        }]
      @ObjectModel.text.element: ['Vtext']
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.6
      @Search.ranking: #MEDIUM
      @EndUserText.label: 'Possui janela BP'
      GrupoCond,
      CompanyCodeName,
      CustomerName,
      Vtext,
      DiaFixo,
      //      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_DIA_SEMANA', element: 'StatusId' } }]
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZI_FI_DIASEMANA', element: 'Diasemana' }}]       
      @ObjectModel.text: { element: ['DiaSemanaText'] }
      DiaSemana,
      DiaSemanaText,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
