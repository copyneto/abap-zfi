@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Cockpit DDA'
@Metadata.allowExtensions: true
define root view entity ZI_FI_COCKPIT_DDA
  as select from ZI_FI_ERROR_DDA as ErrorDDA
  association [1..1] to ZI_FI_VH_ERRORREASONDDA as _Error on $projection.ErrReason = _Error.DomvalueL

{
  key       StatusCheck,
  key       case when Supplier <> '' then Supplier
                 else _Supplier.Supplier
                 end                                               as Supplier,
  key       ReferenceNo,
  key       case when DocNumber <> '' then cast( DocNumber as belnr_d preserving type )
            //                 when _MiroInvoice.AccountingDocument <> '' then cast( _MiroInvoice.AccountingDocument as belnr_d preserving type )
                 when AccountingDocument <> '' then cast( AccountingDocument as belnr_d preserving type )
                 else cast( '' as belnr_d )
            end                                                    as DocNumber,
  key       MiroInvoice,
  key       CompanyCode,
  key       FiscalYear,
  key       Cnpj,
  key       DueDate,
  key       DataArq,
            cast( concat( concat( substring(DueDate, 5, 4),
                                  substring(DueDate, 3, 2)
                          ),
                         substring(DueDate, 1, 2) ) as abap.dats ) as DueDateConverted,
            Amount,
            AmountNotConv,
            DueDateDoc,
            ErrorXblnr,
            Barcode,
            RecNum,
            Partner,
            IssueDate,
            PostingDate,
            ErrReason,
            Msg,
            ChaveReferencia,
            CnpjSemZero,
            _Company.CompanyCodeName                               as CompanyName,
            _Supplier.SupplierName                                 as SupplierName,
            CnpjSemZero                                            as SupplierCNPJ,
            _Supplier.TaxNumber2                                   as SupplierCPF,
            cast( ''  as abap.char(20))                            as CNPJFormat,
            cast( ''  as abap.char(20))                            as SupplierCNPJFormat,
            cast( ''  as abap.char(20))                            as SupplierCPFFormat,
            substring(CnpjSemZero, 1, 8)                           as SupplierCnpjRoot,
            Currency,
            DocComp,
            //            StatusCheck2,
            _Error.Text,

            //       Associations
            //            _MiroInvoice,

            ''                                                     as nfdiv_belnr,
            ''                                                     as nfdiv_buzei,

            _Company,
            _Supplier,
            _Error

}
