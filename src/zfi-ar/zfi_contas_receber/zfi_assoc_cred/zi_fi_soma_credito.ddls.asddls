@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Soma Créditos Selecionados'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_SOMA_CREDITO
  as select from ztfi_creditoscli
{

  key empresa,
  key cliente,
  key raizid,
  key raizsn,
      sum( cast( montante as abap.dec(23,2) ) ) as TotalCreditos,
      sum( cast( residual as abap.dec(23,2) ) ) as TotalResidual,
      sum( cast( fatura   as abap.dec(23,2) ) ) as TotalFatura
}
  
group by
  empresa,
  cliente,
  raizid,
  raizsn
  
