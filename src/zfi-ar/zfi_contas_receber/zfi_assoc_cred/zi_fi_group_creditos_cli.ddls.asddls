@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Agrupa Créditos Cliente'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_GROUP_CREDITOS_CLI as select from ZI_FI_CREDITOS_CLI_U
{
  key Empresa,
  key Cliente,
  key RaizId,
  key RaizSn,
      sum( cast( 0 as abap.dec(23,2) ) ) as TotalCreditos,
      sum( cast( 0 as abap.dec(23,2) ) ) as TotalResidual,
      sum( cast( 0 as abap.dec(23,2) ) ) as TotalFatura
}
group by
  Empresa,
  Cliente,
  RaizId,
  RaizSn
