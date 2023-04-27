@AbapCatalog.sqlViewName: 'ZVFI_REVERSAO'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Reversão Abatimento'
define view ZI_FI_REVERSAO
  as select from    bsid_view as bsid
    inner join      bsad_view as bsad on  bsad.bukrs = bsid.bukrs
                                      and bsad.belnr = bsid.rebzg
                                      and bsad.gjahr = bsid.rebzj
                                      and bsad.buzei = bsid.rebzz
    left outer join kna1              on bsad.kunnr = kna1.kunnr
    inner join      bseg              on  bseg.bukrs = bsid.bukrs
                                      and bseg.belnr = bsid.belnr
                                      and bseg.gjahr = bsid.gjahr
                                      and bseg.bschl = '09'

  //    inner join bseg as bseg on bseg.belnr = bsad.augbl
  //                           and bseg.bukrs = bsad.bukrs
  //                           and bseg.bschl = '17'
  //    inner join bkpf as bkpf on bkpf.belnr = bseg.belnr
  //                           and bkpf.bukrs = bseg.bukrs
  //                           and bkpf.gjahr = bseg.gjahr
{

  bsid.bukrs,
  bsid.belnr,
  bsid.gjahr,
  bsid.buzei,
  bseg.augbl,
  bseg.augdt,
  bsid.bschl,
  bsid.blart,
  bsid.budat,
  bsid.waers,
  @Semantics.amount.currencyCode: 'waers'
  bsid.wrbtr,
  bsad.rebzg,
  bsid.kunnr,
  kna1.name1,
  bsid.zuonr,
  bsid.rebzt

}
where
  bsid.bschl = '17'
//  bsid.rebzt = 'G'
