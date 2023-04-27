@AbapCatalog.sqlViewName: 'ZVFIVHKATEGORIE'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Categoria do Processo'
@Search.searchable: true

@ObjectModel.semanticKey: 'Kategorie'
@ObjectModel.usageType.dataClass: #MASTER
@ObjectModel.usageType.serviceQuality: #C
@ObjectModel.usageType.sizeCategory: #S

@ClientHandling.algorithm: #SESSION_VARIABLE

define view ZI_FI_VH_KATEGORIE
  as select from dd07v
{
      @UI.hidden: true
  key domname    as Domname,
      @UI.hidden: true
  key ddlanguage as Ddlanguage,
      @UI.hidden: true
  key valpos     as Valpos,
      @ObjectModel.text.element: ['KategorieText']
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.7 }
      domvalue_l as Kategorie,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.7 }
      @Semantics.text: true
      ddtext     as KategorieText
}
where
      domname    = 'CKML_KATEGORIE'
  and ddlanguage = $session.system_language
