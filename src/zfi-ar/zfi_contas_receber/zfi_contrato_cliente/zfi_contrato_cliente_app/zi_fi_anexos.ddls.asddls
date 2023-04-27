@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Anexos'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_ANEXOS
  as select from ztfi_cont_anexo
  association        to parent ZI_FI_CONTRATO as _Contrato on $projection.DocUuidH = _Contrato.DocUuidH
  association [0..1] to ZI_FI_TIPO_ANEXO      as _Text     on _Text.TipoDoc = $projection.TipoDoc
{
  key doc_uuid_h            as DocUuidH,
  key doc_uuid_doc          as DocUuidDoc,
      _Contrato.Contrato    as Contrato,
      _Contrato.Aditivo     as Aditivo,
      tipo_doc              as TipoDoc,
      _Text.TipoDocText     as TipoDocText,
      filename              as Filename,
      mimetype              as Mimetype,
      value                 as Value,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _Contrato
}
