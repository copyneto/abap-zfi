@EndUserText.label: 'Proj. Forn agrupador'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_FORN_AGRUPADOR
  as projection on ZI_FI_FORN_AGRUPADOR
{

  key IdFornAgrupador,

      @Consumption.valueHelpDefinition: [{
        entity: {
              name: 'I_Supplier_VH',
              element: 'Supplier'
        }
      }]
      @ObjectModel.text.element: ['FornAgrupadorNome']
      FornAgrupador,

      @Consumption.valueHelpDefinition: [{
        entity: {
              name: 'ZI_CA_VH_COMPANY',
              element: 'CompanyCode'
        }
      }]
      @ObjectModel.text.element: ['CompanyCodeName']
      CompanyCode,

      @Consumption.valueHelpDefinition: [ {
        entity: {
            name: 'ZI_FI_VH_SAKNR_PC3C',
            element: 'GLAccount'
        }
      }]
      AccountNumber,

      @Consumption.valueHelpDefinition: [ {
         entity: {
            name: 'ZI_CA_VH_DOCTYPE',
            element: 'DocType'
            }
      }]
      @ObjectModel.text.element: ['DocTypeText']
      DocumentType,
      //      PercentualDesconto,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      FornAgrupadorNome,

      _Company.CompanyCodeName,

      //      _CostCenter.CostCenterName,

      DocTypeText,
      /* Associations */
      _Company,
      _Supplier,
      _DocType
}
