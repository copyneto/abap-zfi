@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de interface - Faixa e Bônus - Cresci Contrato Cliente'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_FAIXA_CRESC
  as select from ztfi_faixa_cresc
  association        to parent ZI_FI_CONTRATO_CRESC as _Crescimento on $projection.DocUuidH = _Crescimento.DocUuidH
  //                                                             and $projection.Contrato = _Crescimento.Contrato

  association [0..1] to ZI_FI_CODIGO_VALOR          as _Text        on $projection.CodFaixa = _Text.TipoDescId
  association [0..1] to ZI_FI_COD_MONTANTE          as _CodMont     on $projection.CodMontante = _CodMont.TipoCodMont
{
  key doc_uuid_h               as DocUuidH,
  key doc_uuid_faixa           as DocUuidFaixa,
      contrato                 as Contrato,
      aditivo                  as Aditivo,
      moeda                    as Moeda,
      cod_faixa                as CodFaixa,
      _Text.TipoDescText       as CodFaixaText,
      vlr_faixa_ini            as VlrFaixaIni,
      vlr_faixa_fim            as VlrFaixaFim,
      cod_montante             as CodMontante,
      _CodMont.TipoCodMontText as CodMontanteText,
      @Semantics.amount.currencyCode : 'Moeda'
      vlr_mont_ini             as VlrMontIni,
      @Semantics.amount.currencyCode : 'Moeda'
      vlr_mont_fim             as VlrMontFim,
      vlr_bonus_ini            as VlrBonusIni,
      @Semantics.amount.currencyCode : 'Moeda'
      vlr_montbonus_ini        as VlrMontbonusIni,
      @Semantics.user.createdBy: true
      created_by               as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at               as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by          as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at          as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at    as LocalLastChangedAt,

      _Crescimento
}
