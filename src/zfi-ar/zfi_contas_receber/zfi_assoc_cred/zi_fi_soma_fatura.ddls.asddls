@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Soma Créditos Selecionados'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_SOMA_FATURA
  as select from ztfi_faturacli
{

  key empresa,
  key cliente,
  key raizid,
  key raizsn,
      sum( cast( creditos as abap.dec(23,2) ) ) as TotalCreditos,
      sum( cast( residual as abap.dec(23,2) ) ) as TotalResidual,
      sum( cast( montante as abap.dec(23,2) ) ) as TotalFatura
}
where
  marcado = 'X'

group by
  empresa,
  cliente,
  raizid,
  raizsn
