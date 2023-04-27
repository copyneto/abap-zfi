@AbapCatalog.sqlViewName: 'ZVFI_DDEDATA'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Busca dados DDE'
define view ZI_FI_DDE_DATA
  as select distinct from Fins_Sif_Bkpf               as bkpf
    inner join            bsid_view                   as bsid      on  bkpf.BUKRS = bsid.bukrs
                                                                   and bkpf.BELNR = bsid.belnr
                                                                   and bkpf.GJAHR = bsid.gjahr
    inner join            ZI_FI_GET_FAMILIA           as billbase  on billbase.BillingDocument = bsid.vbeln
    inner join            I_BillingDocExtdItemBasic   as bill      on  bill.BillingDocument     = billbase.BillingDocument
                                                                   and bill.BillingDocumentItem = billbase.item
    inner join            ZI_FI_ENTREGA_TM_LAST       as deliv     on bill.ReferenceSDDocument = deliv.Remessa
    inner join            ZI_CA_GET_KUNNR_BY_CNPJROOT as cnpj      on cnpj.Cliente = bsid.kunnr
    left outer join       I_CompanyCodeVH             as _Company  on _Company.CompanyCode = bkpf.BUKRS
    left outer join       kna1                        as _Customer on _Customer.kunnr = bsid.kunnr
    left outer join       I_PostingKeyText as _Chavetxt on bsid.bschl = _Chavetxt.PostingKey
                                                       and _Chavetxt.Language = $session.system_language

{

  key bkpf.BUKRS,
  key bkpf.BELNR,
  key bkpf.GJAHR,
  key bsid.buzei,
      bkpf.BUDAT,
      bkpf.BLDAT,
      bsid.kunnr,
      bsid.vbeln,
      bsid.zlsch,
      bill.ReferenceSDDocument           as vgbel,
      cast( deliv.DataEntrega as datum ) as dataentrega,
      cnpj.rootCnpj,
      _Company.CompanyCodeName,
      _Customer.name1,
      left(bill.ProfitCenter,2)          as familia,
      _Customer.katr2                    as classificacao,
      bsid.zuonr,
      bsid.gsber,
      bsid.xblnr,
      bsid.sgtxt,
      bsid.zlspr,
      bsid.zterm,
      bsid.mansp,
      bsid.zfbdt,
      bsid.zbd1t,
      bsid.zbd2t,
      bsid.zbd3t,
      bsid.dtws1,
      bsid.hbkid,
      bsid.xref3,
      _Customer.stcd1,
      _Customer.stcd2,
      bkpf.BKTXT,
      bkpf.XBLNR as xblnr2,
      bkpf.XREF1_HD,
      bkpf.XREF2_HD,
      bsid.bschl,
      _Chavetxt.PostingKeyName
}
where
      bkpf.XREF1_HD     =  ''
  and deliv.DataEntrega <> ''
