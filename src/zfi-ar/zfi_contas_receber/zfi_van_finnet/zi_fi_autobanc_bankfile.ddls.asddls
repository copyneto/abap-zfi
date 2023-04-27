@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Autom. bancária - arquivos do banco'
define root view entity ZI_FI_AUTOBANC_BANKFILE
  as select from P_Arbanktransactiondocitem_06 as BankStmtItem
    inner join   P_FEBKO                       as BankStmtHeader
      on BankStmtHeader.ShortKey = BankStmtItem.StatementShortID
  association to ZI_FI_AUTOBANC_PART_ABERTO_CLI as _PartidasAbertoCliente
    on  $projection.CompanyCode  = _PartidasAbertoCliente.bukrs
    and $projection.FiscalYear   = _PartidasAbertoCliente.gjahr
    and $projection.DaybookEntry = _PartidasAbertoCliente.belnr
    and $projection.AcctItem     = _PartidasAbertoCliente.buzei
{

  key BankStmtItem.StatementShortID,
  key BankStmtItem.StatementItem,
      BankStmtItem.FiscalYear,
      BankStmtItem.PaymentExternalTransacType,
      BankStmtItem.DocumentReferenceID,
      BankStmtItem.DaybookEntry,
      BankStmtItem.ItemProcessingType,
      BankStmtItem.PaymentReference,
      cast( substring(BankStmtItem.PaymentReference, 9, 1) as buzei ) as AcctItem,
      BankStmtHeader.Application,
      BankStmtHeader.BankStatementId,
      BankStmtHeader.PayeeKeys,
      BankStmtHeader.CompanyCode,

      /*Associations*/
      _PartidasAbertoCliente
}

where
  (
       BankStmtItem.PaymentExternalTransacType = '09'
    or BankStmtItem.PaymentExternalTransacType = '27'
  )
  and  BankStmtItem.ItemProcessingType         = '11'
  and  BankStmtHeader.Application              = '0001'
