@AbapCatalog.sqlViewName: 'ZIFI_SAKNR_PC3C'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Help search contas plano PC3C'
@Search.searchable: true
define view ZI_FI_VH_SAKNR_PC3C
  as select from I_CostElementVH
{
  key GLAccount,
  key ChartOfAccounts,
  key CompanyCode,
      GLAccountLongName
}

where
  ChartOfAccounts = 'PC3C'
