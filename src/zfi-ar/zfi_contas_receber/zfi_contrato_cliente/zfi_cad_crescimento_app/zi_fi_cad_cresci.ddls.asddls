@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de interface - Crescimento'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_CAD_CRESCI
  as select from ztfi_cad_cresci
  association to parent ZI_FI_CONTRATO_CRESC as _Crescimento on  $projection.DocUuidH = _Crescimento.DocUuidH
  //                                                             and $projection.Contrato = _Crescimento.Contrato

  association to ZI_CO_FAMILIA_CL            as _Familia     on  $projection.FamiliaCl = _Familia.Wwmt1
                                                             and _Familia.Spras        = $session.system_language
  association to ZI_FI_TP_APU_IMP            as _ApuraImp    on  $projection.TipoApImposto = _ApuraImp.TipoApImpId
  association to ZI_FI_TP_IMPOSTOS           as _Imp         on  $projection.TipoImposto = _Imp.TipoImpId
  association to ZI_FI_TP_AP_IMPOST          as _ApDevoluc   on  $projection.TipoApDevoluc = _ApDevoluc.TipoApDevoluc
  association to ZI_FI_PERIODIC              as _Periodic    on  $projection.Periodicidade = _Periodic.TipoPeriodicidade
  association to ZI_FI_TIPO_COMPARACAO       as _TpComparac  on  $projection.TipoComparacao = _TpComparac.TipoComparacaoId
  association to ZI_CA_VH_KATR2              as _Katr2       on  $projection.ClassificCnpj = _Katr2.katr2


{
  key doc_uuid_h                      as DocUuidH,
  key doc_uuid_cresc                  as DocUuidCresc,
      contrato                        as Contrato,
      aditivo                         as Aditivo,
      familia_cl                      as FamiliaCl,
      _Familia.Bezek                  as FamiliaClTxt,
      tipo_ap_devoluc                 as TipoApDevoluc,
      _ApDevoluc.TipoApDevolucText    as TipoApDevolucText,
      tipo_ap_imposto                 as TipoApImposto,
      _ApuraImp.TipoApImpText         as TipoApImpText,
      tipo_imposto                    as TipoImposto,
      _Imp.TipoImpText                as TipoImpostoText,
      forma_descont                   as FormaDescont,
      ajuste_anual                    as AjusteAnual,
      periodicidade                   as Periodicidade,
      _Periodic.TipoPeriodicidadeText as PeriodicidadeText,
      inicio_periodic                 as InicioPeriodic,
      classific_cnpj                  as ClassificCnpj,
      _Katr2.Name                     as ClassificCnpjText,
      flag_td_atribut                 as FlagTdAtribut,
      tipo_comparacao                 as TipoComparacao,
      _TpComparac.TipoComparacaoText  as TipoComparacaoText,
      @Semantics.user.createdBy: true
      created_by                      as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                      as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                 as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                 as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at           as LocalLastChangedAt,

      _Crescimento
}
