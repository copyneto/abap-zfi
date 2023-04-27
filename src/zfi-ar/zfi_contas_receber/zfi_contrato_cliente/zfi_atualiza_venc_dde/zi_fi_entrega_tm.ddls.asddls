@AbapCatalog.sqlViewName: 'ZVFI_ENTREGATM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Busca dados Entrega no TM'
define view ZI_FI_ENTREGA_TM
  as select from /scmtms/d_torrot as root
    inner join   /scmtms/d_torexe as exec on root.db_key = exec.parent_key
{
  right(root.base_btd_id, 10)                        as Remessa,
  left(cast( exec.actual_date as abap.char(20) ), 8) as DataEntrega
} where root.tor_cat = 'FU'
