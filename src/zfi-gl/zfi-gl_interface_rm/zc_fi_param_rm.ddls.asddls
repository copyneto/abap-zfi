@EndUserText.label: 'CDS de projeção - Cadastro de Parâmetros RM'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_PARAM_RM
  as projection on ZI_FI_PARAM_RM
{
  key Bukrs,
  key Gsber,
  key Bupla,
      Zmatriz,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
