@AbapCatalog.sqlViewName: 'ZVHGSBER'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Divisão'
define view ZI_FI_VH_GSBER
  as select from tgsbt
{
  key spras as Spras,
  key gsber as Gsber,
      gtext as Gtext
}

where
  spras = $session.system_language
