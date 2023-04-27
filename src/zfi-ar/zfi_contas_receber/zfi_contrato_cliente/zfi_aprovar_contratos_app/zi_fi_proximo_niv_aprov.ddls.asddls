@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Linha De Aprovação para o Proximo do Nível'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_PROXIMO_NIV_APROV
  as select from ZI_FI_PROXIMO_NIVEl as _Nivel
  
  association [1..1] to ZI_FI_CONT_TODOS_NIVEIS as _Contrato on  $projection.DocUuidH = _Contrato.DocUuidH
                                                             and $projection.Contrato = _Contrato.Contrato
                                                             and $projection.Aditivo  = _Contrato.Aditivo
                                                             and $projection.Nivel    = _Contrato.Nivel
{
  key DocUuidH,
  key Contrato,
  key Aditivo,
      Nivel,
      _Contrato.Bukrs,
      _Contrato.Branch,
      _Contrato.Bname,
      _Contrato.Email,
      _Contrato.DescNivel
}
where
  _Contrato.Bname = $session.user
