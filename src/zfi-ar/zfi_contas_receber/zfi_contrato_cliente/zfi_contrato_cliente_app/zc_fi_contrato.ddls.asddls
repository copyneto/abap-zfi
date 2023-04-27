@EndUserText.label: 'Gestão de Contrato Cliente'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true

@ObjectModel.semanticKey: ['Contrato', 'Aditivo' ]
define root view entity ZC_FI_CONTRATO
  as projection on ZI_FI_CONTRATO
{
  key DocUuidH,
      @EndUserText.label: 'N° Contrato'
      Contrato,
      @EndUserText.label: 'N° Aditivo'
      Aditivo,
      @EndUserText.label: 'N° Contrato Próprio'
      ContratoProprio,
      @EndUserText.label: 'N° Contrato Jurid'
      ContratoJurid,
      @EndUserText.label: 'Data Inicio Validade'
      DataIniValid,
      @EndUserText.label: 'Data fim Validade'
      DataFimValid,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH', element: 'CompanyCode' }}]
      @ObjectModel.text: { element: ['CompanyCodeName'] }
      Bukrs,
      CompanyCodeName,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_BRANCH', element: 'BusinessPlace' },
                                           additionalBinding: [{  element: 'CompanyCode', localElement: 'Bukrs' }] }]
      @ObjectModel.text: { element: ['BusinessPlaceName'] }
      Branch,
      BusinessPlaceName,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_KATR10', element: 'katr10' }}]
      @ObjectModel.text: { element: ['GrpContratosTxt'] }
      GrpContratos,
      GrpContratosTxt,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_GRP_COND', element: 'Kdkgr' }}]
      @ObjectModel.text: { element: ['GrpCondText'] }
      GrpCond,
      GrpCondText,
      @EndUserText.label: 'N° Chamado Jurídico'
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
      StatusAnexo,
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
      @EndUserText.label: 'CNPJ Principal'
      CnpjPrincipal,
      @EndUserText.label: 'Razão Social'
      RazaoSocial,
      @EndUserText.label: 'Nome Fantasia'
      NomeFantasia,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_TIPO_ENTREGA', element: 'TpEntrega' }}]
      @ObjectModel.text: { element: ['TpEntregaText'] }
      TipoEntrega,
      TpEntregaText,
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
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      @EndUserText.label: 'Aprovador 1'
      Aprov1,
      @EndUserText.label: 'Data Aprov. 1'
      Dataaprov1,
      @EndUserText.label: 'Hora Aprov. 1'
      HoraAprov1,

      @EndUserText.label: 'Aprovador 2'
      Aprov2,
      @EndUserText.label: 'Data Aprov. 2'
      Dataaprov2,
      @EndUserText.label: 'Hora Aprov. 2'
      HoraAprov2,

      @EndUserText.label: 'Aprovador 3'
      Aprov3,
      @EndUserText.label: 'Data Aprov. 3'
      Dataaprov3,
      @EndUserText.label: 'Hora Aprov. 3'
      HoraAprov3,

      @EndUserText.label: 'Aprovador 4'
      Aprov4,
      @EndUserText.label: 'Data Aprov. 4'
      Dataaprov4,
      @EndUserText.label: 'Hora Aprov. 4'
      HoraAprov4,

      @EndUserText.label: 'Aprovador 5'
      Aprov5,
      @EndUserText.label: 'Data Aprov. 5'
      Dataaprov5,
      @EndUserText.label: 'Hora Aprov. 5'
      HoraAprov5,

      @EndUserText.label: 'Aprovador 6'
      Aprov6,
      @EndUserText.label: 'Data Aprov. 6'
      Dataaprov6,
      @EndUserText.label: 'Hora Aprov. 6'
      HoraAprov6,

      @EndUserText.label: 'Aprovador 7'
      Aprov7,
      @EndUserText.label: 'Data Aprov. 7'
      Dataaprov7,
      @EndUserText.label: 'Hora Aprov. 7'
      HoraAprov7,

      @EndUserText.label: 'Aprovador 8'
      Aprov8,
      @EndUserText.label: 'Data Aprov. 8'
      Dataaprov8,
      @EndUserText.label: 'Hora Aprov. 8'
      HoraAprov8,

      @EndUserText.label: 'Aprovador 9'
      Aprov9,
      @EndUserText.label: 'Data Aprov. 9'
      Dataaprov9,
      @EndUserText.label: 'Hora Aprov. 9'
      HoraAprov9,

      @EndUserText.label: 'Aprovador 10'
      Aprov10,
      @EndUserText.label: 'Data Aprov. 10'
      Dataaprov10,
      @EndUserText.label: 'Hora Aprov. 10'
      HoraAprov10,

      @ObjectModel.text: { element: ['DescNivel'] }
      Nivel,
      DescNivel,


      _Raiz        : redirected to composition child ZC_FI_RAIZ_CNPJ_CONT,
      _Anexos      : redirected to composition child ZC_FI_ANEXOS,
      _Cond        : redirected to composition child ZC_FI_COND_CONT,
      _Prov        : redirected to composition child ZC_FI_PROV_CONT,
      _Janela      : redirected to composition child ZC_FI_JANELA_CONT,
      _Aprovadores : redirected to composition child ZC_FI_NIVEIS_APROV_CONTRATO,
      _RetAprov    : redirected to composition child ZC_FI_RETORNO_APROV
}
