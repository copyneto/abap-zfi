@EndUserText.label: 'CDS projeção-Base Comp. de Crescimento'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_COMP_CRESCI
  as projection on ZI_FI_COMP_CRESCI
{
  key DocUuidH,
  key DocUuidCiclo,
      Contrato,
      @EndUserText.label: 'Aditivo Contrato Cliente'
      Aditivo,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_CICLOBASECOMP', element: 'TipoDescId'  }}]
      @ObjectModel.text: { element: ['CiclosText'] }
      @EndUserText.label: 'Ciclo Base de Comparação'
      Ciclos,
      CiclosText,
      @EndUserText.label: 'Montante de Comparação'
      MontComp,
      @EndUserText.label: 'Moeda'
      Waers,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _Crescimento : redirected to parent ZC_FI_CONTRATO_CRESC
}
