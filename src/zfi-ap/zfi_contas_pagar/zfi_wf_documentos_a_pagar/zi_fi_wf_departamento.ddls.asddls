@AbapCatalog.sqlViewName: 'ZVFI_WFDEPART'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'WF - Responsabilidades -> Departamento'
define view ZI_FI_WF_DEPARTAMENTO
  as select from ztfi_wf_docpagar as Config
{
  key blart                 as DocumentType,
  key contador              as Counter,
      bktxt                 as DocumentText,

      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt
}
