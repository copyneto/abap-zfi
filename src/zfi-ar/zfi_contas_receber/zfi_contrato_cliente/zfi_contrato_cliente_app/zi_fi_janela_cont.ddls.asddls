@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Janela do Contrato'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_JANELA_CONT
  as select from ztfi_cont_janela

  association        to parent ZI_FI_CONTRATO as _Contrato on $projection.DocUuidH = _Contrato.DocUuidH

  association [0..1] to ZI_CO_FAMILIA_CL      as _Familia  on $projection.FamiliaCl = _Familia.Wwmt1
  association [0..1] to ZI_FI_DIASEMANA       as _Semana   on $projection.DiaSemana = _Semana.Diasemana
  association [0..1] to ZI_FI_GRP_COND        as _Grpcond  on $projection.GrpCond = _Grpcond.Kdkgr
  association [0..1] to ZI_CA_VH_KATR2        as _Atr2     on $projection.Atributo2 = _Atr2.katr2

{
  key doc_uuid_h                          as DocUuidH,
  key doc_uuid_janela                     as DocUuidJanela,
      _Contrato.Contrato                  as Contrato,
      _Contrato.Aditivo                   as Aditivo,
      grp_cond                            as GrpCond,
      _Grpcond.Vtext                      as GrpCondTxt,
      atributo_2                          as Atributo2,
      _Atr2.Name                          as Atributo2Txt,
      familia_cl                          as FamiliaCl,
      _Familia.Bezek                      as FamiliaClTxt,
      prazo                               as Prazo,
      cast( percentual as abap.dec(9,5))  as Percentual,
      dia_mes_fixo                        as DiaMesFixo,
      dia_semana                          as DiaSemana,

      case when _Semana.Diasemana  is not null
           then _Semana.DiasemanaText
           else cast (''as val_text ) end as DiasemanaText,
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
