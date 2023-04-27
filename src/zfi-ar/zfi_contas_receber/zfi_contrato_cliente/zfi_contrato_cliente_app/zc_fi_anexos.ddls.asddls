@EndUserText.label: 'Anexos'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_FI_ANEXOS
  as projection on ZI_FI_ANEXOS
{
  key DocUuidH,
  key DocUuidDoc,
      Contrato,
      Aditivo,
      @ObjectModel.text: { element: ['TipoDocText'] }
      TipoDoc,
      TipoDocText,
      Filename,
      Mimetype,
      Value,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _Contrato : redirected to parent ZC_FI_CONTRATO
}
