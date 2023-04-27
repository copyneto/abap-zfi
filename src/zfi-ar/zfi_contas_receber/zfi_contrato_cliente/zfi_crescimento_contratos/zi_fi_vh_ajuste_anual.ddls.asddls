@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Filtro Ajuste Anual'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_FI_VH_AJUSTE_ANUAL 
  as select from dd07t as _Domain
{
      @ObjectModel.text.element: ['Descricao']
  key _Domain.domvalue_l as XFLD,
      _Domain.ddtext     as Descricao
}
where
      _Domain.domname    = 'XFLD'
  and _Domain.ddlanguage = $session.system_language
