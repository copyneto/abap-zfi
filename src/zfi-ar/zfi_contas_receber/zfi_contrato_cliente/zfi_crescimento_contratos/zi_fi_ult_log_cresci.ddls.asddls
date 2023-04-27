@AbapCatalog.sqlViewName: 'ZVULTLOG'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Ultimo log Crescimento'
define view ZI_FI_ULT_LOG_CRESCI
  as select from ztfi_log_clcresc
  

  
{
  key contrato         as Contrato,
  key aditivo          as Aditivo,
  key ajuste_anual     as AjusteAnual,
  key ciclo            as Ciclo,
  key exerc_atual      as ExercAtual,
  key exerc_anter      as ExercAnter,
      timestamp        as Timestamp,
      bukrs            as Bukrs,
      canal            as Canal,
      tipo_comparacao  as TipoComparacao,
      perid_avaliado   as PeridAvaliado,
      mont_perid_aval  as MontPeridAval,
      mont_comparacao  as MontComparacao,
      mont_crescimento as MontCrescimento,
      perc_crescimento as PercCrescimento,
      perc_bonus       as PercBonus,
      mont_bonus       as MontBonus,
      bonus_calculado  as BonusCalculado,
      gjahr            as Gjahr,
      belnr            as Belnr
}
