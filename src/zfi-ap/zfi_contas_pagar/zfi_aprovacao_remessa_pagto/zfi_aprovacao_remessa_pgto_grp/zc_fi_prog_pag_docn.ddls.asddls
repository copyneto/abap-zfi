@EndUserText.label: 'Itens'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_PROG_PAG_DOCN
  as projection on ZI_FI_PROG_PAG_DOCN
{
      @Consumption: { valueHelpDefinition: [{ entity: { name:    'C_CompanyCodeValueHelp', element: 'CompanyCode' } } ],
                                         filter: { mandatory: true, selectionType: #SINGLE } }
  key CompanyCode,
      @Consumption             : { filter: { mandatory: true, selectionType: #SINGLE } }
  key NetDueDate,
  key CashPlanningGroup,
  key Supplier,
  key PaymentDocument,
  key AccountingDocument,
  key AccountingDocumentItem,
  key FiscalYear,
      //@Aggregation.default: #SUM
      PaidAmountInPaytCurrency,
      PaymentCurrency,
      @Consumption             : { valueHelpDefinition: [{ entity: { name:    'ZI_FI_VH_TIPOREL', element: 'Value' } }],
                                   filter  : { mandatory: true, selectionType: #SINGLE } }
      RepType,
      //@Aggregation.default: #SUM
      OpenAmount,
      //@Aggregation.default: #SUM
      BlockedAmount,
      ItemStatus,
      HouseBank,
      PaymentMethod,
      CompanyCodeName,
      SupplierFullName,
      CashPlanningGroupName,
      RepTypeText,
      novogrptesouraria,
      /* Associations */
      _Company,
      _Planning,
      _RepType,
      _Supplier
}
