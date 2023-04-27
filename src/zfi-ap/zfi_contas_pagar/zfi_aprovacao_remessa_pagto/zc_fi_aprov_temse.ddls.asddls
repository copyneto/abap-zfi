@EndUserText.label: 'Aprovação de Contas a Pagar'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_APROV_TEMSE
  as projection on ZI_FI_APROV_TEMSE as _TemSe
  association [1..*] to ZC_FI_PROG_PAG_DOC_ITENS as _Itens on  _Itens.CompanyCode       = $projection.CompanyCode
  //                                                           and _Itens.PaymentRunID      = $projection.PaymentRunID
                                                           and _Itens.CashPlanningGroup = $projection.CashPlanningGroup
                                                           and _Itens.NetDueDate        = $projection.NetDueDate
  //                                                           and _Itens.RunHourTo         = $projection.RunHourTo
                                                           and _Itens.RepType           = $projection.RepType
  //  association [1..*] to ZC_FI_PROG_PAG_DOCN as _DocItens on  _DocItens.CompanyCode       = $projection.CompanyCode
  //and _DocItens.Supplier          = $projection.supplier
  //                                                         and _DocItens.CashPlanningGroup = $projection.CashPlanningGroup
  //                                                         and _DocItens.NetDueDate        = $projection.NetDueDate
{
  key _TemSe.CompanyCode,
  key _TemSe.NetDueDate,
  key _TemSe.CashPlanningGroup,
  key _TemSe.RepType,
      _TemSe.PaymentRunID,
      _TemSe.RunHourTo,
      @Aggregation.default: #SUM
      _TemSe.PaidAmountInPaytCurrency,
      _TemSe.PaymentCurrency,
      @Aggregation.default: #SUM
      _TemSe.OpenAmount,
      @Aggregation.default: #SUM
      _TemSe.BlockedAmount,
      _TemSe.encerrador,
      _TemSe.encerradorcrit,
      _TemSe.encerradortext,
      _TemSe.aprov1,
      _TemSe.aprov1crit,
      _TemSe.aprov1text,
      _TemSe.aprov2,
      _TemSe.aprov2crit,
      _TemSe.aprov2text,
      _TemSe.aprov3,
      _TemSe.aprov3crit,
      _TemSe.aprov3text,
      _TemSe.Username,
      _TemSe.Userlevel,
      _TemSe.NivelAtual,
      _TemSe.CompanyCodeName,
      _TemSe.CashPlanningGroupName,
      _TemSe.RepTypeText,
      /* Associations */
      _TemSe._Company,
      _TemSe._Currency,
      _TemSe._Fdgrv,
      _TemSe._TipoRel,
      _Itens //: redirected to composition child ZC_FI_PROG_PAG_DOC_ITEM
}
