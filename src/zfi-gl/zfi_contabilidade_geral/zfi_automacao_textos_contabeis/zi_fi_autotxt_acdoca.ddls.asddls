@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Automação txt contábeis-Documentos AF '
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_AUTOTXT_ACDOCA
  as select from    P_BKPF_COM as DocumentHeader

    left outer join acdoca     as DocumentItem
      on  DocumentHeader.bukrs = DocumentItem.rbukrs
      and DocumentHeader.belnr = DocumentItem.belnr
      and DocumentHeader.gjahr = DocumentItem.gjahr

  association [0..1] to P_GLAccountText        as _GLAccountText
    on  _GLAccountText.ChartOfAccounts = 'PC3C'
    and $projection.hkont              = _GLAccountText.GLAccount

  association [0..1] to I_Supplier             as _Supplier
    on $projection.lifnr = _Supplier.Supplier

  association [0..1] to I_Customer             as _Customer
    on $projection.kunnr = _Customer.Customer

  association        to ZI_FI_AUTOTXT_TREASURY as _Treasury
    on  $projection.bukrs = _Treasury.CompanyCode
    and $projection.belnr = _Treasury.AccountingDocument
    and $projection.gjahr = _Treasury.FiscalYear

{

  key DocumentHeader.bukrs,
  key DocumentHeader.belnr,
  key DocumentHeader.gjahr,
  key cast( ltrim( DocumentItem.docln, '0' ) as buzei ) as buzei,
      DocumentHeader.blart,
      DocumentItem.racct                                as hkont,
      DocumentItem.bschl,
      DocumentHeader.monat                              as monat,
      DocumentItem.rcntr                                as kostl,
      DocumentItem.lifnr,
      DocumentItem.kunnr,
      DocumentHeader.awkey,
      DocumentItem.sgtxt,
      DocumentItem.ebeln,
      _Supplier.SupplierName                            as LifnrName,
      _Customer.CustomerName                            as KunnrName,
      _GLAccountText.GLAccountName                      as HkontTxt,
      DocumentHeader.xblnr,
      DocumentHeader.budat,

      case when _Treasury.TreasuryUpdateType is not null then _Treasury.TreasuryUpdateType
      else ''
      end                                               as Dis_flowty,

      case when _Treasury.FinancialInstrumentProductType is not null then _Treasury.FinancialInstrumentProductType
      else ''
      end                                               as Gsart,

      /*Associations*/
      _GLAccountText,
      _Supplier,
      _Customer,
      _Treasury

}
where
  DocumentHeader.blart = 'AF'
