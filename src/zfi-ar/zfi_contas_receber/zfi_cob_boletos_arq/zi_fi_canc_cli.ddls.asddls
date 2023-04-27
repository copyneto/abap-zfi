@AbapCatalog.sqlViewName: 'ZVFI_CANC_CLI'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'View cancelamento por cliente'

define root view ZI_FI_CANC_CLI
  as select from    bsid_view as A
    inner join      bsid_view as B on  A.bukrs =  B.bukrs
                                   and A.belnr =  B.belnr
                                   and A.buzei =  B.buzei
                                   and A.gjahr =  B.gjahr
                                   and B.anfbn <> ''
    inner join      kna1      as c on c.kunnr = A.kunnr
    left outer join mhnd      as d on d.kunnr = A.kunnr
{
  key A.bukrs,
  key A.belnr              as belnr,
  key A.buzei,
      //  key A.budat,
  key A.gjahr,
      A.bldat,
      A.bschl,
      A.rebzg,
      A.kunnr,
      A.dmbtr,
      A.wrbtr,
      A.blart,
      A.xblnr,
      A.zuonr,
      A.hbkid,
      A.zlsch,
      A.anfbn,
      A.waers,
      A.zfbdt,
      A.zbd1t,
      A.zbd2t,
      A.zbd3t,
      cast ( 0 as verzn )  as Quantidade,
      c.name1,
      @ObjectModel.virtualElement: true
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCLFI_DIAS_ATRASO'
      //@ObjectModel.sort.transformedBy: 'ABAP:ZCLFI_FILTER_ATRASO'
      cast ( 0 as verz1  ) as diasAtra
}
where
      A.bschl = '01'
  and A.shkzg = 'S'
