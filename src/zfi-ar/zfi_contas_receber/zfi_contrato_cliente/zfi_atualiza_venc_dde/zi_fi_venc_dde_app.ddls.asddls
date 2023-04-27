@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS Interface Vencimento DDE'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_VENC_DDE_APP
  as select from ZI_FI_VENC_DDE
{
  key Empresa,
  key Documento,
  key Exercicio,
  key Cliente,
  key Fatura,
  key Remessa,
      DataEntrega,
      cast(
 Concat(
   Concat(
     Concat(substring(DataEntrega, 5, 2), '.'),
     Concat(substring(DataEntrega, 7, 2), '.')
  ),
Substring(DataEntrega, 1, 4)
  )
as char10 preserving type) as DataEntregaz
      
}
//eliminar
