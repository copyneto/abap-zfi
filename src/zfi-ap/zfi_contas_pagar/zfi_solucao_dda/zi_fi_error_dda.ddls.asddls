@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Log de erros DDA'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZI_FI_ERROR_DDA
  as select from    j1b_error_dda           as ErrorDDA
    left outer join ZI_FI_SUPPLIER_DDA_CNPJ as SupplierCNPJ on ErrorDDA.cnpj = SupplierCNPJ.CnpjComZeros
    left outer join ZI_FI_MIRO_INVOICE_DDA  as _MiroInvoice on  ErrorDDA.bukrs        = _MiroInvoice.CompanyCode
                                                            and ErrorDDA.gjahr        = _MiroInvoice.FiscalYear
                                                            and ErrorDDA.doc_num      = _MiroInvoice.AccountingDocument
                                                            and ErrorDDA.reference_no = _MiroInvoice.DocumentReferenceID
    left outer join ztfi_error_xblnr        as xblnrError   on  ErrorDDA.bukrs        = xblnrError.bukrs
                                                            and ErrorDDA.gjahr        = xblnrError.gjahr
                                                            and ErrorDDA.cnpj         = xblnrError.cnpj
                                                            and ErrorDDA.due_date     = xblnrError.due_date
                                                            and ErrorDDA.reference_no = xblnrError.reference_no
    left outer join ztfi_ddaerror_cp        as ddaerror     on  ddaerror.bukrs = ErrorDDA.bukrs
                                                            and ddaerror.gjahr = ErrorDDA.gjahr
                                                            and ddaerror.belnr = ErrorDDA.doc_num
    left outer join bseg                    as _Vec         on  ErrorDDA.bukrs   = _Vec.bukrs
                                                            and ErrorDDA.gjahr   = _Vec.gjahr
                                                            and ErrorDDA.doc_num = _Vec.belnr
                                                            and _Vec.buzei       = '001'
  //                                                            and ddaerror.belnr = ErrorDDA.doc_num


  association [0..1] to I_CompanyCode as _Company  on $projection.CompanyCode = _Company.CompanyCode

  association [0..1] to I_Supplier    as _Supplier on $projection.CnpjSemZero = _Supplier.TaxNumber1
{
  key ErrorDDA.id                                                                    as ErrorId,
  key ErrorDDA.status_check                                                          as StatusCheck,
  key case when ErrorDDA.lifnr is not initial then ErrorDDA.lifnr
           when SupplierCNPJ.Supplier is not initial then SupplierCNPJ.Supplier
           else ''
      end                                                                            as Supplier,
  key ErrorDDA.reference_no                                                          as ReferenceNo,
  key ErrorDDA.doc_num                                                               as DocNumber,
  key ErrorDDA.miro_invoice                                                          as MiroInvoice,
  key ErrorDDA.bukrs                                                                 as CompanyCode,
  key ErrorDDA.gjahr                                                                 as FiscalYear,
  key ErrorDDA.cnpj                                                                  as Cnpj,
  key ErrorDDA.due_date                                                              as DueDate,
      @Semantics.amount.currencyCode: 'Currency'
      cast( division( cast( ErrorDDA.amount as abap.dec(15,2) ), 100, 2)  as wrbtr ) as Amount,

      ErrorDDA.amount                                                                as AmountNotConv,

      _Vec.netdt                                                                     as DueDateDoc,
      case
        when xblnrError.gjahr is not null and xblnrError.gjahr is not initial
           then   'X'
        else '' end                                                                  as ErrorXblnr,

      ErrorDDA.barcode                                                               as Barcode,
      ErrorDDA.rec_num                                                               as RecNum,
      ErrorDDA.partner                                                               as Partner,
      ErrorDDA.issue_date                                                            as IssueDate,
      ErrorDDA.posting_date                                                          as PostingDate,
      ErrorDDA.err_reason                                                            as ErrReason,
      //      case
      //      when ErrorDDA.reference_no != _MiroInvoice.DocumentReferenceID then 'V'
      //                                                                     else ErrorDDA.err_reason   end  as ErrReason,
      ErrorDDA.msg                                                                   as Msg,
      concat( ErrorDDA.miro_invoice, ErrorDDA.gjahr )                                as ChaveReferencia,
      cast( ErrorDDA.posting_date as abap.char(8) )                                  as DataArq,
      ltrim( ErrorDDA.cnpj, '0' )                                                    as CnpjSemZero,
      ddaerror.doc_comp                                                              as DocComp,
      _MiroInvoice.Currency,
      _MiroInvoice.AccountingDocument,

      //      case
      //      when ErrorDDA.reference_no != _MiroInvoice.DocumentReferenceID then 'E'
      //                                                                     else ErrorDDA.status_check  end as StatusCheck2,

      // Associations
      //      _MiroInvoice,
      _Company,
      _Supplier
}
