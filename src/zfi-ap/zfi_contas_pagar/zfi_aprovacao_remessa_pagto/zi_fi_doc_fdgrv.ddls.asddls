@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Grupo de tesouraria por Documento'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_DOC_FDGRV
  as select from ztfi_doc_fdgrv
{
  key bukrs                 as Bukrs,
  key belnr                 as Belnr,
  key gjahr                 as Gjahr,
  key buzei                 as Buzei,
      fdgrv                 as Fdgrv,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt
}
