@AbapCatalog.sqlViewName: 'ZVFI_DDE'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Busca dados para Interface'
define view ZI_FI_VENC_DDE
  as select distinct from bkpf             as f
    inner join            bsid_view        as d  on  f.bukrs = d.bukrs
                                                 and f.belnr = d.belnr
                                                 and f.gjahr = d.gjahr
    inner join            vbrp             as p  on d.vbeln = p.vbeln
    left outer join       ZI_FI_ENTREGA_TM as tm on tm.Remessa = p.vgbel
{

  key d.bukrs             as Empresa,
  key d.belnr             as Documento,
  key d.gjahr             as Exercicio,
  key d.kunnr             as Cliente,
  key d.vbeln             as Fatura,
  key p.vgbel             as Remessa,
      max(tm.DataEntrega) as DataEntrega

}
where
  d.vbeln is not initial
group by
  d.bukrs,
  d.belnr,
  d.gjahr,
  d.kunnr,
  d.vbeln,
  p.vgbel
//eliminar
