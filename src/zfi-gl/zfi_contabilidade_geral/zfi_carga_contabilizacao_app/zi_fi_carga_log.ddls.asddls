@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Carga Contabilização-Logs de Mensagens'
define view entity ZI_FI_CARGA_LOG
  as select from ztfi_carga_log
{

  key documentid            as Documentid,
  key seqnr                 as Seqnr,
      msgty                 as Msgty,
      msgid                 as Msgid,
      msgno                 as Msgno,
      msgv1                 as Msgv1,
      msgv2                 as Msgv2,
      msgv3                 as Msgv3,
      msgv4                 as Msgv4,
      message               as Message,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}
