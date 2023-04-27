@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Cockpit de Associação de Créditos'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_COCKPIT_ASSOCIACAO_CRE
  as select from ZI_FI_SUM_CREDITOS_CLI
  composition [0..*] of ZI_FI_COCKPIT_CREDITOS_CLI as _Creditos
  composition [0..*] of ZI_FI_COCKPIT_FATURA_CLI   as _Fatura
  association [0..1] to ZI_FI_SOMA_TOTAIS          as _Totais      on  _Totais.Empresa    = $projection.Empresa  
                                                                   and _Totais.Cliente    = $projection.Cliente 
                                                                   and _Totais.RaizId     = $projection.RaizId  
                                                                   and _Totais.RaizSn     = $projection.RaizSn  
  association [0..1] to ZI_FI_SUM_FATURA_CLI       as _SumFatura   on  _SumFatura.Empresa    = $projection.Empresa  
                                                                   and _SumFatura.Cliente    = $projection.Cliente 
                                                                   and _SumFatura.RaizId     = $projection.RaizId  
                                                                   and _SumFatura.RaizSn     = $projection.RaizSn
  association [0..1] to ZI_CA_VH_BUKRS             as _Empresa     on  _Empresa.Empresa   = $projection.Empresa
  association [0..1] to ZI_CA_VH_RAIZCODID         as _RaizId      on  _RaizId.Cliente    = $projection.Cliente
                                                                   and _RaizId.RaizId     = $projection.RaizId
{
  key Empresa,
  key Cliente,
  key RaizId,
  key RaizSn,
      Montante              as Montante,
      _SumFatura.Montante   as FaturaMontante,
      _Totais.TotalCreditos as TotalizadorDetalhe1,
      _Totais.TotalFatura   as TotalizadorDetalhe2,
      ( _Totais.TotalFatura - _Totais.TotalCreditos ) as TotalizadorDetalhe3,
      _Totais.TotalResidual  as TotalizadorDetalhe4,
      _Creditos,
      _Fatura,
      _SumFatura,
      _Empresa,
      _RaizId,
      _Totais
}

