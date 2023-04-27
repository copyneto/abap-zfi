@EndUserText.label: 'Config. conta pagto p/ diferença DDA'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: ['CompanyCode']
define root view entity ZC_FI_CONTA_DDA
  as projection on ZI_FI_CONTA_DDA
{
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZI_CA_VH_COMPANY',
              element: 'CompanyCode'
          }
      }]
      @ObjectModel.text.element: ['CompanyName']
  key CompanyCode,
      ValorTolerancia,
      ContaLow,
      ContaHig,
      DataTolerancia,
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZI_CA_VH_FORMA_PAGTO',
              element: 'FormaPagtoId'
          }
      }]
      PaymentMethod,
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZI_CA_VH_DOCTYPE',
              element: 'DocType'
          }
      }]
      DocumentType,
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZI_CA_VH_KOSTL',
              element: 'CentroCusto'
          }
      }]
      @ObjectModel.text.element: ['DescCentroCusto']
      CentroCusto,
      DescCentroCusto,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      Moeda,
      CompanyName,
      /* Associations */
      _Empresas
}
