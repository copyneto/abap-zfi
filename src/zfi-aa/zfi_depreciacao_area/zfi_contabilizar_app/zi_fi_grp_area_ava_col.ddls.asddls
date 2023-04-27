@AbapCatalog.sqlViewName: 'ZVGRPCOL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Colunar dados agrupados'
define view ZI_FI_GRP_AREA_AVA_COL
  as select from ZI_FI_AREA_AVA_ALL
{
  key bukrs,
  key anln1,
  key anln2,
      gjahr,
      peraf,

      cast( min( case when afabe = '01' then Nafag01 else 0 end )  as abap.curr( 12, 2 ) ) as Nafag01,
      cast( min( case when afabe = '10' then Nafag10 else 0 end ) as abap.curr( 12, 2 ) )  as Nafag10,
      cast( min( case when afabe = '11' then Nafag11 else 0 end ) as abap.curr( 12, 2 ) )  as Nafag11,
      cast( min( case when afabe = '80' then Nafag80 else 0 end ) as abap.curr( 12, 2 ) )  as Nafag80,
      cast( min( case when afabe = '82' then Nafag82 else 0 end ) as abap.curr( 12, 2 ) )  as Nafag82,
      cast( min( case when afabe = '84' then Nafag84 else 0 end ) as abap.curr( 12, 2 ) )  as Nafag84
}
group by
  bukrs,
  anln1,
  anln2,
  gjahr,
  peraf
