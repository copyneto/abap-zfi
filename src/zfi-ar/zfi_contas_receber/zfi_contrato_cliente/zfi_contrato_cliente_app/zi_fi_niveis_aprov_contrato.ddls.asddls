@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Aprovadores contrato'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_NIVEIS_APROV_CONTRATO
  as select from    ztfi_cont_aprov           as _Aprov
    left outer join ZI_FI_CONTRATO_LINK_APROV as _Link on  _Link.DocUuidH     = _Aprov.doc_uuid_h
                                                       and _Link.DocUuidAprov = _Aprov.doc_uuid_aprov
                                                       and _Link.Nivel        = _Aprov.nivel

  association to parent ZI_FI_CONTRATO as _Contrato on $projection.DocUuidH = _Contrato.DocUuidH
{
  key _Aprov.doc_uuid_h     as DocUuidH,
  key _Aprov.doc_uuid_aprov as DocUuidAprov,
      _Aprov.nivel          as Nivel,
      _Aprov.nivel_atual    as NivelAtual,
      _Link.Bukrs,
      _Link.Branch,
      _Link.DescNivel,
      _Link.Aprovador,
      _Link.DataAprov,
      _Link.HoraAprov,
      _Link.Obs,
      _Contrato
}
