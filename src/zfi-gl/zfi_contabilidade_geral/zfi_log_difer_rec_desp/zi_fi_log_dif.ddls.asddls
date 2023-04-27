@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Interface - Log Diferimento'
define root view entity ZI_FI_LOG_DIF
  as select from ztfi_log_dif

  association [0..1] to zi_fi_log_difer_vh_status as _Status on _Status.DomvalueL = $projection.Status
  composition [1..*] of ZI_FI_LOG_MSG           as _Mensagens
{
  key bukrs        as Empresa,
  key belnr        as NumDoc,
  key gjahr        as Ano,
      _Status.Text as StatusText,

      case status
        when 'S' then 3
      end          as StatusCriticality,

      status       as Status, 
      usuario      as Usuario,
      dt_exec      as DtExec,
      hr_exec      as HrExec,
      text         as Descricao,
      
      _Mensagens
}
