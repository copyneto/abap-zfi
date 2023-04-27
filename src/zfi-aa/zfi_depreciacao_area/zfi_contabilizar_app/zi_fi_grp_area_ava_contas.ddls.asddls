@AbapCatalog.sqlViewName: 'ZVAVACONTGR'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Agrupar area de avaliação e contas'
define view ZI_FI_GRP_AREA_AVA_CONTAS
  as select from ZI_FI_AREA_AVA_CONTAS
{
  key Bukrs,
  key Anln1,
  key Anln2,
      Anlkl,
      Txt50,
      Aktiv,
      gsber,
      kostl,
      gjahr,
      peraf,
      sum( Nafag01 )       as Nafag01,
      sum( Nafag10 )       as Nafag10,
      sum( Nafag11 )       as Nafag11,
      sum( Nafag80 )       as Nafag80,
      sum( Nafag82 )       as Nafag82,
      sum( Nafag84 )       as Nafag84,

      sum( ANSWL_80 )      as ANSWL_80,
      sum( NAFAG_80 )      as NAFAG_80,
      sum( NAFAG_80_CALC ) as NAFAG_80_CALC,

      ContaDepFiscal_01,
      ContaDepFiscal_10,
      ContaDepFiscal_11,
      ContaDespFiscal_01,
      ContaDespFiscal_10,
      ContaDespFiscal_11,
      ContaDepFiscal_80,
      ContaDepFiscal_82,
      ContaDepFiscal_84,
      ContaDespFiscal_80,
      ContaDespFiscal_82,
      ContaDespFiscal_84
}
group by
  Bukrs,
  Anln1,
  Anln2,
  Anlkl,
  gsber,
  kostl,
  gjahr,
  peraf,
  Txt50,
  Aktiv,
  ContaDepFiscal_01,
  ContaDepFiscal_10,
  ContaDepFiscal_11,
  ContaDespFiscal_01,
  ContaDespFiscal_10,
  ContaDespFiscal_11,
  ContaDepFiscal_80,
  ContaDepFiscal_82,
  ContaDepFiscal_84,
  ContaDespFiscal_80,
  ContaDespFiscal_82,
  ContaDespFiscal_84
