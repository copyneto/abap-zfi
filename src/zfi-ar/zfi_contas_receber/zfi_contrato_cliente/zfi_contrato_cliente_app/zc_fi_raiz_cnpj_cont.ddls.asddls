@EndUserText.label: 'Raiz CNPJ - Contrato Cliente'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_RAIZ_CNPJ_CONT
  as projection on ZI_FI_RAIZ_CNPJ_CONT 
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
      _Contrato : redirected to parent ZC_FI_CONTRATO,
      _Clientes : redirected to composition child ZC_FI_CLIENTES_CONT
}
