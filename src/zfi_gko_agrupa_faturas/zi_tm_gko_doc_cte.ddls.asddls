@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'GKO - Incoming Invoice - CTE'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_tm_gko_doc_cte
  as select from   j_1bnfdoc as cte
    
    inner join      zttm_gkot001   as t001 on  t001.re_belnr = cte.belnr
                                           and t001.re_gjahr = cte.gjahr
                                           and t001.re_belnr is not initial
    
    inner join j_1bnfe_active as active on active.docnum = cte.docnum

    left outer join bkpf           as bkpf on bkpf.awkey = concat( cte.belnr, cte.gjahr )
                                           and bkpf.awkey is not initial

    left outer join bsik_view      as bsik on  bsik.bukrs = bkpf.bukrs
                                           and bsik.belnr = bkpf.belnr
                                           and bsik.gjahr = bkpf.gjahr
 
    left outer join bsak_view      as bsak on  bsak.bukrs = bkpf.bukrs
                                           and bsak.belnr = bkpf.belnr
                                           and bsak.gjahr = bkpf.gjahr
{
  key t001.acckey,
      active.nfyear,
      active.nfmonth,
      active.stcd1,
      active.model,
      active.serie,
      active.nfnum9,
      active.docnum9,
      active.cdv,
      active.cancel,
      cte.docnum,
      cte.nfnum,
      cte.bukrs,
      cte.branch as bupla,
      bsik.belnr,
      bsik.gjahr,
      bsik.buzei,
      cte.parid,
      bkpf.awkey,
      @Semantics.amount.currencyCode: 'waers'
      bsik.wrbtr,
      bsik.waers,
      bsik.zfbdt,
      bsik.zbd1t,
      bsik.zbd2t,
      bsik.zbd3t,
      bsik.shkzg,
      bsik.rebzg,
      t001.codstatus,
      t001.num_fatura,
      bkpf.xblnr,
      t001.re_belnr as re_belnr,
      t001.re_gjahr as re_gjahr,
      bsak.belnr as clear_belnr,
      bsak.gjahr as clear_gjahr,
      bsak.buzei as clear_buzei
}
