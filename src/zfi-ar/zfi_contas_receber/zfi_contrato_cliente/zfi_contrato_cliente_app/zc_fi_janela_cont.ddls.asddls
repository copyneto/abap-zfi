@EndUserText.label: 'Janela do Contrato'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_JANELA_CONT
  as projection on ZI_FI_JANELA_CONT
{
  key DocUuidH,
  key DocUuidJanela,
      Contrato,
      Aditivo,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_GRP_COND', element: 'Kdkgr' }}]
      @ObjectModel.text: { element: ['GrpCondTxt'] }
      GrpCond,
      GrpCondTxt,
      @Consumption.valueHelpDefinition: [{
          entity: { name: 'ZI_CA_VH_KATR2', element: 'katr2'  } } ]
      @ObjectModel.text: { element: ['Atributo2Txt'] }
      Atributo2,
      Atributo2Txt,
      @Consumption.valueHelpDefinition: [{
          entity: { name: 'ZI_CO_FAMILIA_CL', element: 'Wwmt1'  } } ]
      @ObjectModel.text: { element: ['FamiliaClTxt'] }
      FamiliaCl,
      FamiliaClTxt,
      Prazo,
      @EndUserText: {
          label: 'Percentual',
          quickInfo: 'Percentual'
      }
      Percentual,
      DiaMesFixo,
      @Consumption.valueHelpDefinition: [{
          entity: { name: 'ZI_FI_DIASEMANA', element: 'Diasemana'  } } ]
      @ObjectModel.text: { element: ['DiasemanaText'] }
      DiaSemana,
      DiasemanaText,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _Contrato : redirected to parent ZC_FI_CONTRATO
}
