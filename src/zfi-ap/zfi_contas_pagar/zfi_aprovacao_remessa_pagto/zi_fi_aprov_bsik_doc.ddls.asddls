@AbapCatalog.sqlViewName: 'ZVFIAPV'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'BSIK Docs'
define view ZI_FI_APROV_BSIK_doc
  as select distinct from bsik_view       as _bsik
    left outer join       bseg            as _bseg  on  _bseg.bukrs = _bsik.bukrs
                                                    and _bseg.belnr = _bsik.belnr
                                                    and _bseg.gjahr = _bsik.gjahr
                                                    and _bseg.buzei = _bsik.buzei
    left outer join       ZI_FI_DOC_FDGRV as _Fdgrv on  _bsik.bukrs = _Fdgrv.Bukrs
                                                    and _bsik.gjahr = _Fdgrv.Gjahr
                                                    and _bsik.belnr = _Fdgrv.Belnr
{
  key _bsik.bukrs,
  key _bsik.lifnr,
  key _bsik.gjahr,
  key _bsik.belnr,
  key _bsik.buzei,
      coalesce( _Fdgrv.Fdgrv, '' ) as Fdgrv,
      @Semantics.amount.currencyCode: 'waers'
      _bsik.dmbtr,
      _bsik.waers,
      _bsik.zlspr

}
where
  (
       _bsik.bschl =  '31'
    or _bsik.bschl =  '39'
  )
  and  _bsik.shkzg =  'H'
  and  _bsik.umskz <> 'F'
