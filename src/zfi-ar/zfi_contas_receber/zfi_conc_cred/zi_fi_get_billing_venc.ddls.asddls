@AbapCatalog.sqlViewName: 'ZVFI_BILLVENC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Busca dados de fatura e vencimento'
define view ZI_FI_GET_BILLING_VENC
  as select distinct from  bsid_view           as a
    inner join             bseg                as b on  a.bukrs = b.bukrs
                                                    and a.belnr = b.belnr
                                                    and a.gjahr = b.gjahr
                                                    and a.buzei = b.buzei
    inner join             ZI_CA_GET_CNPJ_ROOT as r on a.kunnr = r.kunnr
    inner join             bkpf                as f on  b.bukrs = f.bukrs
                                                    and b.belnr = f.belnr
                                                    and b.gjahr = f.gjahr
    left outer to one join bseg                as s on  a.bukrs = s.bukrs
                                                    and a.belnr = s.belnr
                                                    and a.gjahr = s.gjahr
                                                    and s.koart = 'S'
    left outer to one join lfbk                as k on k.lifnr = a.kunnr
    inner join             ztfi_conc_cred      as z on  a.bukrs = z.bukrs
                                                    and a.blart = z.blart
                                                    and a.bschl = z.bschl
                                                    and a.zlsch = z.zlspr
{


  key a.bukrs,
  key a.belnr,
  key a.gjahr,
  key a.buzei,
      a.kunnr,
      a.blart,
      s.gsber,
      a.budat,
      a.bupla,
      a.hbkid,
      a.bschl,
      a.anfbn,
      a.zlsch,
      b.segment,
      b.netdt,
      s.prctr,
      s.kostl,
      f.xref1_hd,
      f.xref2_hd,
      a.dmbtr,
      a.wrbtr,
      a.zuonr,
      a.xblnr,
      a.zbd1p,
      r.rootCnpj,
      k.bankl,
      z.mindays,  
      z.minres,
      s.buzei as buzei_koart
}
where
  a.bschl = '01'
