@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Dados para preencher o boleto'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_BOLETO_ALL
  //as select from bsid_view as Bsid
  as select from    ZV_FI_BOLETO_BSID as Bsid
    left outer join t012k             as _T012k on  _T012k.bukrs = Bsid.bukrs
                                                and _T012k.hbkid = Bsid.hbkid

  //  I_BR_NFItem tem associacao com I_BR_NFDocument
  association [0..1] to I_BR_NFItem    as _NF    on  $projection.belnr = _NF.BR_NFSourceDocumentNumber
  //association [0..1] to /PF1/P_T012K    as _T012k     on $projection.bukrs  = _T012k.bukrs
  //association [0..1] to t012k    as _T012k     on $projection.bukrs  = _T012k.bukrs
  //                                                    and $projection.hbkid = _T012k.hbkid
  //and $projection.hktid = _T012k.hktid
  association [0..1] to /BSNAGT/P_T012 as _T012  on  $projection.bukrs = _T012.bukrs
                                                 and $projection.hbkid = _T012.hbkid
  //association [0..1] to ESH_N_KNA1_KNB1_KNB1_CUSTOMER as _Kna1
  //on $projection.kunnr = $projection.kunnr
  association [0..1] to kna1           as _Kna1  on  $projection.kunnr = _Kna1.kunnr

  association [0..1] to t012a          as _T012a on  $projection.bukrs = _T012a.bukrs
                                                 and $projection.zlsch = _T012a.zlsch
                                                 and $projection.hbkid = _T012a.hbkid

  association [0..1] to t045t          as _t045t on  $projection.bukrs = _t045t.bukrs
                                                 and $projection.zlsch = _t045t.zlsch
                                                 and $projection.hbkid = _t045t.hbkid


{
  key Bsid.bukrs,
  key Bsid.belnr,
  key Bsid.gjahr,
  key Bsid.buzei,
      Bsid.kunnr,
      Bsid.gsber,
      Bsid.hbkid,
      Bsid.xref3,
      Bsid.xblnr,
      Bsid.zuonr,
      Bsid.bldat,
      Bsid.waers,
      Bsid.zbd1t,
      Bsid.zbd2t,
      Bsid.zbd3t,
      Bsid.vbeln,
      Bsid.bupla,
      Bsid.zbd1p,
      Bsid.zbd2p,
      Bsid.zterm,
      Bsid.zlsch,
      Bsid.rebzg,
      Bsid.rebzj, 
      Bsid.rebzz,
      Bsid.zfbdt,
      Bsid.madat,
      @Semantics.amount.currencyCode: 'WAERS'
      Bsid.wrbtr,
      @Semantics.amount.currencyCode: 'WAERS'
      Bsid.dmbtr,
      _NF.BR_NotaFiscal as BR_NotaFiscal,
      //  _NF.BR_nfenumber,
      _T012.bankl as bankl,
      //  _T012.hbkid,
      _T012k.dtaai as dtaai,
      _T012k.bankn as bankn,
      _T012k.bkont as bkont,
      _t045t.dtaid,
      _T012a.vorga,
      _Kna1.name1,
      _Kna1.pstlz,
      _Kna1.stras,
      _Kna1.ort01,
      _Kna1.ort02,
      _Kna1.regio,
      _Kna1.stcd1,
      _Kna1.stcd2,
      _Kna1.stcd3,


      _NF,
      // _T012k,
      _T012,
      _Kna1,
      _T012a,
      _t045t

}

group by
  Bsid.bukrs,
  Bsid.belnr,
  Bsid.gjahr,
  Bsid.buzei,
  Bsid.kunnr,
  Bsid.gsber,
  Bsid.hbkid,
  Bsid.xref3,
  Bsid.xblnr,
  Bsid.zuonr,
  Bsid.bldat,
  Bsid.waers,
  Bsid.zbd1t,
  Bsid.zbd2t,
  Bsid.zbd3t,
  Bsid.vbeln,
  Bsid.bupla,
  Bsid.zbd1p,
  Bsid.zbd2p,
  Bsid.zterm,
  Bsid.zlsch,
  Bsid.rebzg,
  Bsid.rebzj,
  Bsid.rebzz,
  Bsid.zfbdt,
  Bsid.madat,
  Bsid.wrbtr,
  Bsid.dmbtr,
  _NF.BR_NotaFiscal,
  //  _NF.BR_nfenumber,
  _T012.bankl,
  //  _T012.hbkid,
  _T012k.dtaai,
  _T012k.bankn,
  _T012k.bkont,
  _t045t.dtaid,
  _T012a.vorga,
  _Kna1.name1,
  _Kna1.pstlz,
  _Kna1.stras,
  _Kna1.ort01,
  _Kna1.ort02,
  _Kna1.regio,
  _Kna1.stcd1,
  _Kna1.stcd2,
  _Kna1.stcd3
