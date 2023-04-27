@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Autom. bancária - log'
define root view entity ZI_FI_AUTOBANC_LOG
  as select from ztfi_autbanc_log
{
  key codigo                as Codigo,
      nome                  as Nome,
      tipo                  as Tipo,
      chave_breve           as ChaveBreve,
      msgtype               as Msgtype,
      diretorio             as Diretorio,
      message               as Message,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt

}
