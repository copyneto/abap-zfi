@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Nível atual por Contrato'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_NIVEL_ATUAL
  as select from ZI_FI_CONT_TODOS_NIVEIS_DETAIL
{
  key DocUuidH,
  key Contrato,
  key Aditivo,
  key doc_uuid_aprov,
      Bukrs,
      Branch,
      Nivel,
      Bname,
      Email,
      DescNivel
}
where
  nivel_atual = 'X'
