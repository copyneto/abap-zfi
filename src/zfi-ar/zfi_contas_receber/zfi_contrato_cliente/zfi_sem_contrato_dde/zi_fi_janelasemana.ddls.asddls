@AbapCatalog.sqlViewName: 'ZVFI_JANELASEM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Match Code Janela Semana'
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.dataCategory: #TEXT
define view ZI_FI_JANELASEMANA
  as select from dd07l as Status
    join         dd07t as Text on  Text.domname  = Status.domname
                               and Text.as4local = Status.as4local
                               and Text.valpos   = Status.valpos
                               and Text.as4vers  = Status.as4vers

  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @UI.textArrangement: #TEXT_ONLY
      @ObjectModel.text.element: ['Descricao']
  key cast ( substring( Status.domvalue_l, 1, 1 ) as ze_janelasemana preserving type ) as JanelaSemana,

      @Semantics.language: true
      @UI.hidden: true
  key cast( Text.ddlanguage as spras preserving type )                             as Language,

      @UI.hidden: true
      substring ( Text.ddtext, 1, 60 )                                             as Descricao,

      // Association
      _Language
}
where
      Status.domname  = 'ZD_JANELASEMANA'
  and Status.as4local = 'A'
