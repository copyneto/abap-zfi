@EndUserText.label: 'Simulação de Vigência Contratos Cliente'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
  @Search.searchable : true 
define root view entity zc_fi_vigen_contratos_clientes
  as projection on zi_fi_vigen_contratos_clientes
{
  key DocUuidH,
      @EndUserText.label: 'N° Contrato'
  key Contrato,
      @EndUserText.label: 'N° Aditivo'
  key Aditivo,
      @EndUserText.label: 'CNPJ Principal'
      cnpj_principal,  
      @EndUserText.label: 'Razão Social'
      razao_social,  
      @EndUserText.label: 'N° Contrato Próprio'
      ContratoProprio,
      @EndUserText.label: 'N° Contrato Jurid'
      ContratoJurid,
      //@EndUserText.label: 'Data Inicio Validade'
      DataIniValid,
      @EndUserText.label: 'Data fim Validade'
      DataFimValid,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH', element: 'CompanyCode' }}]
      @ObjectModel.text: { element: ['CompanyCodeName'] }
      Bukrs,
      CompanyCodeName,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_BRANCH', element: 'BusinessPlace' }}]
      @ObjectModel.text: { element: ['BusinessPlaceName'] }
      Branch,
      BusinessPlaceName,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_KATR10', element: 'katr10' }}]
      @ObjectModel.text: { element: ['GrpContratosTxt'] }
      GrpContratos,
      GrpContratosTxt,
      GrpCond,
      Chamado,
      PrazoPagto,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_FORMA_PAGTO', element: 'FormaPagtoId' }}]
      @ObjectModel.text: { element: ['FormaPagtoTxt'] }
      FormaPagto,
      FormaPagtoTxt,
      RespLegal,
      RespLegalGtcor,
      ProdContemplado,
      Observacao,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_STATUS_CONTRATO', element: 'StatusId' } }]
      @ObjectModel.text: { element: ['StatusText'] }
      Status,
      StatusText,
      Desativado,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_VTWEG', element: 'CanalDistrib' }}]
      @ObjectModel.text: { element: ['CanalTxt'] }
      Canal,
      CanalTxt,
      GrpEconomico,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_KATR3', element: 'katr3' }}]
      @ObjectModel.text: { element: ['AbrangenciaTxt'] }
      Abrangencia,
      AbrangenciaTxt,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_KATR5', element: 'katr5' }}]
      @ObjectModel.text: { element: ['EstruturaTxt'] }
      Estrutura,
      EstruturaTxt,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_KATR6', element: 'katr6' }}]
      @ObjectModel.text: { element: ['CanalpdvTxt'] }
      Canalpdv,
      CanalpdvTxt,
      TipoEntrega,
      DataEntrega,
      DataFatura,
      Crescimento,
      AjusteAnual,
      DataAssinatura,
      Multas,
      RenovAut,
      AlertaVig,
      AlertaEnviado,
      AlertaDataEnvio,
      Simulacao,
//      dataFim,
//      
//      dataInicio,
      
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
