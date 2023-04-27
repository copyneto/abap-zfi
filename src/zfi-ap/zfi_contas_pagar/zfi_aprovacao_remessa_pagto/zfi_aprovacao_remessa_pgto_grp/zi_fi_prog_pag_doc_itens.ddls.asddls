@AbapCatalog.sqlViewName: 'ZVPROGPAGITM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'itens'
define view ZI_FI_PROG_PAG_DOC_Itens
  as select distinct from ZI_FI_PROG_PAG_DOC as _Itens
  association        to I_CompanyCodeVH     as _Company  on  _Company.CompanyCode = $projection.CompanyCode
  association        to I_SupplierCompany   as _Supplier on  _Supplier.CompanyCode       = $projection.CompanyCode
                                                         and _Supplier.Supplier          = $projection.Supplier
                                                         and _Supplier.CashPlanningGroup = $projection.CashPlanningGroup
  association        to I_PlanningGroupText as _Planning on  _Planning.CashPlanningGroup = $projection.CashPlanningGroup
                                                         and _Planning.Language          = $session.system_language
  association        to ZI_FI_VH_TIPOREL    as _RepType  on  _RepType.Value = $projection.RepType
  association        to ZI_CA_VH_DOCTYPE    as _DocType  on  _DocType.DocType = $projection.DocType
  association        to P_BusinessPlace     as _Branch   on  _Branch.branch = $projection.Branch
                                                         and _Branch.bukrs  = $projection.CompanyCode
  association [1..1] to ZI_CA_VH_HBKID      as _Bank     on  $projection.HouseBank   = _Bank.BancoEmpresa
                                                         and $projection.CompanyCode = _Bank.Empresa
  association [1..1] to ZI_CA_VH_ZLSCH      as _PmntMtd  on  $projection.PaymentMethod = _PmntMtd.FormaPagamento

{
      @ObjectModel.text.element: ['CompanyCodeName']
  key CompanyCode,
      @ObjectModel.text.element: ['CashPlanningGroupName']
  key CashPlanningGroup,
  key NetDueDate,
      @ObjectModel.text.element: ['RepTypeText']
  key RepType,
      @ObjectModel.text.element: ['SupplierFullName']
  key Supplier,
  key PaymentDocument,
  key AccountingDocument,
  key AccountingDocumentItem,
  key FiscalYear,
      PaymentRunID,
      RunHourTo,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      PaidAmountInPaytCurrency,
      PaymentCurrency,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      cast( OpenAmount as ze_aberto )       as OpenAmount,
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      cast( BlockedAmount as ze_bloqueado ) as BlockedAmount,
      ItemStatus,
      @ObjectModel.text.element: ['HouseBankText']
      HouseBank,
      @ObjectModel.text.element: ['FormaPagamentoText']
      PaymentMethod,

      Bstat,
      Umskz,
      Amount,
      @ObjectModel.text.element: ['DocTypeText']
      DocType,
      @ObjectModel.text.element: ['BranchText']
      Branch,
      Reference,

      _Company.CompanyCodeName,
      _Supplier._Supplier.SupplierFullName,
      _Planning.CashPlanningGroupName,
      _RepType.Text                         as RepTypeText,
      _DocType.Text                         as DocTypeText,
      _Branch.name                          as BranchText,
      _Bank.BancoEmpresaText                as HouseBankText,
      _PmntMtd.FormaPagamentoText,

      _Company,
      _Supplier,
      _Planning,
      _RepType,
      _DocType,
      _Branch,
      _Bank,
      _PmntMtd
}
