@AbapCatalog.sqlViewName: 'ZVGRPALL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Agrupar valores area de avalição'
define view ZI_FI_GRP_AREA_AVA_ALL
  as select from    ZI_FI_AREA_AVA_ALL as _A

    left outer join Faa_Anlc           as _C on  _A.bukrs = _C.bukrs
                                             and _A.anln1 = _C.anln1
                                             and _A.anln2 = _C.anln2
                                             and _A.gjahr = _C.gjahr
                                             and _A.afabe = _C.afabe

{
  key _A.bukrs,
  key _A.anln1,
  key _A.anln2,
  key _A.gsber,
  key _A.kostl,
  key _A.gjahr,
  key _A.afabe,
  key _A.peraf,
      sum( Nafag01 )                                                                          as Nafag01,
      sum( Nafag10 )                                                                          as Nafag10,
      sum( Nafag11 )                                                                          as Nafag11,
      sum( Nafag80 )                                                                          as Nafag80,
      sum( Nafag82 )                                                                          as Nafag82,
      sum( Nafag84 )                                                                          as Nafag84,
      cast( min( case when _C.afabe = '80' then _C.answl else 0 end ) as abap.curr( 12, 2 ) ) as ANSWL_80,
      cast( min( case when _C.afabe = '80' then _C.nafag else 0 end ) as abap.curr( 12, 2 ) ) as NAFAG_80
}

group by
  _A.bukrs,
  _A.anln1,
  _A.anln2,
  _A.gsber,
  _A.kostl,
  _A.gjahr,
  _A.afabe,
  _A.peraf
