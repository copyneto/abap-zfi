@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Cockpit de Fatura de Clientes'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_COCKPIT_FATURA_CLI
  as select from ZI_FI_FATURA_CLI_U
  association to parent ZI_FI_COCKPIT_ASSOCIACAO_CRE as _Associ on $projection.Empresa          = _Associ.Empresa    
                                                               and $projection.Cliente          = _Associ.Cliente
                                                               and $projection.RaizId           = _Associ.RaizId
                                                               and $projection.RaizSn           = _Associ.RaizSn
  association [0..1] to ztfi_faturacli as _FaturaCli on  _FaturaCli.empresa   = $projection.Empresa
                                                     and _FaturaCli.documento = $projection.Documento
                                                     and _FaturaCli.ano       = $projection.Ano
                                                     and _FaturaCli.linha     = $projection.Linha                                                                                
{
  key Empresa,
  key Cliente,
  key RaizId,
  key RaizSn,  
  key Documento,
  key Ano,
  key Linha,
      CodCliente,
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
      case Marcado when 'X' then 'Marcado'
                            else 'Não Marcado'
                            end  as Marcado,

      case Marcado when 'X'
                  then 3
                  else 2
                  end              as MarcadoCriticality,      
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      
      _Associ,
      _FaturaCli
}
