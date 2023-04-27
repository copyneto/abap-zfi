@AbapCatalog.sqlViewName: 'ZVPRGPGTOP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Aprovação de Contas a Pagar'
define view ZI_FI_PROG_PAGAMENTO_P
  as select distinct from ZI_FI_PROG_PAGAMENTO as _Payment
  left outer join  zi_fi_log_apv_pgt as _Log on    _Payment.CompanyCode       = _Log.Bukrs
                                               and _Payment.NetDueDate        = _Log.Data
//                                               and _Payment.RunHourTo         = _Log.Hora
//                                               and _Payment.dataConv         = _Log.dataConv
                                               and _Payment.CashPlanningGroup = _Log.Fdgrv
                                               and _Payment.RepType           = _Log.Tiporel
                                               
                                               
//  association [1] to zi_fi_log_apv_pgt as _Log on  _Payment.CompanyCode       = _Log.Bukrs
//                                               and _Payment.NetDueDate        = _Log.Data
//                                               and _Payment.RunHourTo         = _Log.Hora
//                                               and _Payment.CashPlanningGroup = _Log.Fdgrv
//                                               and _Payment.RepType           = _Log.Tiporel
{
  key CompanyCode,
  key _Payment.PaymentRunID,
      @Semantics.businessDate.at: true
  key _Payment.NetDueDate,
      @Semantics.time: true
  key _Payment.RunHourTo,
  key _Payment.CashPlanningGroup,
  key _Payment.Supplier,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      PaidAmountInPaytCurrency,
      @Semantics.currencyCode: true
      PaymentCurrency,
      RepType,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      OpenAmount,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      BlockedAmount,
      coalesce( _Log.NivelAtual, '0' )                      as NivelAtual,

      cast( coalesce( _Log.Encerrador, '' ) as ze_aprov_1 ) as encerrador,

      cast(
        case coalesce( _Log.Encerrador, '' )
          when 'X'
            then 3
          else 0
        end as ukm_stat_exposure_criticality )              as encerradorcrit,

      cast(
        case coalesce( _Log.Encerrador, '' )
          when 'X'
            then 'Aprovado'
          else 'Pendente'
        end as text10 )                                     as encerradortext,

      cast( coalesce( _Log.Aprov1, '' ) as ze_aprov_2 )     as aprov1,

      cast(
        case coalesce( _Log.Aprov1, '' )
          when 'X'
            then 3
          else 0
        end as ukm_stat_exposure_criticality )              as aprov1crit,

      cast(
        case coalesce( _Log.Aprov1, '' )
          when 'X'
            then 'Aprovado'
          else 'Pendente'
        end as text10 )                                     as aprov1text,

      cast( coalesce( _Log.Aprov2, '' ) as ze_aprov_3 )     as aprov2,

      cast(
        case coalesce( _Log.Aprov2, '' )
          when 'X'
            then 3
          else 0
        end as ukm_stat_exposure_criticality )              as aprov2crit,

      cast(
        case coalesce( _Log.Aprov2, '' )
          when 'X'
            then 'Aprovado'
          else 'Pendente' end as text10 )                   as aprov2text,

      cast( coalesce( _Log.Aprov3, '' ) as ze_aprov_4 )     as aprov3,

      cast(
        case coalesce( _Log.Aprov3, '' )
          when 'X'
            then 3
          else 0 end as ukm_stat_exposure_criticality )     as aprov3crit,

      cast(
        case coalesce( _Log.Aprov3, '' )
          when 'X'
            then 'Aprovado'
          else 'Pendente' end as text10 )                   as aprov3text,

      _Payment.HouseBank,
      _Payment.PaymentMethod,
      _Payment.PaymentBlockingReason,

      _Payment.AccountingDocumentItem,
      _Payment.PaymentDocument,
      _Payment.AccountingDocument,
      _Payment.FiscalYear,
      Bstat,
      Umskz,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      _Payment.Amount,
      DocType,
      Branch,
      Reference
}
