@EndUserText.label: 'Rel. centro de lucro p lanç. contabeis'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION

define root view entity ZC_FI_CENTRO_LUCRO_LC
  as projection on ZI_FI_CENTRO_LUCRO_LC
{

  key Empresa,
  key Divisao,
  key ContaContabil,
      CentroLucro,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt

}
