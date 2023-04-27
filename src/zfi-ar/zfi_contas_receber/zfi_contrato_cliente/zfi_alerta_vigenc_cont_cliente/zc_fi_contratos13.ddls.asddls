@EndUserText.label: 'Alerta de Vigência Contratos Cliente'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_CONTRATOS13
  as projection on ZI_FI_CONTRATOS13
{
  KEY Id,
  @Consumption.valueHelpDefinition: [{ entity:{ name: 'ZI_CA_VH_BUKRS', element : 'Empresa' } }]
  @ObjectModel.text.element: ['Name1']
  key Empresa,
   @Consumption.valueHelpDefinition: [{
   entity: { name: 'ZI_CA_VH_BRANCH',
   element: 'BusinessPlace' },
   additionalBinding: [ {element: 'CompanyCode'    , localElement: 'Empresa' }]
   }]  
  key LocalNegocio,
      Email,
      Nome,
      Name1,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
