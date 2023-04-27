@AbapCatalog.sqlViewName: 'ZVFI_PRCAGRPSTAT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Status agrupamento item'
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.dataCategory: #TEXT
define view ZI_FI_VH_AGRUPA_ITEM_STATUS
  as select from dd07l as Domain
  association to dd07t as _Text
    on  $projection.Domname  = _Text.domname
    and $projection.As4local = _Text.as4local
    and $projection.Valpos   = _Text.valpos
    and $projection.As4vers  = _Text.as4vers
    and _Text.ddlanguage     = $session.system_language
{
      @UI.hidden: true
  key domname                                                  as Domname,
      @UI.hidden: true
  key as4local                                                 as As4local,
      @UI.hidden: true
  key valpos                                                   as Valpos,
      @UI.hidden: true
  key as4vers                                                  as As4vers,

      @UI.textArrangement: #TEXT_ONLY
      @ObjectModel.text.element: [ 'StatusText' ]
  key cast(LEFT( domvalue_l, 1 ) as ze_fi_status_proc_agrupa ) as StatusId,

      @UI.hidden: true
      @Semantics.text:true
      _Text.ddtext                                             as StatusText,
      @UI.hidden: true
      domvalue_h                                               as DomvalueH,
      @UI.hidden: true
      appval                                                   as Appval

}
where
      domname  = 'ZD_FI_STATUS_PROC_AGRUPA'
  and as4local = 'A'
