@AbapCatalog.sqlViewName: 'ZV_FI_BOL_EMAIL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Dados para preencher o boleto'
define view ZV_FI_BOLETO_EMAIL 

as select from bsid_view as a 
inner join FNDEI_KNA1_FILTER as b
on a.kunnr = b.KUNNR
{
  a.bukrs,
  a.belnr,
  a.gjahr,
  a.buzei,
  a.kunnr,
  b.STCD1
}
where b.STCD1 is not initial
