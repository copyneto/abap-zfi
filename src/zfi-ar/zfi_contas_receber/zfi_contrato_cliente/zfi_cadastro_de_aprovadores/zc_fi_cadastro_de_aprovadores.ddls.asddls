@EndUserText.label: 'Configurar Níveis Aprovação e Usuário'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_FI_CADASTRO_DE_APROVADORES
  as projection on ZI_FI_CADASTRO_DE_APROVADORES
{

           @Consumption.valueHelpDefinition: [{
           entity: {
               name: 'ZI_FI_VH_NIVEIS_DE_APROVACAO',
               element: 'Nivel'
           }
           }]

  key      Nivel,
           @Consumption.valueHelpDefinition: [{
           entity: {
               name: 'ZI_CA_VH_DADOS_USUARIO',
               element: 'ContactCardID'
           }
           }]
  key      Bname,
           @Search.fuzzinessThreshold: 0.6
           @Search.ranking: #MEDIUM
           @Consumption.valueHelpDefinition: [{
               entity: {
                   name: 'I_CompanyCodeVH',
                   element: 'CompanyCode'
               }
           }]
           @ObjectModel.text.element: ['CompanyCodeName']
           //      @Search.defaultSearchElement: true
           //      @Search.fuzzinessThreshold: 0.6
           //      @Search.ranking: #MEDIUM
  key      Bukrs,
           @Consumption.valueHelpDefinition: [{
                   entity: {
                       name: 'ZI_CA_VH_BRANCH',
                       element: 'BusinessPlace'
                   },
                   additionalBinding: [{ element: 'Bukrs' }]

               }]
           @ObjectModel.text.element: ['BusinessPlaceName']
           //      @Search.fuzzinessThreshold: 0.6
           //      @Search.ranking: #MEDIUM
  key      Branch,
           @Consumption.valueHelpDefinition: [{
           entity: {
               name: 'ZI_FI_VH_NIVEIS_DE_APROVACAO',
               element: 'Nivel'
           }
           }]
           @ObjectModel.text.element: ['DescNivel']
           CompanyCodeName,
           @Search.fuzzinessThreshold: 0.6
           @Search.ranking: #MEDIUM
           DescNivel,
           BusinessPlaceName,
           Email,
           CreatedBy,
           CreatedAt,
           LastChangedBy,
           LastChangedAt,
           LocalLastChangedAt


}
