@AbapCatalog.sqlViewName: 'ZVALLAVA'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Dados gerais Areas de avaliação'
define view ZI_FI_ALL_AREA_AVA
  as select distinct from anla     as _A


    left outer join       anlz     as _Z on  _A.bukrs = _Z.bukrs
                                         and _A.anln1 = _Z.anln1
                                         and _A.anln2 = _Z.anln2

    left outer join       Faa_Anlp as _P on  _A.bukrs = _P.bukrs
                                         and _A.anln1 = _P.anln1
                                         and _A.anln2 = _P.anln2

    left outer join       Faa_Anlc as _C on  _A.bukrs = _C.bukrs
                                         and _A.anln1 = _C.anln1
                                         and _A.anln2 = _C.anln2
                                         and _C.gjahr = _P.gjahr
{


  key _A.bukrs                                                                                 as bukrs,
  key _A.anln1                                                                                 as anln1,
  key _A.anln2                                                                                 as anln2,
  key _Z.gsber                                                                                 as gsber,
  key _Z.kostl                                                                                 as kostl,
  key _P.gjahr                                                                                 as gjahr,
  key _P.afaber                                                                                as afabe,
  key _P.peraf                                                                                 as peraf,
      cast( min( case when _P.afaber = '01' then _P.nafap else 0 end ) as abap.curr( 12, 2 ) ) as Nafag01,
      cast( min( case when _P.afaber = '10' then _P.nafap else 0 end ) as abap.curr( 12, 2 ) ) as Nafag10,
      cast( min( case when _P.afaber = '11' then _P.nafap else 0 end ) as abap.curr( 12, 2 ) ) as Nafag11,
      cast( min( case when _P.afaber = '80' then _P.nafap else 0 end ) as abap.curr( 12, 2 ) ) as Nafag80,
      cast( min( case when _P.afaber = '82' then _P.nafap else 0 end ) as abap.curr( 12, 2 ) ) as Nafag82,
      cast( min( case when _P.afaber = '84' then _P.nafap else 0 end ) as abap.curr( 12, 2 ) ) as Nafag84,
      cast( min( case when _C.afabe = '80' then _C.answl else 0 end ) as abap.curr( 12, 2 ) )  as ANSWL_80,
      cast( min( case when _C.afabe = '80' then _C.nafag else 0 end ) as abap.curr( 12, 2 ) )  as NAFAG_80
}
where
     _C.afabe = '01'
  or _C.afabe = '10'
  or _C.afabe = '11'
  or _C.afabe = '80'
  or _C.afabe = '82'
  or _C.afabe = '84'
group by
  _A.bukrs,
  _A.anln1,
  _A.anln2,
  _Z.gsber,
  _Z.kostl,
  _P.gjahr,
  _P.afaber,
  _P.peraf




//union select from anla     as _A
//
//
//  left outer join anlz     as _Z on  _A.bukrs = _Z.bukrs
//                                 and _A.anln1 = _Z.anln1
//                                 and _A.anln2 = _Z.anln2
//
//  left outer join Faa_Anlc as _C on  _A.bukrs = _C.bukrs
//                                 and _A.anln1 = _C.anln1
//                                 and _A.anln2 = _C.anln2
//
//  left outer join Faa_Anlp as _P on  _A.bukrs = _P.bukrs
//                                 and _A.anln1 = _P.anln1
//                                 and _A.anln2 = _P.anln2
//                                 and _C.gjahr = _P.gjahr
//
//{
//
//
//  key _A.bukrs                                                                                as bukrs,
//  key _A.anln1                                                                                as anln1,
//  key _A.anln2                                                                                as anln2,
//      _Z.gsber                                                                                as gsber,
//      _Z.kostl                                                                                as kostl,
//      _C.afabe                                                                                as afabe,
//      _C.gjahr                                                                                as gjahr,
//      _P.peraf                                                                                as peraf,
//      0                                                                                       as Nafag01,
//      cast( min( case when _C.afabe = '10' then _C.nafag else 0 end ) as abap.curr( 12, 2 ) ) as Nafag10,
//      0                                                                                       as Nafag11,
//      0                                                                                       as Nafag80,
//      0                                                                                       as Nafag82,
//      0                                                                                       as Nafag84
//}
//where
//  _C.afabe = '10'
//group by
//  _A.bukrs,
//  _A.anln1,
//  _A.anln2,
//  _Z.gsber,
//  _Z.kostl,
//  _C.afabe,
//  _C.gjahr,
//  _P.peraf
//
//
//union select from anla     as _A
//
//
//  left outer join anlz     as _Z on  _A.bukrs = _Z.bukrs
//                                 and _A.anln1 = _Z.anln1
//                                 and _A.anln2 = _Z.anln2
//
//  left outer join Faa_Anlc as _C on  _A.bukrs = _C.bukrs
//                                 and _A.anln1 = _C.anln1
//                                 and _A.anln2 = _C.anln2
//
//  left outer join Faa_Anlp as _P on  _A.bukrs = _P.bukrs
//                                 and _A.anln1 = _P.anln1
//                                 and _A.anln2 = _P.anln2
//                                 and _C.gjahr = _P.gjahr
//
//{
//
//
//  key _A.bukrs                                                                                as bukrs,
//  key _A.anln1                                                                                as anln1,
//  key _A.anln2                                                                                as anln2,
//      _Z.gsber                                                                                as gsber,
//      _Z.kostl                                                                                as kostl,
//      _C.afabe                                                                                as afabe,
//      _C.gjahr                                                                                as gjahr,
//      _P.peraf                                                                                as peraf,
//      0                                                                                       as Nafag01,
//      0                                                                                       as Nafag10,
//      cast( min( case when _C.afabe = '11' then _C.nafag else 0 end ) as abap.curr( 12, 2 ) ) as Nafag11,
//      0                                                                                       as Nafag80,
//      0                                                                                       as Nafag82,
//      0                                                                                       as Nafag84
//}
//where
//  _C.afabe = '11'
//group by
//  _A.bukrs,
//  _A.anln1,
//  _A.anln2,
//  _Z.gsber,
//  _Z.kostl,
//  _C.afabe,
//  _C.gjahr,
//  _P.peraf
//
//union select from anla     as _A
//
//
//  left outer join anlz     as _Z on  _A.bukrs = _Z.bukrs
//                                 and _A.anln1 = _Z.anln1
//                                 and _A.anln2 = _Z.anln2
//
//  left outer join Faa_Anlc as _C on  _A.bukrs = _C.bukrs
//                                 and _A.anln1 = _C.anln1
//                                 and _A.anln2 = _C.anln2
//
//  left outer join Faa_Anlp as _P on  _A.bukrs = _P.bukrs
//                                 and _A.anln1 = _P.anln1
//                                 and _A.anln2 = _P.anln2
//                                 and _C.gjahr = _P.gjahr
//
//{
//
//
//  key _A.bukrs                                                                                as bukrs,
//  key _A.anln1                                                                                as anln1,
//  key _A.anln2                                                                                as anln2,
//      _Z.gsber                                                                                as gsber,
//      _Z.kostl                                                                                as kostl,
//      _C.afabe                                                                                as afabe,
//      _C.gjahr                                                                                as gjahr,
//      _P.peraf                                                                                as peraf,
//      0                                                                                       as Nafag01,
//      0                                                                                       as Nafag10,
//      0                                                                                       as Nafag11,
//      cast( min( case when _C.afabe = '80' then _C.nafag else 0 end ) as abap.curr( 12, 2 ) ) as Nafag80,
//      0                                                                                       as Nafag82,
//      0                                                                                       as Nafag84
//}
//where
//  _C.afabe = '80'
//group by
//  _A.bukrs,
//  _A.anln1,
//  _A.anln2,
//  _Z.gsber,
//  _Z.kostl,
//  _C.afabe,
//  _C.gjahr,
//  _P.peraf
//
//
//union select from anla     as _A
//
//
//  left outer join anlz     as _Z on  _A.bukrs = _Z.bukrs
//                                 and _A.anln1 = _Z.anln1
//                                 and _A.anln2 = _Z.anln2
//
//  left outer join Faa_Anlc as _C on  _A.bukrs = _C.bukrs
//                                 and _A.anln1 = _C.anln1
//                                 and _A.anln2 = _C.anln2
//
//  left outer join Faa_Anlp as _P on  _A.bukrs = _P.bukrs
//                                 and _A.anln1 = _P.anln1
//                                 and _A.anln2 = _P.anln2
//                                 and _C.gjahr = _P.gjahr
//
//{
//
//
//  key _A.bukrs                                                                                as bukrs,
//  key _A.anln1                                                                                as anln1,
//  key _A.anln2                                                                                as anln2,
//      _Z.gsber                                                                                as gsber,
//      _Z.kostl                                                                                as kostl,
//      _C.afabe                                                                                as afabe,
//      _C.gjahr                                                                                as gjahr,
//      _P.peraf                                                                                as peraf,
//      0                                                                                       as Nafag01,
//      0                                                                                       as Nafag10,
//      0                                                                                       as Nafag11,
//      0                                                                                       as Nafag80,
//      cast( min( case when _C.afabe = '82' then _C.nafag else 0 end ) as abap.curr( 12, 2 ) ) as Nafag82,
//      0                                                                                       as Nafag84
//}
//where
//  _C.afabe = '82'
//group by
//  _A.bukrs,
//  _A.anln1,
//  _A.anln2,
//  _Z.gsber,
//  _Z.kostl,
//  _C.afabe,
//  _C.gjahr,
//  _P.peraf
//
//union select from anla     as _A
//
//
//  left outer join anlz     as _Z on  _A.bukrs = _Z.bukrs
//                                 and _A.anln1 = _Z.anln1
//                                 and _A.anln2 = _Z.anln2
//
//  left outer join Faa_Anlc as _C on  _A.bukrs = _C.bukrs
//                                 and _A.anln1 = _C.anln1
//                                 and _A.anln2 = _C.anln2
//
//  left outer join Faa_Anlp as _P on  _A.bukrs = _P.bukrs
//                                 and _A.anln1 = _P.anln1
//                                 and _A.anln2 = _P.anln2
//                                 and _C.gjahr = _P.gjahr
//
//{
//
//
//  key _A.bukrs                                                                                as bukrs,
//  key _A.anln1                                                                                as anln1,
//  key _A.anln2                                                                                as anln2,
//      _Z.gsber                                                                                as gsber,
//      _Z.kostl                                                                                as kostl,
//      _C.afabe                                                                                as afabe,
//      _C.gjahr                                                                                as gjahr,
//      _P.peraf                                                                                as peraf,
//      0                                                                                       as Nafag01,
//      0                                                                                       as Nafag10,
//      0                                                                                       as Nafag11,
//      0                                                                                       as Nafag80,
//      0                                                                                       as Nafag82,
//      cast( min( case when _C.afabe = '84' then _C.nafag else 0 end ) as abap.curr( 12, 2 ) ) as Nafag84
//}
//where
//  _C.afabe = '84'
//
//group by
//  _A.bukrs,
//  _A.anln1,
//  _A.anln2,
//  _Z.gsber,
//  _Z.kostl,
//  _C.afabe,
//  _C.gjahr,
//  _P.peraf
