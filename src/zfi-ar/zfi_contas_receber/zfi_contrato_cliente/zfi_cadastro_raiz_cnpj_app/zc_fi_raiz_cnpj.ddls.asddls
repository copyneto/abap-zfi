@EndUserText.label: 'Cnpj Raiz'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_RAIZ_CNPJ
  as projection on ZI_FI_RAIZ_CNPJ
{
  key DocUuidH,
  key DocUuidRaiz,
      CnpjRaiz,
      Contrato,
      Aditivo,
      RazaoSoci,
      NomeFanta,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _Clientes : redirected to composition child ZC_FI_RAIZ_CLIENTES
}
