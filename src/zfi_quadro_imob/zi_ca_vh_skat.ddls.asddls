@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Help search skat'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Search.searchable: true
define view entity Zi_ca_vh_skat
  as select from ska1
  association to skat as _Text on  _Text.spras = $session.system_language
                               and _Text.ktopl = $projection.Ktopl
                               and _Text.saknr = $projection.Saknr
{
      //      @UI.hidden: true
      //  key spras as Spras,
      //      @UI.hidden: true
      @Search.ranking: #MEDIUM
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key ktopl       as Ktopl,
      @ObjectModel.text.element: ['Text']
      @Search.ranking: #MEDIUM
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key saknr       as Saknr,
      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      @Search.fuzzinessThreshold: 0.7
      _Text.txt20 as Text,

      _Text
}
