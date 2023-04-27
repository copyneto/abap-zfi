@AbapCatalog.sqlViewName: 'ZVLINKAPROVC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Unir aprovações com contrato'
define view ZI_FI_CONTRATO_LINK_APROV

  //  as select from ztfi_cont_aprov        as _Apro
  //
  //    inner join   ztfi_contrato          as _Con   on _Apro.doc_uuid_h = _Con.doc_uuid_h
  //
  //    inner join   zi_fi_nivel_aprov_cont as _Nivel on  _Nivel.Nivel  = _Apro.nivel
  //                                                  and _Nivel.Branch = _Con.branch
  //                                                  and _Nivel.Bukrs  = _Con.bukrs


  as select from    ztfi_contrato          as _Con
    inner join      zi_fi_nivel_aprov_cont as _Nivel on  _Nivel.Branch = _Con.branch
                                                     and _Nivel.Bukrs  = _Con.bukrs
    left outer join ztfi_cont_aprov        as _Apro  on  _Apro.doc_uuid_h = _Con.doc_uuid_h
                                                     and _Apro.nivel      = _Nivel.Nivel
{
  key _Con.doc_uuid_h      as DocUuidH,
  key _Apro.doc_uuid_aprov as DocUuidAprov,
  key _Nivel.Nivel         as Nivel,
      _Con.bukrs           as Bukrs,
      _Con.branch          as Branch,
      _Nivel.DescNivel     as DescNivel,
      _Apro.aprovador      as Aprovador,
      _Apro.data_aprov     as DataAprov,
      _Apro.hora_aprov     as HoraAprov,
      _Apro.observacao     as Obs
}
