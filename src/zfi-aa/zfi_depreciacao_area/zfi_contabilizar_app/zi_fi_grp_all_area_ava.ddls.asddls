@AbapCatalog.sqlViewName: 'ZVGRPAVA'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Agrupar valores'
define view ZI_FI_GRP_ALL_AREA_AVA
  as select from ZI_FI_ALL_AREA_AVA
{
  key bukrs,
  key anln1,
  key anln2,
      gsber,
      kostl,
      gjahr,
      peraf,
      sum( Nafag01 ) as Nafag01,
      sum( Nafag10 ) as Nafag10,
      sum( Nafag11 ) as Nafag11,
      sum( Nafag80 ) as Nafag80,
      sum( Nafag82 ) as Nafag82,
      sum( Nafag84 ) as Nafag84
}

group by
  bukrs,
  anln1,
  anln2,
  gsber,
  kostl,
  gjahr,
  peraf
