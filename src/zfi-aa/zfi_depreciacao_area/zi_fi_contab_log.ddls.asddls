@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'DD - Log'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_CONTAB_LOG
  as select from ztfi_contab_log as Log
{

  key bukrs      as Bukrs,
  key anln1      as Anln1,
  key anln2      as Anln2,
  key anlkl      as Anlkl,
  key gsber      as Gsber,
  key kostl      as Kostl,
  key gjahr      as Gjahr,
  key peraf      as Peraf,
      belnr      as Belnr,
      belnr_reav as BelnrReav,
      contab     as Contab,
      reav       as Reav,
      cpudt      as Cpudt,
      cputm      as Cputm,
      cpudt_reav as CpudtReav,
      cputm_reav as CputmReav

}
