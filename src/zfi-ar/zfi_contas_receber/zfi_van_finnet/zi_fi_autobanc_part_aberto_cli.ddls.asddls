@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Autom. bancária-Partidas aberto cliente'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_AUTOBANC_PART_ABERTO_CLI
  as select from bsid_view
{

  key bukrs,
  key kunnr,
  key umsks,
  key umskz,
  key augdt,
  key augbl,
  key zuonr,
  key gjahr,
  key belnr,
  key buzei,
      waers,
      zterm,
      zlsch,
      zlspr,
      anfbn,
      anfbj,
      anfbu,
      manst,
      dtws1,
      dtws2,
      dtws3
}
where
      anfbn <> ''
  and anfbj <> '0000'
  and anfbu <> ''
