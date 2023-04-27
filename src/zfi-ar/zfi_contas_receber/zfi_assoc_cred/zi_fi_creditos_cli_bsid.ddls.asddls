@AbapCatalog.sqlViewName: 'ZVFI_CRED_BSID'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Créditos de Clientes'
define view ZI_FI_CREDITOS_CLI_BSID  
  as select from bsid_view                      as bsid
    left outer join ZI_FI_LOGCONCRED_CONV as _LogCred on _LogCred.bukrs            = bsid.bukrs
                                                         and _LogCred.zcredito          = bsid.belnr
                                                         and _LogCred.zexerciciocredito = bsid.gjahr
                                                         and _LogCred.zitemcredito      = bsid.buzei  
  association [0..1] to bseg as _bseg                     on _bseg.bukrs = bsid.bukrs
                                                         and _bseg.belnr = bsid.belnr
                                                         and _bseg.gjahr = bsid.gjahr
                                                         and _bseg.buzei = bsid.buzei                                                            
                                                         
                                                         
{
  key bsid.bukrs,
  key bsid.belnr,
  key bsid.gjahr,
  key bsid.buzei,
      bsid.kunnr,
      bsid.blart,
      bsid.bschl,
      bsid.umskz,
      _bseg.netdt,
      bsid.zuonr,
      bsid.xblnr,
      bsid.budat,
      bsid.zlsch,
      bsid.zterm,
      bsid.waers,
      @Semantics.amount.currencyCode: 'waers'
      bsid.dmbtr,
      bsid.zbd1p,
      _bseg    
} where ( bsid.bschl = '11' or
          bsid.bschl = '19' )
  and _LogCred.mandt is null
