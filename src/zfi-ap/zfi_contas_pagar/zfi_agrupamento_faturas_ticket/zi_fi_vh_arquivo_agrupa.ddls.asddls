@AbapCatalog.sqlViewName: 'ZVFI_ARQAGRUP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Help search Arquivo agrupamento'
@Search.searchable: true
@ObjectModel.dataCategory: #VALUE_HELP
define view ZI_FI_VH_ARQUIVO_AGRUPA
  as select from ztfi_agrupfatura as Arquivo
{
      @UI.hidden: true
  key id_arquivo as IdArquivo,
      @Search.ranking: #HIGH
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.5
      @Semantics.text: true
      @UI.textArrangement: #TEXT_ONLY
      arquivo    as Arquivo
}
