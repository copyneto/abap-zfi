@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo de Processamento da NF'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_FI_VH_TP_PROCESS_NF
  as select from dd07t as _Domain
{
      @ObjectModel.text.element: ['Descricao']
  key _Domain.domvalue_l as TpProcNF,
      _Domain.ddtext     as Descricao
}
where
      _Domain.domname    = 'ZD_FILTR_TPPRCNF'
  and _Domain.ddlanguage = $session.system_language
