@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Interface Clientes Sem Contrato'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_SEM_CONTR_DDE
  as select from ztfi_sem_ctr_dde
  
  association [0..1] to ZI_FI_DIASEMANA       as _Semana   on $projection.DiaSemana = _Semana.Diasemana  
{
  key bukrs                 as Empresa,
  key kunnr                 as Cliente,
      kdkg1                 as GrpCondicoes,
      zjanmes               as DiaMes,
      zjansem               as DiaSemana,
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
      
      _Semana
}
