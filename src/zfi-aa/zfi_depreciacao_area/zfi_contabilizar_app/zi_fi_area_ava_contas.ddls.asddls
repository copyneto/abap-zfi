@AbapCatalog.sqlViewName: 'ZVAVACONT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Area de avaliação com as Contas'
define view ZI_FI_AREA_AVA_CONTAS
  as select from    anla               as _A

    left outer join ZI_FI_ALL_AREA_AVA as _Ava     on  _Ava.bukrs = _A.bukrs
                                                   and _Ava.anln1 = _A.anln1
                                                   and _Ava.anln2 = _A.anln2

    left outer join ztfi_cont_depre    as _Conta01 on  _Conta01.anlkl  = _A.anlkl
                                                   and _Conta01.afaber = '01'
    left outer join ztfi_cont_depre    as _Conta10 on  _Conta10.anlkl  = _A.anlkl
                                                   and _Conta10.afaber = '10'
    left outer join ztfi_cont_depre    as _Conta11 on  _Conta11.anlkl  = _A.anlkl
                                                   and _Conta11.afaber = '11'
    left outer join ztfi_cont_depre    as _Conta80 on  _Conta80.anlkl  = _A.anlkl
                                                   and _Conta80.afaber = '80'
    left outer join ztfi_cont_depre    as _Conta82 on  _Conta82.anlkl  = _A.anlkl
                                                   and _Conta82.afaber = '82'
    left outer join ztfi_cont_depre    as _Conta84 on  _Conta84.anlkl  = _A.anlkl
                                                   and _Conta84.afaber = '84'
{

  key _A.bukrs                    as Bukrs,
  key _A.anln1                    as Anln1,
  key _A.anln2                    as Anln2,
      _A.anlkl                    as Anlkl,
      _A.txt50                    as Txt50,
      _A.aktiv                    as Aktiv,
      _Ava.gsber                  as gsber,
      _Ava.kostl                  as kostl,
      _Ava.gjahr                  as gjahr,
      _Ava.afabe                  as afabe,
      _Ava.peraf                  as peraf,
      _Ava.Nafag01                as Nafag01,
      _Ava.Nafag10                as Nafag10,
      _Ava.Nafag11                as Nafag11,
      _Ava.Nafag80                as Nafag80,
      _Ava.Nafag82                as Nafag82,
      _Ava.Nafag84                as Nafag84,

      _Ava.ANSWL_80               as ANSWL_80,
      _Ava.NAFAG_80               as NAFAG_80,
      abs( _Ava.NAFAG_80)         as NAFAG_80_CALC,


      _Conta01.deprec_fiscal      as ContaDepFiscal_01,
      _Conta10.deprec_fiscal      as ContaDepFiscal_10,
      _Conta11.deprec_fiscal      as ContaDepFiscal_11,
      _Conta01.despesa_fiscal     as ContaDespFiscal_01,
      _Conta10.despesa_fiscal     as ContaDespFiscal_10,
      _Conta11.despesa_fiscal     as ContaDespFiscal_11,

      _Conta80.deprec_societaria  as ContaDepFiscal_80,
      _Conta82.deprec_societaria  as ContaDepFiscal_82,
      _Conta84.deprec_societaria  as ContaDepFiscal_84,
      _Conta80.despesa_societaria as ContaDespFiscal_80,
      _Conta82.despesa_societaria as ContaDespFiscal_82,
      _Conta84.despesa_societaria as ContaDespFiscal_84


}
