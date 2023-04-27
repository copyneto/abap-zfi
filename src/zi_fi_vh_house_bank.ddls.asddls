@AbapCatalog.sqlViewName: 'ZIFI_HOUSEBANK'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Help Search: Banco da Empresa'
@Search.searchable: true
define view ZI_FI_VH_HOUSE_BANK
  as select from    t012  as HouseBank
    left outer join t012t as HouseBankText
      on  HouseBankText.spras = $session.system_language
      and HouseBank.bukrs     = HouseBankText.bukrs
      and HouseBank.hbkid     = HouseBankText.hbkid
{
      @Search.ranking: #MEDIUM
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key HouseBank.bukrs     as CompanyCode,
      @ObjectModel.text.element: ['BankText']
      @Search.ranking: #MEDIUM
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key HouseBank.hbkid     as HouseBankId,
      bankl               as BankId,
      HouseBankText.text1 as BankText
}
