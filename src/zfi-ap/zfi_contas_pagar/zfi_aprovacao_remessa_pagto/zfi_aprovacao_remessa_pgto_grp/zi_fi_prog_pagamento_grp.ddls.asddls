@AbapCatalog.sqlViewName: 'ZVPRGPGTOGRP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Programa de pagamento'
define view ZI_FI_PROG_PAGAMENTO_GRP
  as select from ZI_FI_PROG_PAGAMENTO_P         as _Pgto
    inner join   ZI_FI_PGTO_BCOEMP_OVERALL_STAT as _Stat on  _Pgto.NetDueDate    = _Stat.NetDueDate
                                                         and _Pgto.HouseBank     = _Stat.HouseBank
                                                         and _Pgto.PaymentMethod = _Stat.PaymentMethod
  //    inner join            regut                  as _Regut on  _Pgto.CompanyCode = _Regut.zbukr
  //                                                           and _Pgto.NetDueDate  = _Regut.laufd
  //    inner join            regup                  as _Regup on  _Regut.zbukr = _Regup.zbukr
  //                                                           and _Regut.laufd = _Regup.laufd
  //                                                           and _Regut.laufi = _Regup.laufi
  //                                                           and _Regut.xvorl = _Regup.xvorl
  //    inner join            reguh                  as _Reguh on  _Reguh.laufd = _Regup.laufd
  //                                                           and _Reguh.laufi = _Regup.laufi
  //                                                           and _Reguh.xvorl = _Regup.xvorl
  //                                                           and _Reguh.zbukr = _Regup.zbukr
  //                                                           and _Reguh.lifnr = _Regup.lifnr
  //                                                           and _Reguh.kunnr = _Regup.kunnr
  //                                                           and _Reguh.empfg = _Regup.empfg
  //                                                           and _Reguh.vblnr = _Regup.vblnr
{
  key _Pgto.CompanyCode,
  key _Pgto.NetDueDate,
  key _Pgto.RunHourTo,
  key _Pgto.RepType,
  key _Pgto.CashPlanningGroup,
      _Pgto.Supplier,
      @Semantics.amount.currencyCode: 'paymentcurrency'
      _Pgto.PaidAmountInPaytCurrency,
      _Pgto.PaymentCurrency,
      @Semantics.amount.currencyCode: 'paymentcurrency'
      _Pgto.OpenAmount,
      @Semantics.amount.currencyCode: 'paymentcurrency'
      _Pgto.BlockedAmount,
      _Pgto.HouseBank                                       as Bank,
      _Pgto.PaymentMethod,

      cast( _Stat.Status as ukm_stat_exposure_criticality ) as Status,
      case _Stat.Status
        when 2
          then 'Em Andamento'
        when 3
          then 'Aprovado'
        else
               'Pendente'
      end                                                   as StatusText

}

//    inner join            I_PaymentProposalHeader        as _Payment  on  _Payment.PayingCompanyCode    = _Regut.zbukr
//                                                                      and _Payment.PaymentRunDate       = _Regut.laufd
//                                                                      and _Payment.PaymentRunID         = _Regut.laufi
//                                                                      and _Payment.PaymentRunIsProposal = _Regut.xvorl
//                                                                      and _Payment.PaymentOrigin        = _Regut.grpno
//                                                                      and _Payment.PaymentRunIsProposal = 'X'
//
//    inner join            I_CompanyCode                  as _Bukrs    on _Bukrs.CompanyCode = _Payment.PayingCompanyCode
//
//    inner join            I_SupplierCompany              as _Supplier on  _Supplier.Supplier    = _Payment.Supplier
//                                                                      and _Supplier.CompanyCode = _Payment.PayingCompanyCode
//
//    left outer join       ZI_FI_APROV_NIVEL_S_USER_VALID as _Nivel    on  _Supplier.CompanyCode       = _Nivel.bukrs
//                                                                      and _Supplier.CashPlanningGroup = _Nivel.fdgrv
//                                                                      and _Regup.zfbdt                = _Nivel.data
//
//    left outer join       ZC_FI_APROV_BSIK               as _bsik     on  _Supplier.Supplier    = _bsik.lifnr
//                                                                      and _Supplier.CompanyCode = _bsik.bukrs
//{
//  key _Payment.PayingCompanyCode                                     as CompanyCode,
//  key _Supplier.Supplier,
//  key case when _bsik.Fdgrv = ''
//           then _Supplier.CashPlanningGroup
//           else ''
//      end                                                            as CashPlanningGroup,
//      @Semantics.amount.currencyCode: 'paymentcurrency'
//      //      abs(_Payment.PaidAmountInPaytCurrency)                         as PaidAmountInPaytCurrency,
//      _Payment.PaidAmountInPaytCurrency                              as PaidAmountInPaytCurrency,
//      @Semantics.currencyCode  :true
//      _Regut.waers                                                   as PaymentCurrency,
//      _Regut.tstim                                                   as Runhour,
//      _Regut.dwdat                                                   as DownloadDate,
//      _Payment.PaymentRunDate,
//      _Payment.PaymentRunID,
//      _Payment.PaymentRunIsProposal,
//      _Reguh.hbkid                                                   as Bank,
//      _Reguh.rzawe                                                   as PaymentMethod,
//      case when _Regut.laufd > _Regut.tsdat then 'P'
//           when _Regut.laufd = _Regut.tsdat then 'E'
//           else ''
//      end                                                            as RepType,
//      //      _Regup.zfbdt                                                   as NetDueDate,
//      _Regup.laufd                                                   as NetDueDate,
//
//      @Semantics.currencyCode: true
//      coalesce( _bsik.waers, _Regut.waers )                          as OpenCurrency,
//      @Semantics.currencyCode: true
//      coalesce( _bsik.waers, _Regut.waers )                          as BloqCurrency,
//
//      @Semantics.amount.currencyCode: 'OpenCurrency'
//      case when _bsik.zlspr = 'X'
//           then cast( coalesce( _bsik.dmbtr, 0 ) as dmbtr )
//           else cast( 0 as dmbtr )
//       end                                                           as OpenAmount,
//
//      @Semantics.amount.currencyCode: 'BloqCurrency'
//      case when _bsik.zlspr = 'X'
//           then cast( coalesce( _bsik.dmbtr, 0 ) as dmbtr )
//           else cast( 0 as dmbtr )
//       end                                                           as BlockedAmount,
//
//      cast( _Nivel.encerrador as ze_aprov )                          as encerrador,
//      cast( _Nivel.encerradorcrit as ukm_stat_exposure_criticality ) as encerradorcrit,
//      cast( _Nivel.encerradortext as text10 )                        as encerradortext,
//      cast( _Nivel.aprov1 as ze_aprov )                              as aprov1,
//      cast( _Nivel.aprov1crit as ukm_stat_exposure_criticality )     as aprov1crit,
//      cast( _Nivel.aprov1text as text10 )                            as aprov1text,
//      cast( _Nivel.aprov2 as ze_aprov )                              as aprov2,
//      cast( _Nivel.aprov2crit as ukm_stat_exposure_criticality )     as aprov2crit,
//      cast( _Nivel.aprov2text as text10 )                            as aprov2text,
//      cast( _Nivel.aprov3 as ze_aprov )                              as aprov3,
//      cast( _Nivel.aprov3crit as ukm_stat_exposure_criticality )     as aprov3crit,
//      cast( _Nivel.aprov3text as text10 )                            as aprov3text
//}
