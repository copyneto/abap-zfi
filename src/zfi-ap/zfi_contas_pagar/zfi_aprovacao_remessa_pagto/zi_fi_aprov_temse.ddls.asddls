@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS Regut'
define root view entity ZI_FI_APROV_TEMSE
  as select from ZC_FI_PROG_PAGAMENTO as _Pgto
  association [1..1] to I_CompanyCode       as _Company  on  $projection.CompanyCode = _Company.CompanyCode
  association [0..1] to I_PlanningGroupText as _Fdgrv    on  $projection.CashPlanningGroup = _Fdgrv.CashPlanningGroup
                                                         and _Fdgrv.Language               = $session.system_language
  association [1..1] to ZI_FI_VH_TIPOREL    as _TipoRel  on  $projection.RepType = _TipoRel.Value
  association [1..1] to I_Currency          as _Currency on  $projection.PaymentCurrency = _Currency.Currency

  //  composition [0..*] of ZI_FI_PROG_PAG_DOC_ITEM as _Itens

{
      @ObjectModel.text.element: ['CompanyCodeName']
  key _Pgto.CompanyCode,
  key NetDueDate,
      @ObjectModel.text.element: ['CashPlanningGroupName']
  key _Pgto.CashPlanningGroup,
      @ObjectModel.text.element: ['RepTypeText']
  key _Pgto.RepType,
      PaymentRunID,
      RunHourTo,
      // @ObjectModel.text.element: ['SupplierFullName']
      // key ''                                   as Supplier,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      _Pgto.PaidAmountInPaytCurrency,
      @ObjectModel.foreignKey.association: '_Currency'
      _Pgto.PaymentCurrency,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      _Pgto.OpenAmount,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      _Pgto.BlockedAmount,
      @ObjectModel.text.element: ['encerradortext']
      _Pgto.encerrador,
      _Pgto.encerradorcrit,
      _Pgto.encerradortext,
      @ObjectModel.text.element: ['aprov1text']
      _Pgto.aprov1,
      _Pgto.aprov1crit,
      _Pgto.aprov1text,
      @ObjectModel.text.element: ['aprov2text']
      _Pgto.aprov2,
      _Pgto.aprov2crit,
      _Pgto.aprov2text,
      @ObjectModel.text.element: ['aprov3text']
      _Pgto.aprov3,
      _Pgto.aprov3crit,
      _Pgto.aprov3text,

      _Pgto.Username,
      _Pgto.Userlevel,
      _Pgto.NivelAtual,

      _Company.CompanyCodeName,
      _Fdgrv.CashPlanningGroupName,
      _TipoRel.Text as RepTypeText,

      _Company,
      _Fdgrv,
      _TipoRel,
      _Currency
      //      _Itens
}
