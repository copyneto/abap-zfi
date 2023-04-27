@EndUserText.label: 'Relatório de Cancelamentos - Projection'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.dataCategory: #VALUE_HELP

define root view entity ZC_FI_REL_CANCELA
  as projection on ZI_FI_REL_CANCELA
{
  key Bukrs,
  key Kunnr,
  key Belnr,
  key Buzei,
  key Gjhar,
  key Datac,
  key Horac,
      Netdt,
      @Consumption.valueHelpDefinition: [{ entity:{ name: 'ZI_FI_VH_CAN', element : 'Motivo' }}]
      @ObjectModel.text.element: ['Motivo']
      Motivo,
      Tipo,
      Belnrestorno,
      Buzeiestorno,
      Gjharestorno,
      Verzn,
      Wrbtr,
      Waers,
      CreatedByUserName,
      @Semantics.user: { id: true, createdBy: true }
      @ObjectModel.text.element: ['CreatedByUserName']
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
