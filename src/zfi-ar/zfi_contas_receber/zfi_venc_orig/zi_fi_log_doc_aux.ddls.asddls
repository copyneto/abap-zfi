@AbapCatalog.sqlViewName: 'ZV_FI_LOG_DOCX'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS Auxiliar ZI_FI_LOG_DOC'
define view ZI_FI_LOG_DOC_AUX as select from cdhdr as hd
    inner join   cdpos as it on hd.changenr = it.changenr 
{

  key hd.objectid,
  key it.tabkey,
  key it.fname,
  min(hd.changenr) as changenr
//  it.value_old

}
where
      hd.objectclas = 'BELEG'
  and it.tabname    = 'BSEG'
  group by hd.objectid, tabkey ,fname
