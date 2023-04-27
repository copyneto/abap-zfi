@EndUserText.label: 'Contratos a Vencer - parâmetro'
@AccessControl.authorizationCheck: #CHECK
@AbapCatalog.viewEnhancementCategory: [#NONE]

@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_CONTRATO_A_VENCER_PARAM as select from ZI_FI_CONTRATO_A_VENCER_CALCS
    association [0..1] to ZI_CA_PARAM_VAL  as _Param on _Param.Modulo = 'FI-AR' and
                                                        _Param.Chave1 = 'CONTRATOS_A_VENCER' and
                                                        _Param.Chave2 = 'DIAS'
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

    /* Gerados */
    Situacao,
    _Param.Low as DiasParaVencer,
    DiferencaDias,
    
    /*Default*/
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt
    
    } where DiferencaDias <= cast( cast( _Param.Low as abap.numc(10) ) as abap.int4 ) and
            DiferencaDias >= 0
        
