@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Interface - WF Log'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_WF_LOG
  as select from ztfi_wf_log as _Log

  association [0..1] to ZI_CA_VH_USER      as _User on $projection.Aprovador = _User.Bname
  association [0..1] to I_CompanyCodeVH    as _Emp  on $projection.Empresa = _Emp.CompanyCode
  association [0..1] to ZI_FI_WF_STATUS_SH as _Stat on $projection.StatusAprovacao = _Stat.StatusId

{
  key uuid                 as Uuid,
  key wf_id                as WfId,
  key aprovador            as Aprovador,
      nivel_aprovacao      as NivelAprovacao,
      task_id              as TaskId,
      _User.Text           as AprovadorDesc,
      data                 as Data,
      hora                 as Hora,
      empresa              as Empresa,
      _Emp.CompanyCodeName as EmpresaDesc,
      documento            as Documento,
      exercicio            as Exercicio,
      item                 as Item,
      status_aprovacao     as StatusAprovacao,
      _Stat.StatusName     as StatusDesc,
      case status_aprovacao
        when '1' then 3 // Positive - Green
        when '2' then 2 // Critical - Yellow
        when '3' then 3 // Positive - Green
        when '4' then 1 // Negative - Red
        when '5' then 1 // Negative - Red
        else 0
      end                  as StatusCriticality,

      _User,
      _Emp,
      _Stat

}
