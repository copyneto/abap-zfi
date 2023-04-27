@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Interface - Ordem de Frete'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_TRANSPORDEXECUTION
  as select from I_TranspOrdExecution as _TranspOrdExecution
  
  inner join I_TranspOrdExecution as _TranspOrdExec on _TranspOrdExec.TransportationOrderEventUUID = _TranspOrdExecution.TransportationOrderEventUUID
                                                   and _TranspOrdExec.TransportationOrderUUID = _TranspOrdExecution.TransportationOrderUUID
                                                   and _TranspOrdExec.TranspOrdExecution = _TranspOrdExecution.TranspOrdExecution
                                                   and _TranspOrdExec.TranspOrdEventCode = 'DIFERIMENTO'
{
key _TranspOrdExecution.TransportationOrderUUID,
max(_TranspOrdExecution.TranspOrdExecution) as IdOrdExecution 
}
group by 
_TranspOrdExecution.TransportationOrderUUID
