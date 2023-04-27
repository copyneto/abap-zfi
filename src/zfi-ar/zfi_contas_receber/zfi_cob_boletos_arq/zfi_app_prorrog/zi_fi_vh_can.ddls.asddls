@AbapCatalog.sqlViewName: 'ZVAP_CANREL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Valores fixos - filtro'


/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view ZI_FI_VH_CAN
  as select from dd07l
{

  key domvalue_l as Motivo

}
where
  domname = 'ZD_MOT_PRORROG'
