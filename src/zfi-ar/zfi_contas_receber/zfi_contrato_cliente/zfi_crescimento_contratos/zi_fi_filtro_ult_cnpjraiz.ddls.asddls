@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Filtro Último CNPJ Raiz'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_FILTRO_ULT_CNPJRAIZ
  as select from ztfi_raiz_cnpj
{
  key contrato        as Contrato,
  key aditivo         as Aditivo,
  key max(cnpj_raiz)  as CNPJRaiz,
      max(razao_soci) as RazaoSoci

}
group by
  contrato,
  aditivo
