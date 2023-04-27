@EndUserText.label: 'CDS de projeção - Família de Crescimento'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true

@ObjectModel.semanticKey: ['Contrato', 'Aditivo']
define view entity ZC_FI_FAMILIA_CRESC
  as projection on ZI_FI_FAMILIA_CRESC
{
  key DocUuidH,
  key DocUuidFamilia,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CO_FAMILIA_CL', element: 'Wwmt1' } } ]
      @ObjectModel.text: { element: ['FamiliaClTxt'] }
      FamiliaCl,
      Contrato,
      Aditivo,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _Familia.Bezek as FamiliaClTxt,
      
      _Crescimento : redirected to parent ZC_FI_CONTRATO_CRESC
}
