@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Item'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_PROG_PAG_DOC_ITEM
  as select from ZC_FI_PROG_PAG_DOC_ITENS
  association to parent ZI_FI_APROV_TEMSE as _Docs on  _Docs.CompanyCode       = $projection.CompanyCode
  //                                                   and _Docs.PaymentRunID      = $projection.PaymentRunID
                                                   and _Docs.CashPlanningGroup = $projection.CashPlanningGroup
                                                   and _Docs.NetDueDate        = $projection.NetDueDate
  //                                                   and _Docs.RunHourTo         = $projection.RunHourTo
                                                   and _Docs.RepType           = $projection.RepType
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
      _Docs
}
