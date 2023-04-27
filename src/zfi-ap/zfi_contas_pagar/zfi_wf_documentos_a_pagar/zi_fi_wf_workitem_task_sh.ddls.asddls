@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Search Help - Task Decision Workitem'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_WF_WORKITEM_TASK_SH 
    as select from swwwihead as _WFHead
    
{
    key wi_id   as WiID,
        wi_text as Text
}
where top_task   = 'WS90000015'
  and wi_rh_task = 'TS90000068'
