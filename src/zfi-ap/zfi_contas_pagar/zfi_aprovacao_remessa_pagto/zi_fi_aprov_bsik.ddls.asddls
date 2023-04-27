@AbapCatalog.sqlViewName: 'ZVFIAPVBSIK'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'BSIK Docs'
define view ZI_FI_APROV_BSIK
  as select distinct from bsik_view as _bsik
    inner join            bseg      as _bseg on  _bseg.bukrs = _bsik.bukrs
                                             and _bseg.belnr = _bsik.belnr
                                             and _bseg.gjahr = _bsik.gjahr
                                             and _bseg.buzei = _bsik.buzei
                                             and _bseg.koart = 'K'
                                             and _bseg.shkzg = 'H'
    left outer join       bkpf      as _bkpf on  _bseg.bukrs = _bkpf.bukrs
                                             and _bseg.augbl = _bkpf.belnr
                                             and _bseg.gjahr = _bkpf.gjahr
  //    left outer join       I_SupplierCompany         on  I_SupplierCompany.Supplier    = _bsik.lifnr
  //                                                    and I_SupplierCompany.CompanyCode = _bsik.bukrs
  //
  //    left outer join       ZI_FI_DOC_FDGRV as _Fdgrv on  _bseg.bukrs = _Fdgrv.Bukrs
  //                                                    and _bseg.gjahr = _Fdgrv.Gjahr
  //                                                    and _bseg.belnr = _Fdgrv.Belnr
  //                                                    and _bseg.buzei = _Fdgrv.Buzei
{
  key _bseg.netdt                  as laufd,
  key cast( _bkpf.cputm as tstim ) as lauhr,
  key _bsik.bukrs,
  key _bsik.lifnr,
  key _bsik.gjahr,
  key _bseg.augbl,
  key _bsik.belnr,
  key _bsik.buzei,
      //      coalesce( _Fdgrv.Fdgrv, I_SupplierCompany.CashPlanningGroup ) as Fdgrv,
      @Semantics.amount.currencyCode: 'waers'
      _bsik.dmbtr,
      _bsik.waers,
      _bsik.zlspr,
      _bsik.zlsch,
      _bsik.hbkid,
      _bsik.bstat,
      _bsik.umskz,
      _bsik.blart,
      _bsik.bupla,
      _bsik.xblnr

}

where
      _bsik.bschl = '39'
  and _bsik.umskz = 'F'
union select distinct from bsik_view as _bsik
  inner join               bseg      as _bseg on  _bseg.bukrs = _bsik.bukrs
                                              and _bseg.belnr = _bsik.belnr
                                              and _bseg.gjahr = _bsik.gjahr
                                              and _bseg.buzei = _bsik.buzei
                                              and _bseg.koart = 'K'
                                              and _bseg.shkzg = 'H'
  left outer join          bkpf      as _bkpf on  _bseg.bukrs = _bkpf.bukrs
                                              and _bseg.augbl = _bkpf.belnr
                                              and _bseg.gjahr = _bkpf.gjahr
//  left outer join          I_SupplierCompany         on  I_SupplierCompany.Supplier    = _bsik.lifnr
//                                                     and I_SupplierCompany.CompanyCode = _bsik.bukrs
//
//  left outer join          ZI_FI_DOC_FDGRV as _Fdgrv on  _bseg.bukrs = _Fdgrv.Bukrs
//                                                     and _bseg.gjahr = _Fdgrv.Gjahr
//                                                     and _bseg.belnr = _Fdgrv.Belnr
//                                                     and _bseg.buzei = _Fdgrv.Buzei
{
  key _bseg.netdt as laufd,
  key _bkpf.cputm as lauhr,
  key _bsik.bukrs,
  key _bsik.lifnr,
  key _bsik.gjahr,
  key _bseg.augbl,
  key _bsik.belnr,
  key _bsik.buzei,
      //      coalesce( _Fdgrv.Fdgrv, I_SupplierCompany.CashPlanningGroup ) as Fdgrv,
      @Semantics.amount.currencyCode: 'waers'
      _bsik.dmbtr,
      _bsik.waers,
      _bsik.zlspr,
      _bsik.zlsch,
      _bsik.hbkid,
      _bsik.bstat,
      _bsik.umskz,
      _bsik.blart,
      _bsik.bupla,
      _bsik.xblnr

}

where
  _bsik.bschl = '31'

// I_PaymentProposalItem as _PaymentItem left outer join
//on  _PaymentItem.Supplier               = _bsik.lifnr
//                                                          and _PaymentItem.FiscalYear             = _bsik.gjahr
//                                                          and _PaymentItem.AccountingDocument     = _bsik.belnr
//                                                          and _PaymentItem.AccountingDocumentItem = _bsik.buzei
