@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Value Help Visualizar Relatório'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_FI_VH_VISUALREL
  as select from    dd07l as _Domain
    left outer join dd07t as _Text on  _Text.domname    = _Domain.domname
                                   and _Text.as4local   = _Domain.as4local
                                   and _Text.valpos     = _Domain.valpos
                                   and _Text.as4vers    = _Domain.as4vers
                                   and _Text.ddlanguage = $session.system_language
{

      @ObjectModel.text.element: ['Text']
      @UI.textArrangement: #TEXT_LAST
  key _Domain.domvalue_l as Value,
      _Text.ddtext       as Text

}
where
      _Domain.domname  = 'ZD_FI_TP_REL_CTA_PAG'
  and _Domain.as4local = 'A';
