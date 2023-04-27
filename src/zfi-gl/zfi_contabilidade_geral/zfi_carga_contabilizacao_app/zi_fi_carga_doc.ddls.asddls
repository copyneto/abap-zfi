@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Carga Contabilização - Documento'
define view entity ZI_FI_CARGA_DOC
  as select from ztfi_carga_doc
  association        to parent ZI_FI_CARGA_H   as _H      on $projection.DocUuidH = _H.DocUuidH
  association [0..1] to ZI_FI_STATUS_DOC_CARGA as _Status on $projection.Status = _Status.StatusId
{
  key doc_uuid_h            as DocUuidH,
  key doc_uuid_doc          as DocUuidDoc,
      numero_doc            as NumeroDoc,
      status                as Status,
      _Status.StatusText    as StatusText,
      case status
      when '0' then 2 -- Pendente         | 2: yellow colour
      when '1' then 3 -- Erro             | 3: green colour
      when '2' then 1 -- Completo         | 1: red colour
      else 0          --                  | 0: unknown
      end                   as StatusCriticality,
      bukrs                 as Bukrs,
      belnr                 as Belnr,
      blart                 as Blart,
      bldat                 as Bldat,
      budat                 as Budat,
      monat                 as Monat,
      gjahr                 as Gjahr,
      xblnr                 as Xblnr,
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
