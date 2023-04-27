@AbapCatalog.sqlViewName: 'ZVFI_VHIDENT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Search Help Identificação'
define view ZI_FI_VH_IDENT
  as select from dd07l as Status
    join         dd07t as Text on  Text.domname  = Status.domname
                               and Text.as4local = Status.as4local
                               and Text.valpos   = Status.valpos
                               and Text.as4vers  = Status.as4vers

  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @ObjectModel.text.element: ['Descricao']
  key cast ( substring( Status.domvalue_l, 1, 1 ) as ze_ident preserving type ) as Identificacao,

      @Semantics.language: true
      @UI.hidden: true
  key cast( Text.ddlanguage as spras preserving type )                             as Language,

      substring ( Text.ddtext, 1, 60 )                                             as Descricao,

      // Association
      _Language
}
where
      Status.domname  = 'ZD_IDENT'
  and Status.as4local = 'A'
