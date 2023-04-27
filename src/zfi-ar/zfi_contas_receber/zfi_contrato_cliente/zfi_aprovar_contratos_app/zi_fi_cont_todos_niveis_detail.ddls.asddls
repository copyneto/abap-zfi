@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Contratos para Aprovação - Detalhaes e Nivel Atual'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_CONT_TODOS_NIVEIS_DETAIL 
  as select from ZI_FI_CONT_TODOS_NIVEIS as _Contrato
  association [1] to ztfi_cont_aprov      as _Aprovacao  on  _Aprovacao.doc_uuid_h = _Contrato.DocUuidH
                                                         and _Aprovacao.contrato   = _Contrato.Contrato
                                                         and _Aprovacao.aditivo    = _Contrato.Aditivo
                                                         and _Aprovacao.nivel      = _Contrato.Nivel
  association [1] to ztfi_cont_aprov      as _NivelAtual on  _NivelAtual.doc_uuid_h  = _Contrato.DocUuidH
                                                         and _NivelAtual.contrato    = _Contrato.Contrato
                                                         and _NivelAtual.aditivo     = _Contrato.Aditivo
                                                         and _NivelAtual.nivel_atual = 'X'{
  key _Contrato.DocUuidH,
  key _Contrato.Contrato,
  key _Contrato.Aditivo,
  key _Aprovacao.doc_uuid_aprov,
      _Aprovacao.nivel_atual,
      case
        when _Contrato.Nivel > _NivelAtual.nivel  then 'X' 
        when _NivelAtual.nivel is null then 'X' 
        else  ''
      end as ProximosNiveis,
      _Contrato.Bukrs,
      _Contrato.Branch,
      _Contrato.Nivel,
      _Contrato.Bname,
      _Contrato.Email,
      _Contrato.DescNivel

}
