@AbapCatalog.sqlViewName: 'ZV_GRPCOND'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Grupo Condições: Contrato Cliente'
define view ZI_FI_GRP_COND
  as select from tvkggt
{
  key kdkgr as Kdkgr,
      vtext as Vtext
}
where
  spras = $session.system_language
