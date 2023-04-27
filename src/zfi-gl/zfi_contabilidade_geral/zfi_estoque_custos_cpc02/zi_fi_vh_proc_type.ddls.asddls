@AbapCatalog.sqlViewName: 'ZVFIVHPROCTYPE'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipos de Processo'
@Search.searchable: true

@ObjectModel.semanticKey: 'Ptyp'
@ObjectModel.usageType.dataClass: #MASTER
@ObjectModel.usageType.serviceQuality: #C
@ObjectModel.usageType.sizeCategory: #S

@ClientHandling.algorithm: #SESSION_VARIABLE

define view ZI_FI_VH_PROC_TYPE
  as select from ckmlmv009t
{
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.7 }
      @ObjectModel.text.element: ['Ktext']
  key ptyp  as Ptyp,
      @UI.hidden: true
  key spras as Spras,
      @Semantics.text: true
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.7 }
      ktext as Ktext,
      @UI.hidden: true
      ptyps as Ptyps
}
where
  spras = $session.system_language
