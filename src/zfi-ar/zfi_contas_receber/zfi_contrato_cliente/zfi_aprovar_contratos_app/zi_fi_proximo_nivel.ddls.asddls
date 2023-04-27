@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Proximo Nível de Aprovação'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_PROXIMO_NIVEl
  as select from ZI_FI_PROXIMOS_NIVEIS
{
  key DocUuidH,
  key Contrato,
  key Aditivo,
      min(Nivel) as Nivel

}
group by
  DocUuidH,
  Contrato,
  Aditivo
