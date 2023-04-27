@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Fornecedor Agrupador'
define root view entity ZI_FI_FORN_AGRUPADOR
  as select from ztfi_forn_grp as Agrupador

  association [1]    to ZI_CA_VH_COMPANY as _Company
    on $projection.CompanyCode = _Company.CompanyCode

  association [0..1] to I_Supplier_VH    as _Supplier
    on $projection.FornAgrupador = _Supplier.Supplier

  association [0..1] to ZI_CA_VH_DOCTYPE as _DocType
    on $projection.DocumentType = _DocType.DocType

{
  key id                     as IdFornAgrupador,
      forn_agrupador         as FornAgrupador,
      bukrs                  as CompanyCode,
      hkont                  as AccountNumber,
      blart                  as DocumentType,

      @Semantics.user.createdBy: true
      created_by             as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at             as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by        as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at        as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at  as LocalLastChangedAt,

      _Supplier.SupplierName as FornAgrupadorNome,

      _DocType.Text          as DocTypeText,

      /* Associations */
      _Company,
      _Supplier,
      _DocType

}
