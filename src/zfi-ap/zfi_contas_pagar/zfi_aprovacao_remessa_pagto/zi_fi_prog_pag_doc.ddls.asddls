@AbapCatalog.sqlViewName: 'ZVPRGPGDC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Programa de pagamento Pagamento'
define view ZI_FI_PROG_PAG_DOC
  as select distinct from ZI_FI_PROG_PAGAMENTO_P as _Pgto
  //    left outer join       I_PaymentProposalItem  as _PaymentItem on  _PaymentItem.PayingCompanyCode = _Pgto.CompanyCode
  //                                                                 and _PaymentItem.PaymentRunID      = _Pgto.PaymentRunID
  //                                                                 and _PaymentItem.PaymentRunDate    = _Pgto.NetDueDate
  //  //                                                                 and _PaymentItem.Supplier          = _Pgto.Supplier

{
  key _Pgto.CompanyCode,
  key _Pgto.PaymentRunID,
  key _Pgto.CashPlanningGroup,
  key _Pgto.NetDueDate,
  key _Pgto.RunHourTo,
  key _Pgto.RepType,
  key _Pgto.Supplier,
  key _Pgto.PaymentDocument,
  key _Pgto.AccountingDocument,
  key _Pgto.AccountingDocumentItem,
  key _Pgto.FiscalYear,

      //  key _PaymentItem.PaymentDocument,
      //  key _PaymentItem.AccountingDocument,
      //  key _PaymentItem.AccountingDocumentItem,
      //  key _PaymentItem.FiscalYear,
      _Pgto.PaidAmountInPaytCurrency,
      _Pgto.PaymentCurrency,
      _Pgto.OpenAmount,
      _Pgto.BlockedAmount,
      //      _Pgto.NivelAtual,
      //      _Pgto.encerrador,
      //      _Pgto.encerradorcrit,
      //      _Pgto.encerradortext,
      //      _Pgto.aprov1,
      //      _Pgto.aprov1crit,
      //      _Pgto.aprov1text,
      //      _Pgto.aprov2,
      //      _Pgto.aprov2crit,
      //      _Pgto.aprov2text,
      //      _Pgto.aprov3,
      //      _Pgto.aprov3crit,
      //      _Pgto.aprov3text,
      _Pgto.HouseBank,
      _Pgto.PaymentMethod,

      case when _Pgto.PaymentBlockingReason is not initial
           then 1
           else case when _Pgto.PaymentDocument is not initial
                     then 3
                     else 2
                end
      end as ItemStatus,
      Bstat,
      Umskz,
      Amount,
      DocType,
      Branch,
      Reference
}
