@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Interface - Log Diferimento Mensagens'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_LOG_MSG
  as select from ztfi_log_dif_msg

  association to parent ZI_FI_LOG_DIF as _LogDif on  _LogDif.Empresa = $projection.Empresa
                                                 and _LogDif.NumDoc  = $projection.NumDoc
                                                 and _LogDif.Ano     = $projection.Ano

{
  key bukrs      as Empresa,
  key belnr      as NumDoc,
  key gjahr      as Ano,
  key contador   as Contador,
      tp_bapi    as TipoBapi,
      bukrs_cont as EmpresaCont,
      belnr_cont as NumDocCont,
      gjahr_cont as AnoCont,
      bukrs_est  as EmpresaEst,
      belnr_est  as NumcDocEst,
      gjahr_est  as AnoEst,
      text       as Text,

      _LogDif
}
