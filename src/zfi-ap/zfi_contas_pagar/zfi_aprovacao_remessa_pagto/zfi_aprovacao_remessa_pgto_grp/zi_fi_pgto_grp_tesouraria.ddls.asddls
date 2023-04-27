@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Interface - Pagamento por grupo de tesouraria'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
} 
define root view entity ZI_FI_PGTO_GRP_TESOURARIA
  as select from ZI_FI_PROG_PAGAMENTO_GRP2 as _Pgto

  association [1..1] to I_CompanyCode       as _Company  on  $projection.CompanyCode = _Company.CompanyCode
  //  association [1..1] to I_Supplier          as _Supplier on  $projection.Supplier = _Supplier.Supplier
  association [0..1] to I_PlanningGroupText as _Fdgrv    on  $projection.CashPlanningGroup = _Fdgrv.CashPlanningGroup
                                                         and _Fdgrv.Language               = $session.system_language
  association [1..1] to ZI_FI_VH_TIPOREL    as _TipoRel  on  $projection.RepType = _TipoRel.Value
  association [1..1] to I_Currency          as _Currency on  $projection.PaymentCurrency = _Currency.Currency

{
      @ObjectModel.text.element: ['CompanyCodeName']
  key _Pgto.CompanyCode,
  key _Pgto.NetDueDate,
  key _Pgto.RunHourTo,
      @ObjectModel.text.element: ['CashPlanningGroupName']
      @ObjectModel.foreignKey.association: '_Fdgrv'
  key _Pgto.CashPlanningGroup,
      @ObjectModel.text.element: ['RepTypeText']
      @ObjectModel.foreignKey.association: '_TipoRel'
  key _Pgto.RepType,
  key _Pgto.PaymentRunID,  
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      _Pgto.PaidAmountInPaytCurrency,

      @ObjectModel.foreignKey.association: '_Currency'
      _Pgto.PaymentCurrency,

      //      _Pgto.Runhour,
      //      _Pgto.DownloadDate,
      //      _Pgto.PaymentRunDate,
      //      _Pgto.PaymentRunID,
      //      _Pgto.PaymentRunIsProposal,
      //
      //
      //      @ObjectModel.text.element: ['BankName']
      //      @ObjectModel.foreignKey.association: '_Bank'
      //      _Pgto.Bank,
      //
      //      @ObjectModel.text.element: ['PaymentMethodName']
      //      @ObjectModel.foreignKey.association: '_PmntMtd'
      //      _Pgto.PaymentMethod,
      //      @ObjectModel.foreignKey.association: '_Currency'
      //      OpenCurrency,
      //      @ObjectModel.foreignKey.association: '_Currency'
      //      BloqCurrency,

      @Semantics.amount.currencyCode: 'PaymentCurrency'
      OpenAmount,

      @Semantics.amount.currencyCode: 'PaymentCurrency'
      BlockedAmount,

      @ObjectModel.text.element: ['encerradortext']
      encerrador,
      encerradorcrit,
      encerradortext,
      @ObjectModel.text.element: ['aprov1text']
      aprov1,
      aprov1crit,
      aprov1text,
      @ObjectModel.text.element: ['aprov2text']
      aprov2,
      aprov2crit,
      aprov2text,
      @ObjectModel.text.element: ['aprov3text']
      aprov3,
      aprov3crit,
      aprov3text,

      _Company.CompanyCodeName,
      //      _Supplier.SupplierFullName,
      _Fdgrv.CashPlanningGroupName,
      _TipoRel.Text as RepTypeText,

      $session.user as Username,

      //      _Bank.BancoEmpresaText      as BankName,
      //      _PmntMtd.FormaPagamentoText as PaymentMethodName,

      _Company,
      //      _Supplier,
      _Fdgrv,
      _TipoRel,
      //      _Bank,
      //      _PmntMtd,
      _Currency
}
