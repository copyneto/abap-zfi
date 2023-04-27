@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Simulação de Vigência Contratos Cliente'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define root view entity zi_fi_vigen_contratos_clientes
  as select from ZI_FI_CONTRATO
{
  key DocUuidH,
  key Contrato,
  key Aditivo,
      cnpj_principal,  
      razao_social,
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
      
      '' as Simulacao,
//      dats_add_days($session.system_date, -1, 'INITIAL' ) as dataFim,
//      cast( '00000000' as dats ) as dataInicio,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
