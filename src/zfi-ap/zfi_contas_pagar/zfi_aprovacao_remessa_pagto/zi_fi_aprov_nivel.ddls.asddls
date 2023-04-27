@AbapCatalog.sqlViewName: 'ZVAPVNVL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Log aprovação e níveis'
define view ZI_FI_APROV_NIVEL
  as select distinct from ztfi_apvdrs_pgto as _Aprov
  //    left outer join       zi_fi_log_apv_pgt as _Log on  _Aprov.bukrs = _Log.Bukrs
  //                                                    and _Aprov.nivel = _Log.NivelAtual
{
  key _Aprov.bukrs,
      //  key _Log.Fdgrv,
  key '' as Fdgrv,
  key _Aprov.nivel,
  key _Aprov.uname,
      '' as Data
      //      coalesce( _Log.Data, '' )   as Data,

      //      coalesce( Encerrador, ''  ) as Encerrador,
      //      case when Encerrador = 'X' then 3
      //           else 0 end             as encerradorcrit,
      //      case when Encerrador = 'X' then 'Aprovado'
      //           else 'Pendente' end    as encerradortext,
      //      Aprov1,
      //      case when Aprov1 = 'X' then 3
      //           else 0 end             as aprov1crit,
      //      case when Aprov1 = 'X' then 'Aprovado'
      //           else 'Pendente' end    as aprov1text,
      //      Aprov2,
      //      case when Aprov2 = 'X' then 3
      //           else 0 end             as aprov2crit,
      //      case when Aprov2 = 'X' then 'Aprovado'
      //           else 'Pendente' end    as aprov2text,
      //      Aprov3,
      //      case when Aprov3 = 'X' then 3
      //           else 0 end             as aprov3crit,
      //      case when Aprov3 = 'X' then 'Aprovado'
      //           else 'Pendente' end    as aprov3text
}
where
      _Aprov.endda >= $session.system_date
  and _Aprov.begda <= $session.system_date
//  and uname        = $session.user
