@EndUserText.label: 'Provisão - Contrato Cliente'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_PROV_CONT
  as projection on ZI_FI_PROV_CONT
{
  key DocUuidH,
  key DocUuidProv,
      Contrato,
      Aditivo,
      Empresa,
      @ObjectModel.text: { element: ['GrpContratosTxt'] }
      GrupContrato,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_TP_DESCONTO', element: 'TipoDescId' }}]
      @ObjectModel.text: { element: ['TipoDescTxt'] }
      TipoDesconto,
      TipoDescTxt,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_TP_APLIC_DESC', element: 'TipoAplicId' }}]
      @ObjectModel.text: { element: ['AplicaTxt'] }
      AplicaDesconto,
      AplicaTxt,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_COND_DESCONTO', element: 'TipoCond' }}]
      @ObjectModel.text: { element: ['CondTxt'] }
      @EndUserText.label: 'Condição de Desconto'
      CondDesconto,
      CondTxt,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_ATRIBUTE2_CMASTER', element: 'Id' }}]
      @ObjectModel.text: { element: ['ClassificCnpjText'] }
      ClassificCnpj,
      ClassificCnpjText,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_TP_APU_IMP', element: 'TipoApImpId' }}]
      @ObjectModel.text: { element: ['TipoApImpText'] }
      TipoApImposto,
      TipoApImpText,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_TP_IMPOSTOS', element: 'TipoImpId' }}]
      @ObjectModel.text: { element: ['TipoImpostoTxt'] }
      TipoImposto,
      TipoImpostoTxt,
      @EndUserText.label: 'Percentual de Desconto'
      PercCondDesc,
      MesVigencia,
      RecoAnualDesc,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_TP_APURACAO', element: 'TipoApuraId' }}]
      @ObjectModel.text: { element: ['TipoApuracaoTxt'] }
      TipoApuracao,
      TipoApuracaoTxt,
      GrpContratosTxt,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _Contrato : redirected to parent ZC_FI_CONTRATO,
      _Familia  : redirected to composition child ZC_FI_PROV_FAMILIA

}
