@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Log Diferimento - Docs Processados'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_LOG_DIFER_D as select from ztfi_log_difer_d 
 association to parent ZI_FI_LOG_DIFER_H as _LOG_DIFER_H on _LOG_DIFER_H.IdLog = $projection.IdLog 

{
    key id_log as IdLog,
    key empresa as Empresa,
    key gjahr as Gjahr,
    key belnr as Belnr,
    gjahr_rec as GjahrRec,
    belnr_rec as BelnrRec,
    gjahr_raz as GjahrRaz,
    belnr_raz as BelnrRaz,
    _LOG_DIFER_H
}
