@EndUserText.label: 'Carga de Pendencias'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_FI_CARGA_PENDENCIAS
  as projection on ZI_FI_CARGA_PENDENCIAS
{

  key Doc_guid,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.6
      @Search.ranking: #MEDIUM
  key Contrato,
  key Aditivo,
  key Bukrs,
  key Belnr,
  key Gjahr,
  key NumeroItem,
      Kunnr,
      Budat,
      Wrbtr,
      Waers,
      Bzirk,
      Canal,
      Setor,
      Vkorg,
      TipoDesc,
      DocProvisao,
      ExercProvisao,
      MontProvisao,
      DocLiquidacao,
      ExercLiquidacao,
      MontLiquidacao,
      DocEstorno,
      ExercEstorno,
      MontEstorno,
      StatusProvisao,
      TipoDado,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
