@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Interface - Log Contabilização'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_LOG_CONTABILIZACAO
  as select from ztfi_log_contab

  association [0..1] to ZI_FI_VH_LOG_STATUS_CONTAB as _Status on  _Status.ObjectId = $projection.StatusCode
                                                              and _Status.Language = $session.system_language
{
  key id                 as Id,
  key identificacao      as Identificacao,
      _Status.ObjectName as StatusText,
      status_log         as StatusCode,
      
      case status_log
          when 'C' then 3
          when 'E' then 1
          when 'D' then 0
          else 2 
      end                as StatusCriticality,
      usuario            as Usuario,
      dt_exec            as DtExec,
      hr_exec            as HrExec,
      text               as Descricao
}
