@AbapCatalog.sqlViewName: 'ZVPROGPGTO'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Programa de pagamento'
define view ZC_FI_PROG_PAGAMENTO
  as select from    ZI_FI_PROG_PAGAMENTO_P as _Pgto
    left outer join ZI_FI_APROV_NIVEL      as _Nivel on  _Pgto.CompanyCode = _Nivel.bukrs
                                                     and _Nivel.uname      = $session.user
{
  key CompanyCode,
  key max(PaymentRunID)                                as PaymentRunID,
  key NetDueDate,
  key max(RunHourTo)                                   as RunHourTo,
  key CashPlanningGroup,
      //    Supplier,

      @Semantics.amount.currencyCode: 'PaymentCurrency'
      cast( sum( PaidAmountInPaytCurrency ) as rwbtr ) as PaidAmountInPaytCurrency,
      PaymentCurrency,
      RepType,

      _Nivel.uname                                     as Username,
      _Nivel.nivel                                     as Userlevel,

      @Semantics.amount.currencyCode: 'PaymentCurrency'
      cast( sum( OpenAmount ) as ze_aberto )           as OpenAmount,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      cast( sum( BlockedAmount ) as ze_bloqueado )     as BlockedAmount,

      _Pgto.NivelAtual,
      _Pgto.encerrador,
      _Pgto.encerradorcrit,
      _Pgto.encerradortext,
      _Pgto.aprov1,
      _Pgto.aprov1crit,
      _Pgto.aprov1text,
      _Pgto.aprov2,
      _Pgto.aprov2crit,
      _Pgto.aprov2text,
      _Pgto.aprov3,
      _Pgto.aprov3crit,
      _Pgto.aprov3text
}
//where
//  NivelAtual = _Nivel.nivel
group by
  CompanyCode,
  //  PaymentRunID,
  NetDueDate,
  //  RunHourTo,
  CashPlanningGroup,
  //  Supplier,
  PaymentCurrency,
  RepType,
  uname,
  nivel,
  _Pgto.NivelAtual,
  _Pgto.encerrador,
  _Pgto.encerradorcrit,
  _Pgto.encerradortext,
  _Pgto.aprov1,
  _Pgto.aprov1crit,
  _Pgto.aprov1text,
  _Pgto.aprov2,
  _Pgto.aprov2crit,
  _Pgto.aprov2text,
  _Pgto.aprov3,
  _Pgto.aprov3crit,
  _Pgto.aprov3text
