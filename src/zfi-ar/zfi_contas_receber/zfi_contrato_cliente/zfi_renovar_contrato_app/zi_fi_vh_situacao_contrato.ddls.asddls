@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Value Help para Situação do Contrato'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Search.searchable: true
define view entity ZI_FI_VH_SITUACAO_CONTRATO   as select from    dd07l as _Domain
    left outer join dd07t as _Text on  _Text.domname    = _Domain.domname
                                   and _Text.as4local   = _Domain.as4local
                                   and _Text.valpos     = _Domain.valpos
                                   and _Text.as4vers    = _Domain.as4vers
                                   and _Text.ddlanguage = $session.system_language
{
      @ObjectModel.text.element: ['Texto']
      @Search.ranking: #MEDIUM
      @Search.fuzzinessThreshold: 0.6
  key _Domain.domvalue_l  as Situacao,
      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      @Search.fuzzinessThreshold: 0.7
      _Text.ddtext                             as Texto

}
where
      _Domain.domname  = 'ZD_SITUACAO';
