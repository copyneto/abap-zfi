@AbapCatalog.sqlViewName: 'ZVFIAPRVBSIK'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'BSIK Docs'
define view ZC_FI_APROV_BSIK
  as select distinct from ZI_FI_APROV_BSIK
{
  key laufd,
  key lauhr,
  key bukrs,
  key lifnr,
  key gjahr,
  key augbl,
  key belnr,
  key buzei,
      //      Fdgrv,
      @Semantics.amount.currencyCode: 'waers'
      dmbtr,
      waers,
      zlspr,
      zlsch,
      hbkid,
      bstat,
      umskz,
      blart,
      bupla,
      xblnr

}where dmbtr <> 0
//group by
//  laufd,
//  laufi,
//  bukrs,
//  lifnr,
//  gjahr,
//  belnr,
//  buzei,
//  vblnr,
//  PaymentRunIsProposal,
//  Fdgrv,
//  waers,
//  zlspr
