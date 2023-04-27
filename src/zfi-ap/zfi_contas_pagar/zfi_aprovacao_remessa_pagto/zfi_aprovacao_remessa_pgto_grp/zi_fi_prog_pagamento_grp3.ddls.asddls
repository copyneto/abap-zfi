@AbapCatalog.sqlViewName: 'ZVPRGPGTOGRP3'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Interface - Programa pagamento'
define view ZI_FI_PROG_PAGAMENTO_GRP3
  as select from ZI_FI_PROG_PAGAMENTO_P as _Pgto
  //    inner join   ZI_FI_APROV_NIVEL      as _Nivel on  _Pgto.CompanyCode = _Nivel.bukrs
  //                                                  and _Nivel.uname      = $session.user
{
  key CompanyCode,
  key NetDueDate,
  key RunHourTo,
  key CashPlanningGroup,
  key RepType,
  key PaymentRunID,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      cast( sum( PaidAmountInPaytCurrency ) as rwbtr ) as PaidAmountInPaytCurrency,
      PaymentCurrency,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      cast( sum( OpenAmount ) as ze_aberto )           as OpenAmount,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      cast( sum( BlockedAmount ) as ze_bloqueado )     as BlockedAmount,

      //      _Pgto.NivelAtual,
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
      _Pgto.aprov3text,

      $session.user                                    as Username
}
group by
  CompanyCode,
  NetDueDate,
  RunHourTo,
  CashPlanningGroup,
  RepType,
  PaymentRunID,
  PaymentCurrency,
  //  _Pgto.NivelAtual,
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

//  I_PaymentProposalHeader        as _Payment
//
//    inner join            regut                          as _Regut    on  _Payment.PayingCompanyCode    = _Regut.zbukr
//                                                                      and _Payment.PaymentRunDate       = _Regut.laufd
//                                                                      and _Payment.PaymentRunID         = _Regut.laufi
//                                                                      and _Payment.PaymentRunIsProposal = _Regut.xvorl
//
//    inner join            I_CompanyCode                  as _Bukrs    on _Bukrs.CompanyCode = _Payment.PayingCompanyCode
//
//    inner join            I_SupplierCompany              as _Supplier on  _Supplier.Supplier    = _Payment.Supplier
//                                                                      and _Supplier.CompanyCode = _Payment.PayingCompanyCode
//
//    inner join            ZI_FI_APROV_NIVEL_S_USER_VALID as _Nivel    on  _Supplier.CompanyCode       = _Nivel.bukrs
//                                                                      and _Supplier.CashPlanningGroup = _Nivel.fdgrv
//  //                                                                      and _Payment.PaymentRunDate     = _Nivel.data
//{
//  key _Payment.PayingCompanyCode                                                    as CompanyCode,
//  key _Supplier.Supplier,
//  key _Supplier.CashPlanningGroup,
//      cast( abs( _Payment.PaidAmountInPaytCurrency ) as rwbtr )                     as PaidAmountInPaytCurrency,
//
//      _Payment.PaymentCurrency,
//
//      cast( _Regut.laufd as netdt )                                                 as NetDueDate,
//
//      _Regut.dwdat                                                                  as DownloadDate,
//
//      cast( case when _Regut.laufd > _Regut.tsdat then 'P'
//                 when _Regut.laufd = _Regut.tsdat then 'E'
//                 else ''
//             end
//      as ze_tiporel )                                                               as RepType,
//
//      cast( 0 as dmbtr )                                                            as OpenAmount,
//
//      cast( 0 as dmbtr )                                                            as BlockedAmount,
//
//      cast( coalesce( _Nivel.encerrador, '' ) as ze_aprov_1 )                       as encerrador,
//      cast( coalesce( _Nivel.encerradorcrit, 0 ) as ukm_stat_exposure_criticality ) as encerradorcrit,
//      cast( coalesce( _Nivel.encerradortext, 'Pendente' ) as text10 )               as encerradortext,
//      cast( coalesce( _Nivel.aprov1, '' ) as ze_aprov_2 )                           as aprov1,
//      cast( coalesce( _Nivel.aprov1crit, 0 ) as ukm_stat_exposure_criticality )     as aprov1crit,
//      cast( coalesce( _Nivel.aprov1text, 'Pendente' ) as text10 )                   as aprov1text,
//      cast( coalesce( _Nivel.aprov2, '' ) as ze_aprov_3 )                           as aprov2,
//      cast( coalesce( _Nivel.aprov2crit, 0 ) as ukm_stat_exposure_criticality )     as aprov2crit,
//      cast( coalesce( _Nivel.aprov2text, 'Pendente' ) as text10 )                   as aprov2text,
//      cast( coalesce( _Nivel.aprov3, '' ) as ze_aprov_4 )                           as aprov3,
//      cast( coalesce( _Nivel.aprov3crit, 0 ) as ukm_stat_exposure_criticality )     as aprov3crit,
//      cast( coalesce( _Nivel.aprov3text, 'Pendente' ) as text10 )                   as aprov3text
//}
//where
//  _Payment.PaymentMethod <> 'G'
//union select distinct from ZC_FI_APROV_BSIK               as _bsik
//
//  inner join               I_CompanyCode                  as _Bukrs    on _Bukrs.CompanyCode = _bsik.bukrs
//
//  inner join               I_SupplierCompany              as _Supplier on  _Supplier.Supplier    = _bsik.lifnr
//                                                                       and _Supplier.CompanyCode = _bsik.bukrs
//
//  inner join               ZI_FI_APROV_NIVEL_S_USER_VALID as _Nivel    on  _Supplier.CompanyCode       = _Nivel.bukrs
//                                                                       and _Supplier.CashPlanningGroup = _Nivel.fdgrv
////                                                          and _bsik.laufd                 = _Nivel.Data
//
//{
//  key _bsik.bukrs                                                                   as CompanyCode,
//  key _Supplier.Supplier,
//  key case when _bsik.Fdgrv <> _Supplier.CashPlanningGroup
//           then _bsik.Fdgrv
//           else _Supplier.CashPlanningGroup
//      end                                                                           as CashPlanningGroup,
//
//      cast( 0 as rwbtr )                                                            as PaidAmountInPaytCurrency,
//
//      _Supplier.Currency                                                            as PaymentCurrency,
//
//      cast( _bsik.laufd as netdt )                                                  as NetDueDate,
//
//      cast( '' as dodat )                                                           as DownloadDate,
//
//      cast( 'P' as ze_tiporel )                                                     as RepType,
//
//      cast(
//        case coalesce( _bsik.zlspr, '' )
//          when ''
//            then abs( coalesce( _bsik.dmbtr, 0 ) )
//          else 0
//        end
//      as dmbtr )                                                                    as OpenAmount,
//
//      cast(
//        case coalesce( _bsik.zlspr, '' )
//          when ''
//            then 0
//          else abs( coalesce( _bsik.dmbtr, 0 ) )
//        end
//      as dmbtr )                                                                    as BlockedAmount,
//
//      cast( coalesce( _Nivel.encerrador, '' ) as ze_aprov_1 )                       as encerrador,
//      cast( coalesce( _Nivel.encerradorcrit, 0 ) as ukm_stat_exposure_criticality ) as encerradorcrit,
//      cast( coalesce( _Nivel.encerradortext, 'Pendente' ) as text10 )               as encerradortext,
//      cast( coalesce( _Nivel.aprov1, '' ) as ze_aprov_2 )                           as aprov1,
//      cast( coalesce( _Nivel.aprov1crit, 0 ) as ukm_stat_exposure_criticality )     as aprov1crit,
//      cast( coalesce( _Nivel.aprov1text, 'Pendente' ) as text10 )                   as aprov1text,
//      cast( coalesce( _Nivel.aprov2, '' ) as ze_aprov_3 )                           as aprov2,
//      cast( coalesce( _Nivel.aprov2crit, 0 ) as ukm_stat_exposure_criticality )     as aprov2crit,
//      cast( coalesce( _Nivel.aprov2text, 'Pendente' ) as text10 )                   as aprov2text,
//      cast( coalesce( _Nivel.aprov3, '' ) as ze_aprov_4 )                           as aprov3,
//      cast( coalesce( _Nivel.aprov3crit, 0 ) as ukm_stat_exposure_criticality )     as aprov3crit,
//      cast( coalesce( _Nivel.aprov3text, 'Pendente' ) as text10 )                   as aprov3text
//}
