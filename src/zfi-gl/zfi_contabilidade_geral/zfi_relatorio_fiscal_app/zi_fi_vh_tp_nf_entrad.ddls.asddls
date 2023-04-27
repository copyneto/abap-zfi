@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo de NF Entrada/Saída'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_FI_VH_TP_NF_ENTRAD
  as select from dd07t as _Domain
{
      @ObjectModel.text.element: ['Descricao']
  key _Domain.domvalue_l as Entrad,
      _Domain.ddtext     as Descricao
}
where
      _Domain.domname    = 'ZD_FILTR_ENTRADNF'
  and _Domain.ddlanguage = $session.system_language
