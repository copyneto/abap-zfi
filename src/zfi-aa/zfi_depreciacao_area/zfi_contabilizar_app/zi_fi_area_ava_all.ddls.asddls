@AbapCatalog.sqlViewName: 'ZVFIAVAL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Bucar valores Area de avalição sem agrupamento'
define view ZI_FI_AREA_AVA_ALL
  as select distinct from anla     as _A


    left outer join       anlz     as _Z on  _A.bukrs = _Z.bukrs
                                         and _A.anln1 = _Z.anln1
                                         and _A.anln2 = _Z.anln2
                                         and _Z.adatu <= $session.user_date
                                         and _Z.bdatu >= $session.user_date

    left outer join       Faa_Anlp as _P on  _A.bukrs = _P.bukrs
                                         and _A.anln1 = _P.anln1
                                         and _A.anln2 = _P.anln2

{


  key _A.bukrs                                                                            as bukrs,
  key _A.anln1                                                                            as anln1,
  key _A.anln2                                                                            as anln2,
  key _Z.gsber                                                                            as gsber,
  key _Z.kostl                                                                            as kostl,
  key _P.gjahr                                                                            as gjahr,
  key _P.afaber                                                                           as afabe,
  key _P.peraf                                                                            as peraf,
      cast(  case when _P.afaber = '01' then _P.nafap else 0 end  as abap.curr( 12, 2 ) ) as Nafag01,
      cast(  case when _P.afaber = '10' then _P.nafap else 0 end  as abap.curr( 12, 2 ) ) as Nafag10,
      cast(  case when _P.afaber = '11' then _P.nafap else 0 end  as abap.curr( 12, 2 ) ) as Nafag11,
      cast(  case when _P.afaber = '80' then _P.nafap else 0 end  as abap.curr( 12, 2 ) ) as Nafag80,
      cast(  case when _P.afaber = '82' then _P.nafap else 0 end  as abap.curr( 12, 2 ) ) as Nafag82,
      cast(  case when _P.afaber = '84' then _P.nafap else 0 end  as abap.curr( 12, 2 ) ) as Nafag84
}
where
     _P.afaber = '01'
  or _P.afaber = '10'
  or _P.afaber = '11'
  or _P.afaber = '80'
  or _P.afaber = '82'
  or _P.afaber = '84'
