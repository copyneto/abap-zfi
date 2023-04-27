@AbapCatalog.sqlViewName: 'ZVFI_KDKG1'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Grupo de condigução'
define view ZI_FI_CLIENTE_KDKG1
  as select from    kna1   as _Kna1
    left outer join tvkggt as _Desc on _Kna1.kdkg1 = _Desc.kdkgr
{

  key kunnr       as Kunnr,
      kdkg1       as Kdkg1,
      _Desc.vtext as Vtext
}
where
  _Desc.spras = $session.system_language
