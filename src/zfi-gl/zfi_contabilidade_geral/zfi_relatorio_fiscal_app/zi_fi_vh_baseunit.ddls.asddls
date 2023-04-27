@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Filtro BaseUnit KG'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_FI_VH_BASEUNIT
  as select from dd07t as _Domain
{
      @ObjectModel.text.element: ['Descricao']
  key _Domain.domvalue_l as UnitKG,
      _Domain.ddtext     as Descricao
}
where
      _Domain.domname    = 'ZD_FILTR_KG'
  and _Domain.ddlanguage = $session.system_language
