@AbapCatalog.sqlViewName: 'ZVFI_CREDATR'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Creditos Atribuidos'
define view ZI_FI_CREDATR
  as select from ZI_FI_PROG_CONC_CRED as a
    inner join   bsid_view            as b on  a.bukrs = b.bukrs
                                           and a.belnr = b.rebzg
                                           and a.gjahr = b.rebzj
                                           and a.buzei = b.rebzz
{
    a.blart,
    a.bschl,
    a.zlsch,
    b.bukrs, 
    b.rebzg, 
    b.rebzj, 
    b.rebzz
  } where rebzt  = 'G'
