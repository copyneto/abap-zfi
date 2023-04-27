@AbapCatalog.sqlViewName: 'ZVFI_SUPPDDA'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Fornecedor - busca por CNPJ sem zeros'
define view ZI_FI_SUPPLIER_DDA_CNPJ
  as select from I_Supplier as Supplier
{

  key Supplier,
      TaxNumber1,
      lpad(              TaxNumber1, 15, '0'      ) as CnpjComZeros

}
