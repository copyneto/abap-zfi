@AbapCatalog.sqlViewName: 'ZVIFICPC2LCKML'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Material Ledger'
define view ZI_FI_CPC2L_CKML
  as select from ckmlhd as _Mlhd
    inner join   ckmlpp as _Mlpp on _Mlhd.kalnr = _Mlpp.kalnr
    inner join   ckmlcr as _Mlcr on  _Mlpp.kalnr = _Mlcr.kalnr
                                 and _Mlpp.bdatj = _Mlcr.bdatj
                                 and _Mlpp.poper = _Mlcr.poper
                                 and _Mlcr.curtp = '10'
{
  key _Mlhd.kalnr as Kalnr,
  key _Mlpp.bdatj as Bdatj,
  key _Mlpp.poper as Poper,
      _Mlcr.vnprd_ea,
      _Mlcr.vnkdm_ea,
      _Mlcr.vnprd_ma,
      _Mlcr.vnkdm_ma,
      case
        when vnkumo = 0
          then 1
        else
          vnkumo
      end         as vnkumo,
      waers,
      meins
}
