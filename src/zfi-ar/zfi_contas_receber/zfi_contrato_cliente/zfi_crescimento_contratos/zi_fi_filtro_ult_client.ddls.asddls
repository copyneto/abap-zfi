@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Filtro Último Cliente/CNPJ'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_FILTRO_ULT_CLIENT
  as select from ztfi_cnpj_client
{
  key contrato       as Contrato,
  key aditivo        as Aditivo,
  key max(cnpj_raiz) as CnpjRaiz,
  key max(cliente)   as Cliente,
      max(cnpj)      as Cnpj
}
group by
  contrato,
  aditivo
