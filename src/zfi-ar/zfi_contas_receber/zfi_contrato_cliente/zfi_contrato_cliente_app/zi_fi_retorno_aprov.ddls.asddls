@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Historico retorno de aprovação'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_RETORNO_APROV
  as select from ztfi_ret_aprov as _Ret
    inner join   ztfi_cad_nivel as _Nivel on _Nivel.nivel = _Ret.nivel
  association to parent ZI_FI_CONTRATO as _Contrato on $projection.DocUuidH = _Contrato.DocUuidH
{
  key _Ret.doc_uuid_h            as DocUuidH,
  key _Ret.doc_uuid_ret          as DocUuidRet,
      _Ret.nivel                 as Nivel,
      _Nivel.desc_nivel          as DescNivel,
      _Ret.contrato              as Contrato,
      _Ret.aditivo               as Aditivo,
      _Ret.aprovador             as Aprovador,
      _Ret.data_aprov            as DataAprov,
      _Ret.hora_aprov            as HoraAprov,
      _Ret.retornador            as Retornador,
      _Ret.data_ret              as DataRet,
      _Ret.hora_ret              as HoraRet,
      _Ret.nivel_atual           as NivelAtual,
      _Ret.observacao            as Observacao,
      _Ret.created_by            as CreatedBy,
      _Ret.created_at            as CreatedAt,
      _Ret.last_changed_by       as LastChangedBy,
      _Ret.last_changed_at       as LastChangedAt,
      _Ret.local_last_changed_at as LocalLastChangedAt,
      _Contrato
}
