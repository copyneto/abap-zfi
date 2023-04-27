@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Filtro de SKAT'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_FILTRO_SKAT
  as select from skat
{
  key max(ktopl) as ktopl,
      saknr,
      max(txt50) as DescSaknr


}
where
  spras = $session.system_language

group by
  saknr
