@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'GKO - Find Docs by NFS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_TM_GKO_DOC_NFS
  as select from    ZI_TM_GKO_NF as _Nf
    left outer join lfa1         as _Fornecedores      on _Fornecedores.lifnr = _Nf.parid
    left outer join bkpf         as _DocContabil       on _DocContabil.awkey = _Nf.awkey
    left outer join bsik_view    as _Vendas            on  _Vendas.bukrs = _Nf.bukrs
                                                       and _Vendas.belnr = _DocContabil.belnr
                                                       and _Vendas.gjahr = _DocContabil.gjahr
    left outer join bsak_view    as _VendasCompensadas on  _VendasCompensadas.bukrs = _Nf.bukrs
                                                       and _VendasCompensadas.belnr = _DocContabil.belnr
                                                       and _VendasCompensadas.gjahr = _DocContabil.gjahr
    left outer join zttm_gkot001 as _DadosMestre       on  _DadosMestre.re_belnr = _Nf.belnr
                                                       and _DadosMestre.re_gjahr = _Nf.gjahr
{
  key _Nf.docnum                                as docnum,
      //  key _Nf.nfenum                                as nfenum,
  key case when _DadosMestre.nfnum9 is not initial
           then _DadosMestre.nfnum9
           when _DadosMestre.prefno is not initial
           then left( _DadosMestre.prefno, 9 )
           else cast( '' as j_1bnfnum9  )  end  as nfenum,
  key _Nf.nfnum                                 as nfnum,
  key _Nf.series                                as series,
      _Nf.partyp                                as partyp,
      _Nf.direct                                as direct,
      _Nf.cancel                                as cancel,
      _Nf.subseq                                as subseq,
      _Nf.nfesrv                                as nfesrv,
      _Nf.bukrs                                 as bukrs,
      _Nf.bupla                                 as bupla,
      _Nf.parid                                 as parid,
      _Nf.docref                                as docref,
      _DocContabil.belnr                        as belnr,
      _DocContabil.gjahr                        as gjahr,
      _Vendas.buzei                             as buzei,
      @Semantics.amount.currencyCode: 'waers'
      _Vendas.wrbtr                             as wrbtr,
      _Vendas.waers                             as waers,
      _Vendas.zfbdt                             as zfbdt,
      _Vendas.zbd1t                             as zbd1t,
      _Vendas.zbd2t                             as zbd2t,
      _Vendas.zbd3t                             as zbd3t,
      _Vendas.shkzg                             as shkzg,
      _Vendas.rebzg                             as rebzg,
      _DadosMestre.acckey                       as acckey,
      _DadosMestre.codstatus                    as codstatus,
      _DadosMestre.num_fatura                   as num_fatura,
      _Fornecedores.stcd1                       as stcd1,
      cast( left( _Nf.awkey, 10 ) as re_belnr ) as re_belnr,
      cast( right( _Nf.awkey, 4 ) as gjahr )    as re_gjahr,
      _VendasCompensadas.belnr                  as clear_belnr,
      _VendasCompensadas.gjahr                  as clear_gjahr,
      _VendasCompensadas.buzei                  as clear_buzei

}
where
  _Nf.docref is initial
