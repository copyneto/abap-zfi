@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Log Diferimento - Header'
define root view entity ZI_FI_LOG_DIFER_H
  as select from ztfi_log_difer_h
  association [1..1] to I_CompanyCode             as _CompanyCode on _CompanyCode.CompanyCode = $projection.Empresa

  composition [1..*] of ZI_FI_LOG_DIFER_D         as _LOG_DIFER_D
  composition [1..*] of ZI_FI_LOG_DIFER_M         as _LOG_DIFER_M
  association [0..*] to zi_fi_log_difer_vh_status as _vh_status   on $projection.Status = _vh_status.DomvalueL

{
      @EndUserText.label: 'Identificador do Log'
  key id_log                as IdLog,
      empresa               as Empresa,
      @EndUserText.label: 'Dt.Lanç Informada'
      datalanc              as Datalanc,
      @EndUserText.label: 'Dt.Estorno Informada'
      dataestorno           as Dataestorno,
      gjahr                 as Gjahr,
      @EndUserText.label: 'Doc. Cliente Vs Receita'
      belnr_rec_cli         as BelnrRecCli,
      @EndUserText.label: 'Doc. Razão Vs Razão'
      belnr_raz_raz         as BelnrRazRaz,
      @EndUserText.label: 'Descrição'
      descricao             as Descricao,
      @EndUserText.label: 'Status Execução'
      status                as Status,
      case status
        when '0'  then 0
        when '1'  then 2
        when '2'  then 3
        when '3'  then 1
                  else 0
      end                   as StCor,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _CompanyCode, // Make association public
      _LOG_DIFER_D,
      _LOG_DIFER_M,
      _vh_status.Text       as StText
}
