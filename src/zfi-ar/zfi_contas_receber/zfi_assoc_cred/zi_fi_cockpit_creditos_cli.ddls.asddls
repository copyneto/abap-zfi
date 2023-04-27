@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Cockpit de Créditos de Clientes'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_COCKPIT_CREDITOS_CLI
  as select from ZI_FI_CREDITOS_CLI_U as _Creditos
  association to parent ZI_FI_COCKPIT_ASSOCIACAO_CRE as _Associ on $projection.Empresa          = _Associ.Empresa    
                                                               and $projection.Cliente          = _Associ.Cliente
                                                               and $projection.RaizId           = _Associ.RaizId
                                                               and $projection.RaizSn           = _Associ.RaizSn
  association [0..1] to ztfi_creditoscli as _CreditCli on  _CreditCli.empresa   = $projection.Empresa
                                                       and _CreditCli.documento = $projection.Documento
                                                       and _CreditCli.ano       = $projection.Ano
                                                       and _CreditCli.linha     = $projection.Linha                                                             
{
  key Empresa,
  key Cliente,
  key RaizId,
  key RaizSn,
  key Documento,
  key Ano,  
  key Linha,
      CodCliente,
      @Semantics.amount.currencyCode: 'Moeda'
      Residual,
      TipoDocumento,
      ChaveLancamento,
      CodigoRZE,
      VencimentoLiquido,
      Atribuicao,
      Referencia,
      DataLancamento,
      FormaPagamento,
      CondicaoPagamento,
      Moeda,
      @Semantics.amount.currencyCode: 'Moeda'
      Montante,
      Desconto,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      
      _Associ,
      _CreditCli
}
