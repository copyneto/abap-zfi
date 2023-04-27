@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Cadastro de Crescimento'
define root view entity ZI_FI_CAD_CRESCIMENTO
  as select from ztfi_cad_cresci

  association to ZI_CO_FAMILIA_CL     as _Familia  on $projection.FamiliaCl = _Familia.Wwmt1
  association to ZI_FI_TP_APU_IMP     as _ApuraImp on $projection.TipoApImposto = _ApuraImp.TipoApImpId
  association to ZI_FI_TP_IMPOSTOS    as _Imp      on $projection.TipoImposto = _Imp.TipoImpId
  association to ZI_FI_FORMA_DESCONTO as _Forma    on $projection.FormaDescont = _Forma.TipoFormaId
  association to ZI_FI_PERIODICIDADE  as _Period   on $projection.Periodicidade = _Period.TipoPeriodoId
  association to ZI_FI_TIPO_COMPARAR  as _Compar   on $projection.TipoComparacao = _Compar.TipoCompId
  association to ZI_CA_VH_KATR2       as _Katr2    on $projection.ClassificCnpj = _Katr2.katr2
{

  key doc_uuid_h              as DocUuidH,
  key doc_uuid_cresc          as DocUuidCresc,
  key contrato                as Contrato,
  key aditivo                 as Aditivo,
      familia_cl              as FamiliaCl,
      _Familia.Bezek          as FamiliaClTxt,
      tipo_ap_devoluc         as TipoApDevoluc,
      tipo_ap_imposto         as TipoApImposto,
      _ApuraImp               as TipoApImpostoTxt,
      tipo_imposto            as TipoImposto,
      _Imp.TipoImpText        as TipoImpostoTxt,
      forma_descont           as FormaDescont,
      _Forma.TipoFormaText    as FormaDescontTxt,
      ajuste_anual            as AjusteAnual,
      periodicidade           as Periodicidade,
      _Period.TipoPeriodoText as PeriodicidadeTxt,
      inicio_periodic         as InicioPeriodic,
      classific_cnpj          as ClassificCnpj,
      _Katr2.Name             as ClassificCnpjTxt,
      flag_td_atribut         as FlagTdAtribut,
      tipo_comparacao         as TipoComparacao,
      _Compar.TipoCompId      as TipoComparacaoTxt,
      @Semantics.user.createdBy: true
      created_by              as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at              as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by         as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at         as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at   as LocalLastChangedAt
}
