@EndUserText.label: 'Historico retorno de aprovação'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_RETORNO_APROV
  as projection on ZI_FI_RETORNO_APROV
{
  key DocUuidH,
  key DocUuidRet,
      Nivel,
      DescNivel,
      Contrato,
      Aditivo,
      Aprovador,
      DataAprov,
      HoraAprov,
      Retornador,
      DataRet,
      HoraRet,
      NivelAtual,
      Observacao,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _Contrato : redirected to parent ZC_FI_CONTRATO
}
