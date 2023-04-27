@AbapCatalog.sqlViewName: 'ZVFI_PROVCOPA'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Busca dados para provisão CO-PA'
define view ZI_FI_GET_PROV_DATA
  as select distinct from P_BSEG_COM                 as _Doc
    inner join   I_BillingDocumentItemBasic as _Basic on _Doc.vbeln = _Basic.BillingDocument
{
  key _Doc.bukrs,
  key _Doc.belnr,
  key _Doc.gjahr,
  key _Doc.buzei,
  _Doc.kunnr                           as kndnr,
  _Basic.Plant                         as werks,
  _Basic.SalesOrderDistributionChannel as vtweg,
  _Basic.SalesOrderSalesDistrict       as bzirk,
  left(_Basic.ProfitCenter,2)          as wwmt1_aux
} where _Doc.vbeln <> ''
