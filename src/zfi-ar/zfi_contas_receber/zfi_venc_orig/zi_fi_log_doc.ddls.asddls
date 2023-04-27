@AbapCatalog.sqlViewName: 'ZV_FI_LOG_DOC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Log Documentos FI'
define view ZI_FI_LOG_DOC
  as select from ZI_FI_LOG_DOC_AUX as hd
    inner join   cdpos as it on hd.changenr = it.changenr
                             and hd.objectid = it.objectid 
                             and hd.tabkey = it.tabkey
                             and hd.fname  = it.fname
{

  key hd.objectid,
  key it.tabkey,
  key it.fname,
  it.changenr,
  it.value_old

}
  
