@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Search Help: Status Contabilização'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_FI_VH_STATUS_CONTABILIZACAO
  as select from dd07l as Object
    join         dd07t as Text on  Text.domname  = Object.domname
                               and Text.as4local = Object.as4local
                               and Text.valpos   = Object.valpos
                               and Text.as4vers  = Object.as4vers

  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @UI.textArrangement: #TEXT_ONLY
      @ObjectModel.text.element: ['ObjectName']
  key cast ( substring( Object.domvalue_l, 1, 1 ) as ze_visao preserving type ) as ObjectId,

      @Semantics.language: true
  key cast( Text.ddlanguage as spras preserving type )                          as Language,

      @UI.hidden: true
      substring ( Text.ddtext, 1, 60 )                                          as ObjectName,

      _Language
}
where
      Object.domname  = 'ZD_STATUS_CONTBILIZACAO'
  and Object.as4local = 'A'
