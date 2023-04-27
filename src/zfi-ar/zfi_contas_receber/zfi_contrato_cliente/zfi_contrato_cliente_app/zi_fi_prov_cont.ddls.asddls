@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Provisão - Contrato Cliente'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_PROV_CONT
  as select from ztfi_cad_provi

  association to parent ZI_FI_CONTRATO     as _Contrato on $projection.DocUuidH = _Contrato.DocUuidH

  composition [0..*] of zi_fi_prov_familia as _Familia


  association to ZI_FI_TP_DESCONTO         as _TpDesc   on $projection.TipoDesconto = _TpDesc.TipoDescId
  association to ZI_FI_CONDICAO_DESCONTO   as _Cond     on $projection.CondDesconto = _Cond.TipoCond
  association to ZI_FI_TP_APLIC_DESC       as _Aplic    on $projection.AplicaDesconto = _Aplic.TipoAplicId
  association to ZI_FI_TP_APU_IMP          as _ApuraImp on $projection.TipoApImposto = _ApuraImp.TipoApImpId
  association to ZI_FI_TP_IMPOSTOS         as _Imp      on $projection.TipoImposto = _Imp.TipoImpId
  association to ZI_FI_TP_APURACAO         as _Apura    on $projection.TipoApuracao = _Apura.TipoApuraId
  association to ZI_FI_ATRIBUTE2_CMASTER   as _CMaster  on $projection.ClassificCnpj = _CMaster.Id

{
  key doc_uuid_h                             as DocUuidH,
  key doc_uuid_prov                          as DocUuidProv,
      _Contrato.Contrato                     as Contrato,
      _Contrato.Aditivo                      as Aditivo,
      empresa                                as Empresa,
      _Contrato.GrpContratos                 as GrupContrato,
      tipo_desconto                          as TipoDesconto,
      _TpDesc.TipoDescText                   as TipoDescTxt,
      aplica_desconto                        as AplicaDesconto,
      _Aplic.TipoAplicText                   as AplicaTxt,
      cond_desconto                          as CondDesconto,
      _Cond.Text                             as CondTxt,
      classific_cnpj                         as ClassificCnpj,
      _CMaster.Text                          as ClassificCnpjText,
      tipo_ap_imposto                        as TipoApImposto,
      _ApuraImp.TipoApImpText                as TipoApImpText,
      tipo_imposto                           as TipoImposto,
      _Imp.TipoImpText                       as TipoImpostoTxt,
      cast( perc_cond_desc as abap.dec(9,5)) as PercCondDesc,
      mes_vigencia                           as MesVigencia,
      reco_anual_desc                        as RecoAnualDesc,
      tipo_apuracao                          as TipoApuracao,
      _Apura.TipoApuraText                   as TipoApuracaoTxt,
      _Contrato.GrpContratosTxt              as GrpContratosTxt,
      @Semantics.user.createdBy: true
      created_by                             as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                             as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                        as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                        as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at                  as LocalLastChangedAt,
      _Familia,
      _Contrato
}
