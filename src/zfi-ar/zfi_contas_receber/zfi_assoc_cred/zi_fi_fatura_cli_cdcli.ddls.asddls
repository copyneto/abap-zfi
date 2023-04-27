@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Documentos Faturas Código Cliente'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_FATURA_CLI_CDCLI as select from bsid_view as bsid
  //inner join ZI_FI_PARAM_CHAVE_LANC_FATURA    as _Param     on _Param.ChaveLancamento = bsid.bschl
  association [0..1] to ztfi_faturacli as _FaturaCli on  _FaturaCli.empresa   = $projection.Empresa
                                                     and _FaturaCli.documento = $projection.Documento
                                                     and _FaturaCli.ano       = $projection.Ano
                                                     and _FaturaCli.linha     = $projection.Linha    
  association [0..1] to ZI_FI_CLIENTE_RAIZ as _RaizCnpj on  _RaizCnpj.Cliente   = $projection.CodCliente
  association [0..1] to bseg as _bseg                     on _bseg.bukrs = bsid.bukrs
                                                         and _bseg.belnr = bsid.belnr
                                                         and _bseg.gjahr = bsid.gjahr
                                                         and _bseg.buzei = bsid.buzei                                                                                  
{
  key bsid.bukrs as Empresa,
  key bsid.belnr as Documento,
  key bsid.gjahr as Ano,
  key bsid.buzei as Linha,
      bsid.kunnr as Cliente,
      _RaizCnpj.RaizId               as RaizId,
      cast( '' as boole_d  )         as RaizSN,
      bsid.kunnr as CodCliente,
      bsid.blart as TipoDocumento,
      bsid.bschl as ChaveLancamento,
      bsid.umskz as CodigoRZE,
      _bseg.netdt as VencimentoLiquido,
      bsid.zuonr as Atribuicao,
      bsid.xblnr as Referencia,
      bsid.budat as DataLancamento,
      bsid.zlsch as FormaPagamento,
      bsid.zterm as CondicaoPagamento,
      bsid.waers as Moeda,
      //NETDT    as Vencimento,
      @Semantics.amount.currencyCode: 'Moeda'
      bsid.dmbtr as Montante,
      bsid.zbd1p as Desconto,
      _FaturaCli.marcado as Marcado,
      @Semantics.user.createdBy: true
      _FaturaCli.created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      _FaturaCli.created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      _FaturaCli.last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      _FaturaCli.last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      _FaturaCli.local_last_changed_at as LocalLastChangedAt,
      
      _FaturaCli,
      _bseg,
      _RaizCnpj
      
} where bsid.bschl = '01'
