@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Interface - Ordem de Frete'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_ORDEM_FRETE
  as select from /scmtms/d_tordrf as _TorDrf
//  association to ZI_SD_MONITOR_EXEC as _Exec  on _Exec.ParentKey = $projection.ParentKey
  association to /scmtms/d_torrot   as _TorId on _TorId.db_key = $projection.ParentKey


{
  _TorDrf.parent_key         as ParentKey,
  right( _TorDrf.btd_id, 10) as Remessa,
  _TorId.tor_id              as OrdemFrete,
//  _Exec.ActualDate           as ActualDate,
//  _Exec.EventCode            as EventCode,
//  _Exec.ExtLocId             as ExtLocId,
  _TorDrf.btd_tco,
  _TorId.tor_cat

}
  where
      _TorDrf.btd_tco = '73'
  and _TorId.tor_cat  = 'FU'
