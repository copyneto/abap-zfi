@AbapCatalog.sqlViewName: 'ZVFI_CAN_BANC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'View Documentos BSID_DLL'
define root view ZI_FI_DOC_CANC_BANC
  as select from bsid_view as A
    inner join   bsid_view as B on  A.bukrs = B.bukrs
                                and A.rebzg = B.belnr
                                and A.rebzj = B.gjahr
                                and A.rebzz = B.buzei
                                and A.dmbtr = B.dmbtr

{
  key A.bukrs,
  key A.belnr,
  key A.buzei,
  key A.budat,
  key A.gjahr,
      A.bldat,
      A.bschl,
      A.kunnr,
      A.dmbtr,
      A.wrbtr,
      A.blart,
      A.xblnr,
      A.zuonr,
      A.hbkid,
      A.zlsch,
      B.anfbn,
      A.waers,
      A.zfbdt,
      A.zbd1t,
      A.zbd2t,
      A.zbd3t,
      A.rebzg,
      A.rebzj,
      A.rebzz,
      cast ( 0 as verzn ) as Quantidade,
      B.dmbtr             as Val_Estorno

}
where
      A.bschl =  '11'
  and A.shkzg =  'H'
  and A.rebzg <> ''
  //  and A.anfbn <> ''
  and B.anfbn <> ''

group by
  A.bukrs,
  A.belnr,
  A.buzei,
  A.budat,
  A.gjahr,
  A.bldat,
  A.bschl,
  A.kunnr,
  A.dmbtr,
  A.wrbtr,
  A.blart,
  A.xblnr,
  A.zuonr,
  A.hbkid,
  A.zlsch,
  B.anfbn,
  A.waers,
  A.zfbdt,
  A.zbd1t,
  A.zbd2t,
  A.zbd3t,
  A.rebzg,
  A.rebzj,
  A.rebzz,
  B.dmbtr
