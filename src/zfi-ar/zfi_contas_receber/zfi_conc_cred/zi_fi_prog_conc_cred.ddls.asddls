@AbapCatalog.sqlViewName: 'ZVFI_PROGCC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Busca Documentos'
define view ZI_FI_PROG_CONC_CRED
  as select distinct from           bsid_view      as b
    inner join             ztfi_conc_cred as z on  b.bukrs = z.bukrs
                                               and b.blart = z.blart
                                               and b.bschl = z.bschl
                                               and b.zlsch = z.zlspr
    inner join             kna1           as k on b.kunnr = k.kunnr
    inner join             bseg           as s on  b.bukrs = s.bukrs
                                               and b.belnr = s.belnr
                                               and b.gjahr = s.gjahr
                                               and b.bschl = s.bschl
    inner join             bkpf           as f on  b.bukrs = f.bukrs
                                               and b.belnr = f.belnr
                                               and b.gjahr = f.gjahr
    left outer to one join bseg           as g on  b.bukrs = g.bukrs
                                               and b.belnr = g.belnr
                                               and b.gjahr = g.gjahr
                                               and g.koart = 'S'
{

 key b.belnr,
 key b.bukrs,
 key b.gjahr,
 key b.buzei,
  b.blart,
  b.bschl,
  b.zlspr,
  b.zlsch,
  b.kunnr,
  b.budat,
  b.dmbtr,
  b.gsber,
  b.bupla,
  b.zuonr,
  b.sgtxt,
  b.wrbtr,
  b.zfbdt,
  b.zbd1t,
  b.zbd2t,
  b.zbd3t,
  b.hbkid,
  f.xblnr,
  f.bktxt,
  f.xref1_hd,
  f.xref2_hd,
  g.prctr,
  g.segment,
  g.netdt,
  k.stcd1,
  k.stcd2,
  s.lifnr,
  g.kostl,
  z.mindays,
  z.minres

}
where
  b.rebzg = ''
