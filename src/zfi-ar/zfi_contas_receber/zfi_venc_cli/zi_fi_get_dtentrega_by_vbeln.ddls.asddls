@AbapCatalog.sqlViewName: 'ZVFI_DTENT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Busca última data de entrega pela Fatura'
define view ZI_FI_GET_DTENTREGA_BY_VBELN
  as select distinct from vbrp                  as a
    inner join            ZI_FI_ENTREGA_TM_LAST as b on a.vgbel = b.Remessa
{
  a.vbeln,
  b.DataEntrega
}
