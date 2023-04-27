@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Filtro por Unidade de Medidas'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_VH_BASEUNIT_FLT
  as select from ZI_FI_RELATORIO_FISCAL

  association [0..1] to t006a as _T006A on _T006A.msehi = $projection.BaseUnit
{
      @ObjectModel.text.element: ['Descricao']
  key BaseUnit     as BaseUnit,
      _T006A.msehl as Descricao,

      _T006A
}
where
  _T006A.spras = $session.system_language

group by
  BaseUnit,
  _T006A.msehl
