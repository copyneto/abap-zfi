@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Carga Contabilização - Header'
define root view entity ZI_FI_CARGA_H
  as select from ztfi_carga_h
  composition [0..*] of ZI_FI_CARGA_DOC    as _Doc
  composition [0..*] of zi_fi_carga_item   as _Item
  association [0..1] to ZI_FI_STATUS_CARGA as _Status on $projection.Status = _Status.StatusId
{

  key doc_uuid_h            as DocUuidH,
      documentno            as Documentno,
      data_carga            as DataCarga,
      status                as Status,
      _Status.StatusText    as StatusText,
      case status
        when '0' then 2 -- Pendente         | 2: yellow colour
        when '1' then 1 -- Erro             | 1: red colour
        when '2' then 3 -- Completo         | 3: green colour
        when '3' then 1 -- Cancelado        | 3: green colour
        else 0          --                  | 0: unknown
      end                   as StatusCriticality,


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

      _Doc,
      _Item
}
