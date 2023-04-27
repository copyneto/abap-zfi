@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Renovação de Contrato'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define root view entity ZI_FI_RENOVACAO_CONTRATO

  as select from ZI_FI_RENOVACAO_CONTRATO_UNION
  association [0..1] to ZI_FI_VH_SITUACAO_CONTRATO as _Situacao on $projection.Situacao = _Situacao.Situacao

{
  key DocUuidH,
  key Contrato,
  key Aditivo,
      RazaoSocial,
      CNPJ,
      ContratoProprio,
      ContratoJurid,
      DataIniValid,
      DataFimValid,
      Bukrs,
      CompanyCodeName,
      Branch,
      BusinessPlaceName,
      GrpContratos,
      GrpContratosTxt,
      GrpCond,
      Chamado,
      PrazoPagto,
      FormaPagto,
      FormaPagtoTxt,
      RespLegal,
      RespLegalGtcor,
      ProdContemplado,
      Observacao,
      Status,
      StatusText,
      Desativado,
      Canal,
      CanalTxt,
      GrpEconomico,
      Abrangencia,
      AbrangenciaTxt,
      Estrutura,
      EstruturaTxt,
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
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      CreatedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      Situacao,
      _Situacao.Texto as SituacaoTexto,
      /*Campos do Pop UP*/
      DataIniValid    as AbsDataIniValid,
      DataFimValid    as AbsDataFimValid
}
