@AbapCatalog.sqlViewName: 'ZVPROGPAGITMS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Itens'
@Metadata.allowExtensions: true
define view ZC_FI_PROG_PAG_DOC_ITENS
  as select from ZI_FI_PROG_PAG_DOC_Itens
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
      case ItemStatus
            when 3
             then   'P'
            when 2
            then    'O'
            else 'B' end as tipo,
      //      NivelAtual,
      //      encerrador,
      //      encerradorcrit,
      //      encerradortext,
      //      aprov1,
      //      aprov1crit,
      //      aprov1text,
      //      aprov2,
      //      aprov2crit,
      //      aprov2text,
      //      aprov3,
      //      aprov3crit,
      //      aprov3text,
      HouseBank,
      PaymentMethod,
      Bstat,
      Umskz,
      @Aggregation.default: #SUM
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
      _Company,
      _Planning,
      _RepType,
      _Supplier,
      _DocType,
      _Branch,
      _Bank,
      _PmntMtd
}
