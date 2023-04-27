@AbapCatalog.sqlViewName: 'ZVFI_FORNAGRUP'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Help search Fornecedor agrupador'
@Search.searchable: true
define view ZI_FI_VH_FORN_AGRUPADOR
  as select distinct from ztfi_forn_grp    as FornAgrupador

    inner join            I_Supplier_VH    as Fornecedor
      on FornAgrupador.forn_agrupador = Fornecedor.Supplier

    inner join            ZI_CA_VH_COMPANY as Company
      on FornAgrupador.bukrs = Company.CompanyCode

{
      //      @ObjectModel.text.element: ['NomeFornAgrupador']
      @Search.ranking: #MEDIUM
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key FornAgrupador.forn_agrupador as FornAgrupador,
      //      @ObjectModel.text.element: ['CompanyCodeName']
      @Search.ranking: #MEDIUM
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key FornAgrupador.bukrs          as CompanyCode,

      Fornecedor.SupplierName      as NomeFornAgrupador,
      Company.CompanyCodeName

}
