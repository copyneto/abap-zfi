@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS Log do Cálculo de Crescimento'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_LOG_CALC_CRESCIMENTO
  as select from ztfi_log_clcresc

  association to parent ZI_FI_CONTRATO_CLIENTE as _Contrato on  _Contrato.Contrato = $projection.Contrato
                                                            and _Contrato.Aditivo  = $projection.Aditivo
{
  key contrato                                      as Contrato,
  key aditivo                                       as Aditivo,
  key ciclo                                         as Ciclo,
  key exerc_atual                                   as ExercAtual,
  key exerc_anter                                   as ExercAnter,
      timestamp                                     as Timestamp,
      bukrs                                         as Bukrs,
      canal                                         as Canal,
      tipo_comparacao                               as TipoComparacao,
      perid_avaliado                                as PeridAvaliado,
      cast( mont_perid_aval as abap.dec( 11, 2 ) )  as MontPeridAval,
      cast( mont_comparacao as abap.dec( 11, 2 ) )  as MontComparacao,
      cast( mont_crescimento as abap.dec( 11, 2 ) ) as MontCrescimento,
      perc_crescimento                              as PercCrescimento,
      perc_bonus                                    as PercBonus,
      cast( mont_bonus as abap.dec( 11, 2 ) )       as MontBonus,
      cast( bonus_calculado as abap.dec( 11, 2) )   as BonusCalculado,
      _Contrato.AjusteAnual                         as AjusteAnual,
      belnr                                         as Belnr,
      gjahr                                         as Gjahr,
      created_by                                    as CreatedBy,


      _Contrato
}
