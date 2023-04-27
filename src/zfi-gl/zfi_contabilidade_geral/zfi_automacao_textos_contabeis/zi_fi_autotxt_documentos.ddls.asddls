@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Automação textos contábeis - Documentos'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_AUTOTXT_DOCUMENTOS
  as select from P_BSEG_COM1 as DocumentItem
  association [0..1] to P_GLAccountText                as _GLAccountText  on  _GLAccountText.ChartOfAccounts = 'PC3C'
                                                                          and $projection.hkont              = _GLAccountText.GLAccount

  association [0..1] to ZI_FI_AUTOTXT_DOCCONTABIL_1ITM as _DocumentItem1  on  $projection.bukrs = _DocumentItem1.bukrs
                                                                          and $projection.belnr = _DocumentItem1.belnr
                                                                          and $projection.gjahr = _DocumentItem1.gjahr

  association [1]    to ZI_FI_AUTOTXT_DOCCONTABIL      as _DocumentHeader on  $projection.bukrs = _DocumentHeader.bukrs
                                                                          and $projection.belnr = _DocumentHeader.belnr
                                                                          and $projection.gjahr = _DocumentHeader.gjahr

  association [0..1] to I_Supplier                     as _Supplier       on  $projection.lifnr = _Supplier.Supplier

  association [0..1] to I_Customer                     as _Customer       on  $projection.kunnr = _Customer.Customer

  association        to ZI_FI_AUTOTXT_TREASURY         as _Treasury       on  $projection.bukrs = _Treasury.CompanyCode
                                                                          and $projection.belnr = _Treasury.AccountingDocument
                                                                          and $projection.gjahr = _Treasury.FiscalYear
                                                                          and $projection.buzei = _Treasury.AccountingItemBuzei

{

  key bukrs,
  key belnr,
  key gjahr,
  key buzei,
      h_blart                                        as blart,
      hkont,
      bschl,
      h_monat                                        as monat,
      kostl,
      lifnr,
      kunnr,
      awkey,
      sgtxt,
      ebeln,
      _Supplier.SupplierName                         as LifnrName,
      _Customer.CustomerName                         as KunnrName,
      _GLAccountText.GLAccountName                   as HkontTxt,

      case when h_blart = 'WL' then _DocumentHeader.BR_NFeNumber
      else _DocumentHeader.xblnr end                 as Xblnr,

      _DocumentHeader.budat,

      case when _Treasury.TreasuryUpdateType is not null then _Treasury.TreasuryUpdateType
      else ''
      end                                            as Dis_flowty,

      case when _Treasury.FinancialInstrumentProductType is not null then _Treasury.FinancialInstrumentProductType
      else ''
      end                                            as Gsart,

      left ( _DocumentHeader.bktxt, 13 )             as bktxt,
      cast( _DocumentItem1.projk as abap.char( 24 )) as projk, -- Aplicaremos exit de conversão no programa
      _DocumentItem1.aufnr                           as aufnr,

      /*Associations*/
      _DocumentHeader,
      _GLAccountText,
      _Supplier,
      _Customer,
      _Treasury

}
