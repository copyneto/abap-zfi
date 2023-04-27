@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Soma Créditos Clientes'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_SUM_CREDITOS_CLI
  as select from ZI_FI_CREDITOS_CLI_U
{
  key Empresa,
  key Cliente,
  key RaizId,
  key RaizSn,
      sum( cast( Montante as abap.dec(23,2) ) ) as Montante
}
group by
  Empresa,
  Cliente,
  RaizId,
  RaizSn
