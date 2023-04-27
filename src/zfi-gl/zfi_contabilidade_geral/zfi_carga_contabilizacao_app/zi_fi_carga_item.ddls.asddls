@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Carga Contabilização - Itens'
define view entity zi_fi_carga_item
  as select from ztfi_carga_item
  association to parent ZI_FI_CARGA_H as _H on $projection.DocUuidH = _H.DocUuidH
{
  key doc_uuid_h            as DocUuidH,
  key doc_uuid_doc          as DocUuidDoc,
  key numero_doc            as NumeroDoc,
  key doc_uuid_item         as DocUuidItem,
      numero_item           as NumeroItem,
      shkzg                 as Shkzg,
      zuonr                 as Zuonr,
      hkont                 as Hkont,
      dmbtr                 as Dmbtr,
      waers                 as Waers,
      bupla                 as Bupla,
      gsber                 as Gsber,
      kostl                 as Kostl,
      prctr                 as Prctr,
      segment               as Segment,
      sgtxt                 as Sgtxt,
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
      _H
}
