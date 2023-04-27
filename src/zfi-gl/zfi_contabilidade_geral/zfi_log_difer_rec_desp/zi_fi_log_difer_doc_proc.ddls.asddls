@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS View Documentos já processados'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_LOG_DIFER_DOC_PROC as select from ZI_FI_LOG_DIFER_D 
 inner join ztfi_log_difer_h on ZI_FI_LOG_DIFER_D.IdLog =  ztfi_log_difer_h.status
 {
 
 key ZI_FI_LOG_DIFER_D.Empresa,
 key ZI_FI_LOG_DIFER_D.Gjahr,
 key ZI_FI_LOG_DIFER_D.Belnr,
 ztfi_log_difer_h.status
    
} where ztfi_log_difer_h.status = '2'
