@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Config. WF Documentos a pagar'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_WF_DOCPAGAR
  as select from ztfi_wf_docpagar
  association to ZI_CA_VH_DOCTYPE as _Text
    on $projection.DocumentType = _Text.DocType
{
  key  blart                 as DocumentType,
  key  contador              as Counter,
       bktxt                 as DocumentText,

       created_by            as CreatedBy,
       created_at            as CreatedAt,
       last_changed_by       as LastChangedBy,
       last_changed_at       as LastChangedAt,
       local_last_changed_at as LocalLastChangedAt,

       _Text.Text            as DocTypeText,
       /* Associations */
       _Text
}
