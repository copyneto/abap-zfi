@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'WEVO - Cont Reversa - LOG'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_cont_revers_log
  as select from ztfi_cont_revers

  association [0..1] to t001             as _T001         on $projection.Bukrs = _T001.bukrs

  association [0..1] to ztfi_ecm_cenar   as _CodCenario   on _CodCenario.cod_cenario = $projection.CodCenario
  association [0..1] to ztfi_ecm_mercadr as _CodMercad    on _CodMercad.cod_mercadoria = $projection.CodMercadoria
  association [0..1] to ztfi_ecm_ressarc as _CodRessarc   on _CodRessarc.cod_ressarcimento = $projection.CodRessarcimento
  association [0..1] to ztfi_ecm_pagamnt as _CodPagment   on _CodPagment.cod_pgto = $projection.CodPgto
  association [0..1] to ztfi_ecm_ordemsd as _CodOrdemSD   on _CodOrdemSD.cod_ordem = $projection.CodOrdem
  association [0..1] to ztfi_ecm_tpcenar as _CodTpCenario on _CodTpCenario.cod_tipo_cenario = $projection.CodTipoCenario

{
  key cod_cenario           as CodCenario,
  key bukrs                 as Bukrs,
  key bstkd                 as Bstkd,
  key bupla                 as Bupla,
  key zlsch                 as Zlsch,
  key data_i                as DataI,
  key hora_i                as HoraI,
  key user_i                as UserI,
      gsber                 as Gsber,
      belnr                 as Belnr,
      gjahr                 as Gjahr,
      bukrs_d               as BukrsD,
      cod_tipo_cenario      as CodTipoCenario,
      cod_ordem             as CodOrdem,
      cod_pgto              as CodPgto,
      cod_ressarcimento     as CodRessarcimento,
      cod_mercadoria        as CodMercadoria,
      vbeln                 as Vbeln,
      lifnr                 as Lifnr,
      @UI.hidden: true
      _T001.waers           as Waers,
      @Semantics.amount.currencyCode: 'Waers'
      zvou                  as Zvou,
      @Semantics.amount.currencyCode: 'Waers'
      vlr_restituir         as VlrRestituir,
      id_pedido             as IdPedido,
      @Semantics.amount.currencyCode: 'Waers'
      vlr_tax               as VlrTax,
      voucher               as Voucher,
      adm                   as Adm,
      nsu                   as Nsu,
      dt_venda              as DtVenda,
      nome_ident            as NomeIdent,
      status                as Status,
      tx_perc               as TxPerc,
      id_sales_force        as IdSalesForce,
      reservado_1           as Reservado1,
      reservado_2           as Reservado2,
      reservado_3           as Reservado3,
      reservado_4           as Reservado4,
      reservado_5           as Reservado5,
      reservado_6           as Reservado6,
      reservado_7           as Reservado7,
      reservado_8           as Reservado8,
      reservado_9           as Reservado9,
      reservado_10          as Reservado10,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDate.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDate.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _T001,
      _CodCenario,
      _CodMercad,
      _CodRessarc,
      _CodPagment,
      _CodOrdemSD,
      _CodTpCenario

}
