@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Condições Desconto - Contrato'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_COND_CONT
  as select from ztfi_cont_cond
  association to parent ZI_FI_CONTRATO as _Contrato      on $projection.DocUuidH = _Contrato.DocUuidH
  association to ZI_FI_COND_DESCONTO   as _Text          on $projection.TipoCond = _Text.TipoCond
  association to ZI_FI_TP_APLIC_DESC   as _TextAplicDesc on $projection.Aplicacao = _TextAplicDesc.TipoAplicId
{
  key doc_uuid_h                          as DocUuidH,
  key doc_uuid_cond                       as DocUuidCond,
      _Contrato.Contrato                  as Contrato,
      _Contrato.Aditivo                   as Aditivo,
      tipo_cond                           as TipoCond,
      _Text.Text                          as TipoCondText,
      //      @Semantics.amount.currencyCode: 'Moeda'
      cast( percentual  as abap.dec(9,5)) as Percentual,
      @Semantics.amount.currencyCode: 'Moeda'
      montante                            as Montante,
      koei1                               as Moeda,
      aplicacao                           as Aplicacao,
      _TextAplicDesc.TipoAplicText        as AplicacaoText,
      per_vigencia                        as PerVigencia,
      recorrencia_anual                   as RecorrenciaAnual,
      @Semantics.user.createdBy: true
      created_by                          as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                          as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                     as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                     as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at               as LocalLastChangedAt,
      _Contrato
}
