@EndUserText.label: 'CDS Log do Cálculo de Crescimento'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_LOG_CALC_CRESCIMENTO
  as projection on ZI_FI_LOG_CALC_CRESCIMENTO
{
  key Contrato,
  key Aditivo,
  key Ciclo,
  key ExercAtual,
  key ExercAnter,
      Timestamp,
      Bukrs,
      Canal,
      TipoComparacao,
      PeridAvaliado,
      MontPeridAval,
      MontComparacao,
      MontCrescimento,
      PercCrescimento,
      PercBonus,
      MontBonus,
      BonusCalculado,
      AjusteAnual,
      Belnr,
      Gjahr,
      CreatedBy,      
      /* Associations */
      _Contrato : redirected to parent ZC_FI_CONTRATO_CLIENTE
}
