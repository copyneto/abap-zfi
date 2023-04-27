@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Autom. textos contábeis-Execução manual'
define root view entity ZI_FI_AUTOTXT_EXEC_MANUAL
  as select from ztfi_autotxt_exe

{
  key id                    as Id,
      jobname               as Jobname,
      bukrs_ini             as CompanyCodeStart,
      bukrs_fim             as CompanyCodeEnd,
      gjahr_ini             as FiscalYearStart,
      gjahr_fim             as FiscalYearEnd,
      budat_ini             as PostingDateStart,
      budat_fim             as PostingDateEnd,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt,
      cast ( 'X' as xfeld ) as ExecutaJob
}
