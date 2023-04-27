@AbapCatalog.sqlViewName: 'ZVFI_DOCCRED'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Busca documentos de créditos referentes a fatura'
define view ZI_FI_GET_DOC_CRED
  as select from bsid_view
{
  key   rebzg,
  key   rebzj,
  key   rebzz,
  key   bukrs,
        //  key kunnr,
        //  key umsks,
        //  key umskz,
        //  key augdt,
        //  key augbl,
        //  key zuonr,
        //        belnr,
        //        gjahr,
        //        buzei,
        sum(dmbtr) as dmbtr


}
group by
  bukrs,
  rebzg,
  rebzj,
  rebzz
