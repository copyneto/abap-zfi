@EndUserText.label: 'Projection Rel. Venc Mod Part de Cliente'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_VENC_CLI as projection on ZI_FI_VENC_CLI {

    key Empresa,
    key NoDocumento,
    key Exercicio,
    key Cliente,
    NomeCliente,
    DataMod,
    Item,
    TpDocumento,
    DataLanc,
    DtBase,
    BlocAdvert,
    DocFaturamento,
    FormaPagto,
    MontMoedaInt,
    Dia1,
    Dia2,
    DiasLiq,
    Moeda,
    VencimentoEm,
    DataComp,
    EscritorioVendas,
    RegiaoVendas,
    CanalDist,
    SetorAtiv,
    ContRegist,
    UsuarioMod,
    DiasAtraso,
    VencOrigem,
    DiasProrrog,
    Observacao
}
