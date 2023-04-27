@EndUserText.label: 'Aprovadores Contrato'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_NIVEIS_APROV_CONTRATO
  as projection on ZI_FI_NIVEIS_APROV_CONTRATO
{
  key DocUuidH,
  key DocUuidAprov,
      Nivel,
      NivelAtual,
      Bukrs,
      Branch,
      DescNivel,
      Aprovador,
      DataAprov,
      HoraAprov,
      Obs,
      /* Associations */
      _Contrato : redirected to parent ZC_FI_CONTRATO
}
