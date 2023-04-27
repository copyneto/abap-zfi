@EndUserText.label: 'Familias da Provisão'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_PROV_FAMILIA
  as projection on zi_fi_prov_familia
{
      @UI.hidden: true
  key DocUuidH,
      @UI.hidden: true
  key DocUuidProv,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CO_FAMILIA_CL', element: 'Wwmt1' }}]
      @ObjectModel.text: { element: ['FamiliaClTxt'] }
  key Familia,
      FamiliaClTxt,
      Contrato,
      Aditivo,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _Contrato : redirected to ZC_FI_CONTRATO,
      _Prov     : redirected to parent ZC_FI_PROV_CONT
}
