@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Retirar bloqueios'
define root view entity ZI_RET_BLOQ
  as select from bsid_view  as a
    inner join   P_BKPF_COM as b on  b.bukrs = a.bukrs
                                 and b.belnr = a.belnr
                                 and b.gjahr = a.gjahr
    inner join   P_BSEG_COM as c on  c.bukrs = a.bukrs
                                 and c.belnr = a.belnr
                                 and c.gjahr = a.gjahr
                                 and c.buzei = a.buzei
{
  key a.bukrs,
  key a.kunnr,
  key a.belnr,
  key a.buzei,
  key a.gjahr,
      a.xblnr,
      a.zuonr,
      a.hbkid,
      a.zlsch,
      a.blart,
      a.zlspr,
      a.bschl,
      a.zterm,
      c.netdt,
      a.sgtxt,
      a.zumsk,
      a.umskz,
      a.gsber,
      cast( a.dmbtr as abap.dec(10,2) ) as dmbtr,
      b.bktxt,
      b.cpudt,
      b.cputm,
      c.koart
}

where
  a.zlspr <> ''
