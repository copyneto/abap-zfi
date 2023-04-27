@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Interface View - Integração Totvs'
define root view entity ZI_FI_TOTVS_LOG
  as select from ztfi_totvs_log as _Log
  association [1] to ZI_FI_VH_STATUS_LOG as _Status on _Status.Status = $projection.Status
{
  key identificacao         as Identificacao,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_VH_STATUS_LOG', element: 'Status' } }]
  key status                as Status,
  key data                  as Data,
  key hora                  as Hora,
      mensagem              as Mensagem,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt,

      case status
        when 'S' 
          then 3
        when 'E' 
          then 1
      else 0
      end                   as StatusCriticality,

      _Status.StatusText,

      _Status
}
