@EndUserText.label: 'Consumo Auto. Bancária arquivos do banco'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_FI_AUTOBANC_BANKFILE
  as projection on ZI_FI_AUTOBANC_BANKFILE
{
  key StatementShortID,
  key StatementItem,
      FiscalYear,
      PaymentExternalTransacType,
      DocumentReferenceID,
      DaybookEntry,
      ItemProcessingType,
      PaymentReference,
      AcctItem,
      Application,
      BankStatementId,
      PayeeKeys,
      CompanyCode,
      /* Associations */
      _PartidasAbertoCliente
}
