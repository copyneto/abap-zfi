@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Contratos que possuem niveis'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_CONT_TODOS_NIVEIS
  as select from ztfi_contrato as _Contrato
  association [1..1] to ZI_FI_NIVEIS_E_APROVADORES as _Aprovadores on  _Contrato.bukrs  = _Aprovadores.Bukrs
                                                                   and _Contrato.branch = _Aprovadores.Branch
  association [0..1] to ztfi_cont_aprov            as _Aprovacao   on  $projection.DocUuidH = _Aprovacao.doc_uuid_h
                                                                   and $projection.Contrato = _Aprovacao.contrato
                                                                   and $projection.Aditivo  = _Aprovacao.aditivo

{
  key doc_uuid_h             as DocUuidH,
  key contrato               as Contrato,
  key aditivo                as Aditivo,
      bukrs                  as Bukrs,
      branch                 as Branch,
      _Aprovadores.Nivel     as Nivel,
      _Aprovadores.Bname     as Bname,
      _Aprovadores.Email     as Email,
      _Aprovadores.DescNivel as DescNivel

}
where
      _Aprovadores.Bname != ''
  and _Aprovadores.Email != ''
