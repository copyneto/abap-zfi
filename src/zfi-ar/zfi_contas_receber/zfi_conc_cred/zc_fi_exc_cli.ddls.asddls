@EndUserText.label: 'Projection Exclusão de Clientes'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_EXC_CLI
  as projection on ZI_FI_EXC_CLI
{
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZI_CA_VH_CUSTOMER', element: 'Customer' }}]
      @ObjectModel.text.element: ['CustName']
  key kunnr,
      _Customer.CustomerName as CustName,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt

}
