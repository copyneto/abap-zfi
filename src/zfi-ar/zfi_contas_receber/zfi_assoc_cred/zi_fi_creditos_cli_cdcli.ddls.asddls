@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Documentos Créditos Código Cliente'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_CREDITOS_CLI_CDCLI 
  as select from ZI_FI_CREDITOS_CLI_BSID   as bsid
    //inner join   ZI_FI_PARAM_CHAVE_LANC_CREDITO as _Param on _Param.ChaveLancamento = bsid.bschl
  association [0..1] to ztfi_creditoscli as _CreditCli on  _CreditCli.empresa   = $projection.Empresa
                                                       and _CreditCli.documento = $projection.Documento
                                                       and _CreditCli.ano       = $projection.Ano
                                                       and _CreditCli.linha     = $projection.Linha  
                                                       and _CreditCli.cliente   = $projection.Cliente  
  association [0..1] to ZI_FI_CLIENTE_RAIZ as _RaizCnpj on  _RaizCnpj.Cliente   = $projection.CodCliente  
                                                       
{
  key bsid.bukrs                       as Empresa,
  key bsid.belnr                       as Documento,
  key bsid.gjahr                       as Ano,
  key bsid.buzei                       as Linha,
      bsid.kunnr                       as Cliente,
      _RaizCnpj.RaizId                 as RaizId,
      cast( '' as boole_d  )           as RaizSN,
      bsid.kunnr                       as CodCliente,
      @Semantics.amount.currencyCode: 'Moeda'
      _CreditCli.residual              as Residual,
      bsid.blart                       as TipoDocumento,
      bsid.bschl                       as ChaveLancamento,
      bsid.umskz                       as CodigoRZE,
      bsid.netdt                       as VencimentoLiquido,
      bsid.zuonr                       as Atribuicao,
      bsid.xblnr                       as Referencia,
      bsid.budat                       as DataLancamento,
      bsid.zlsch                       as FormaPagamento,
      bsid.zterm                       as CondicaoPagamento,
      bsid.waers                       as Moeda,
      //NETDT    as Vencimento,
      @Semantics.amount.currencyCode: 'Moeda'
      bsid.dmbtr                       as Montante,
      bsid.zbd1p                       as Desconto,    
      @Semantics.user.createdBy: true
      _CreditCli.created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      _CreditCli.created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      _CreditCli.last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      _CreditCli.last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      _CreditCli.local_last_changed_at as LocalLastChangedAt,

      _CreditCli,
      _RaizCnpj
}
