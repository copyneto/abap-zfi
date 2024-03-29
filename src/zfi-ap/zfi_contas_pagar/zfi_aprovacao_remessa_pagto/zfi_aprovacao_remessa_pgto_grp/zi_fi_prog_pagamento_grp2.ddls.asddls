@AbapCatalog.sqlViewName: 'ZVPRGPGTOGRP2'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Interface - Programa pagamento'
define view ZI_FI_PROG_PAGAMENTO_GRP2
  as select distinct from ZI_FI_PROG_PAGAMENTO_GRP3 as _Pgto

{
  key CompanyCode,
  key NetDueDate,
 // pferraz - 01.08.23 - ajustes relatorio por grupo de tesouraria - inicio
  key cast( '000000' as abap.tims )                    as RunHourTo,
      //  key RunHourTo,
  // pferraz - 01.08.23 - ajustes relatorio por grupo de tesouraria - fim      
  key CashPlanningGroup,
  key RepType,
 // pferraz - 01.08.23 - ajustes relatorio por grupo de tesouraria - inicio  
  key cast( '000000' as abap.char( 6 ) ) as PaymentRunID, 
//  key PaymentRunID,
 // pferraz - 01.08.23 - ajustes relatorio por grupo de tesouraria - fim
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      cast( sum( PaidAmountInPaytCurrency ) as rwbtr ) as PaidAmountInPaytCurrency,
      PaymentCurrency,
      //      DownloadDate,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      cast( sum( OpenAmount ) as ze_aberto )           as OpenAmount,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      cast( sum( BlockedAmount ) as ze_bloqueado )     as BlockedAmount,
      encerrador,
      encerradorcrit,
      encerradortext,
      aprov1,
      aprov1crit,
      aprov1text,
      aprov2,
      aprov2crit,
      aprov2text,
      aprov3,
      aprov3crit,
      aprov3text
}
group by
  CompanyCode,
  NetDueDate,
  RunHourTo,
  CashPlanningGroup,
  RepType,
  PaymentRunID,
  PaymentCurrency,
  encerrador,
  encerradorcrit,
  encerradortext,
  aprov1,
  aprov1crit,
  aprov1text,
  aprov2,
  aprov2crit,
  aprov2text,
  aprov3,
  aprov3crit,
  aprov3text
