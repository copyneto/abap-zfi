@EndUserText.label: 'Contratos a Vencer'
@AccessControl.authorizationCheck: #CHECK
@AbapCatalog.viewEnhancementCategory: [#NONE]

@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZI_FI_CONTRATO_A_VENCER as select from ZI_FI_CONTRATO_A_VENCER_PARAM
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
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    Situacao,
    DiferencaDias,
    DiasParaVencer
}
