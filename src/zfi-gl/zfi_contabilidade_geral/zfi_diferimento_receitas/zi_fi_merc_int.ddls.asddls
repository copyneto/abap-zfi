@AbapCatalog.sqlViewName: 'ZVFI_MER_INT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS View Mercado Interno'
define view ZI_FI_MERC_INT
  as select from P_BKPF_COM             as Cabec

    inner join   I_BillingDocumentBasic as BillingDocBasic on  BillingDocBasic.AccountingDocument  =  Cabec.awkey
                                                           and BillingDocBasic.BillingDocumentType <> 'Z002'

    inner join   vbfa                   as FluxoRemessa    on  FluxoRemessa.vbeln   = BillingDocBasic.BillingDocument
                                                           and FluxoRemessa.vbtyp_v = 'J'

  association [0..*] to ZI_FI_BillingDocExtd as BillingDocExtdItemBasic on BillingDocBasic.BillingDocument = BillingDocBasic.BillingDocument

{
  key bukrs                               as CompanyCode,
  key belnr                               as DocContabil,
  key gjahr                               as Exercicio,
      blart                               as DocType,
      bldat                               as DtLancamentoContab,
      budat                               as DtLancamento,
      awkey                               as RefKey,
      BillingDocBasic.AccountingDocument  as AccountingDoc,
      BillingDocBasic.BillingDocument     as BillingDoc,
      BillingDocBasic.BillingDocumentType as BillingDocType,
      BillingDocBasic.BillingDocumentDate as BillingDocDate,
      BillingDocBasic.PayerParty          as PayerParty,
      FluxoRemessa.vbelv                  as Remessa,
      BillingDocExtdItemBasic

}
