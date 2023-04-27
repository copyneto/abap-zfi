@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Soma Totais Créditos/Fatura'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_SOMA_TOTAIS as select from ZI_FI_CALCULA_TOTAIS
{
  key Empresa,
  key Cliente,
  key RaizId,
  key RaizSn,
      sum( TotalCreditos )  as TotalCreditos,
      sum( TotalResidual )  as TotalResidual,
      sum( TotalFatura )    as TotalFatura
}
group by
  Empresa,
  Cliente,
  RaizId,
  RaizSn
