@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Help Search: Tipo de Documento'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity ZI_FI_VH_AUTOTXT_DOCTYPE
  as select from t003 as DocType
  association to t003t as _Text
    on  $projection.DocType = _Text.blart
    and _Text.spras         = $session.system_language
{
      @ObjectModel.text.element: ['Text']
      @Search.defaultSearchElement: true
  key blart       as DocType,
      @Search.defaultSearchElement: true
      _Text.ltext as Text
}
where
  blart <> 'AF'
