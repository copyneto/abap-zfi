@AbapCatalog.sqlViewName: 'ZVFIAPRVBSID'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'BSIK Docs'
define view ZC_FI_APROV_BSIK_DOC
  as select from ZI_FI_APROV_BSIK
{
  key bukrs,
  key lifnr,
  key gjahr,
  key belnr,
  key buzei,  
//      Fdgrv,
      @Semantics.amount.currencyCode: 'waers'
      sum( dmbtr ) as dmbtr,
      waers,
      zlspr
}
group by
  bukrs,
  lifnr,
gjahr,
belnr, 
buzei,  
waers,
  zlspr
