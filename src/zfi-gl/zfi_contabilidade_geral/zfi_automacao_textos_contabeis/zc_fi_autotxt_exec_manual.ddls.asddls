@EndUserText.label: 'Proj Autom. textos contábeis-Exec manual'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_AUTOTXT_EXEC_MANUAL
  as projection on ZI_FI_AUTOTXT_EXEC_MANUAL
{
  key Id,
      Jobname,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_VH_COMPANY', element: 'CompanyCode' } } ]
      @EndUserText.label: 'Empresa De'
      CompanyCodeStart,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_VH_COMPANY', element: 'CompanyCode' } } ]
      @EndUserText.label: 'Empresa Até'
      CompanyCodeEnd,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'C_CnsldtnFiscalYearVH', element: 'FiscalYear' } } ]
      @EndUserText.label: 'Exercício De'
      FiscalYearStart,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'C_CnsldtnFiscalYearVH', element: 'FiscalYear' } } ]
      @EndUserText.label: 'Exercício Até'
      FiscalYearEnd,
      @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
      @Semantics.dateTime: true
      PostingDateStart,
      @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
      @Semantics.dateTime: true
      PostingDateEnd,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      CreatedAt,
      @Semantics.user.lastChangedBy: true
      LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      @EndUserText.label: 'Confirma nova execução do Job?'
      ExecutaJob

}
