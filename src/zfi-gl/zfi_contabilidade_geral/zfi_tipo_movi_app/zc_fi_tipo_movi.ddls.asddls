@EndUserText.label: 'Tipo de Movimento'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_TIPO_MOVI
  as projection on ZI_FI_TIPO_MOVI
{

      @Consumption.valueHelpDefinition: [{
                     entity: { name: 'ZI_CA_VH_PLANCONTAS', element: 'ChartOfAccounts' } }]
      @ObjectModel.text.element: ['ChartOfAccountsName']
  key PlanContas,
      @ObjectModel.text.element: ['GLAccountName']
      @Consumption.valueHelpDefinition: [{
                     entity: { name: 'I_GLAccountText', element: 'GLAccount' } ,
                     additionalBinding: [{ localElement: 'PlanContas', element: 'ChartOfAccounts' }] }]
  key Conta,
      @ObjectModel.text.element: ['ChaveTxt']
      @Consumption.valueHelpDefinition: [{
                         entity: { name: 'ZI_CA_VH_SHKZG', element: 'DebitCreditCode' } }]
  key chaveLanc,
      @Consumption.valueHelpDefinition: [
          { entity:  { name:    'I_AccountingDocumentTypeStdVH', element: 'AccountingDocumentType' }    }]
      @ObjectModel.text.element: ['TpDocTxt']
  key TipoDoc,
      @Consumption.valueHelpDefinition: [{
                           entity: { name: 'ZI_CA_VH_BEWAR', element: 'Trtyp' } }]
      @ObjectModel.text.element: ['TpMovTxt']
  key TipoMov,
      ChartOfAccountsName,
      GLAccountName,
      ChaveTxt,
      TpMovTxt,
      TpDocTxt,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
