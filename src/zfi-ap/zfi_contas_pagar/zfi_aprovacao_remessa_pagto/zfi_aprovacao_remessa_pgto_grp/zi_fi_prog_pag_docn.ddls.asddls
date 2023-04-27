@EndUserText.label: 'Itens'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZI_FI_PROG_PAG_DOCN
  as select from ZI_FI_PROG_PAG_DOC_Itens
{
  key CompanyCode,
  key NetDueDate,
  key CashPlanningGroup,
  key Supplier,
  key PaymentDocument,
  key AccountingDocument,
  key AccountingDocumentItem,
  key FiscalYear,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      PaidAmountInPaytCurrency,
      PaymentCurrency,
      RepType,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      OpenAmount,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      BlockedAmount,
      ItemStatus,
      HouseBank,
      PaymentMethod,
      CompanyCodeName,
      SupplierFullName,
      CashPlanningGroupName,
      RepTypeText,
      cast( '' as fdgrv ) as novogrptesouraria,
      /* Associations */
      _Company,
      _Planning,
      _RepType,
      _Supplier
}
