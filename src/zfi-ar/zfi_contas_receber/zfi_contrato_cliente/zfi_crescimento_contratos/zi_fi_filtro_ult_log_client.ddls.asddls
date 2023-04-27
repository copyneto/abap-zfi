@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Filtro Último Log Cliente'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_FILTRO_ULT_LOG_CLIENT
  as select from ztfi_log_clcresc as A

{
  key contrato       as Contrato,
  key aditivo        as Aditivo,
  key max(timestamp) as Timestamp

}
group by
  contrato,
  aditivo
