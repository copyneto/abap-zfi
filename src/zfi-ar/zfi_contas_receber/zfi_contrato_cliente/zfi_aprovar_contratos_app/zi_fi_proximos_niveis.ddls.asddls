@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Proximos Niveis de Aprovação'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_PROXIMOS_NIVEIS
  as select from ZI_FI_CONT_TODOS_NIVEIS_DETAIL
{
  key DocUuidH,
  key Contrato,
  key Aditivo,
  key doc_uuid_aprov,
      nivel_atual,
      Bukrs,
      Branch,
      Nivel,
      Bname,
      Email,
      DescNivel

} where ProximosNiveis = 'X'
