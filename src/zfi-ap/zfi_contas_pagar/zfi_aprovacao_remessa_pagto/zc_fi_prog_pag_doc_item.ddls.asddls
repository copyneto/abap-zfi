@EndUserText.label: 'Item'
@AccessControl.authorizationCheck: #CHECK
define view entity ZC_FI_PROG_PAG_DOC_ITEM
  as projection on ZI_FI_PROG_PAG_DOC_ITEM
{

  key CompanyCode,
  key CashPlanningGroup,
  key NetDueDate,
  key RepType,
  key Supplier,
  key PaymentDocument,
  key AccountingDocument,
  key AccountingDocumentItem,
  key FiscalYear,
      PaymentRunID,
      RunHourTo,
      PaidAmountInPaytCurrency,
      OpenAmount,
      BlockedAmount,
      PaymentCurrency,
      ItemStatus,
      tipo,
      HouseBank,
      PaymentMethod,
      Bstat,
      Amount,
      DocType,
      Branch,
      Reference,
      CompanyCodeName,
      SupplierFullName,
      CashPlanningGroupName,
      RepTypeText,
      DocTypeText,
      BranchText,
      HouseBankText,
      FormaPagamentoText,
      /* Associations */
      _Bank,
      _Branch,
      _Company,
      _DocType,
      _Planning,
      _PmntMtd,
      _RepType,
      _Supplier,

      _Docs : redirected to parent ZC_FI_APROV_TEMSE
}
