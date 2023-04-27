@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Log Diferimento - Docs Mensagens'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_LOG_DIFER_M as select from ztfi_log_difer_m 
association to parent ZI_FI_LOG_DIFER_H as _LOG_DIFER_H on _LOG_DIFER_H.IdLog = $projection.IdLog
{
    key id_log as IdLog,
    key id_msg as IdMsg,
    key id_bapi as IdBapi,
    type as Type,
    case type
     when 'E' then 1
     when 'S' then 3
     when 'W' then 2
              else 0 
    end        as MgCor,       
    message as Message,
    _LOG_DIFER_H
    
}
