@AbapCatalog.sqlViewName: 'ZVAPVNVLUSER'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Log aprovação e níveis'
define view ZI_FI_APROV_NIVEL_S_USER_VALID
  as select distinct from ztfi_apvdrs_pgto as _Aprov
    inner join            ztfi_log_apv_pgt as _Log on _Log.bukrs = _Aprov.bukrs
{

  key _Aprov.bukrs,
  key _Log.fdgrv,
  key _Aprov.nivel,
  key _Aprov.uname,
  key data,
      //      hora,
      //      tiporel,
      encerrador,
      case when encerrador = 'X' then 3
           else 0 end          as encerradorcrit,
      case when encerrador = 'X' then 'Aprovado'
           else 'Pendente' end as encerradortext,
      aprov1,
      case when aprov1 = 'X' then 3
           else 0 end          as aprov1crit,
      case when aprov1 = 'X' then 'Aprovado'
           else 'Pendente' end as aprov1text,
      aprov2,
      case when aprov2 = 'X' then 3
           else 0 end          as aprov2crit,
      case when aprov2 = 'X' then 'Aprovado'
           else 'Pendente' end as aprov2text,
      aprov3,
      case when aprov3 = 'X' then 3
           else 0 end          as aprov3crit,
      case when aprov3 = 'X' then 'Aprovado'
           else 'Pendente' end as aprov3text
}
where
      _Aprov.endda >= $session.system_date
  and _Aprov.begda <= $session.system_date
