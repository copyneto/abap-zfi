@AbapCatalog.sqlViewName: 'ZVFILOGAPVI'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Detalhes Log Aprovação de Pagamento'
define view ZI_FI_LOG_APV_PGTO_I
  as select from ztfi_log_apv_pgt as _Log
{
  key bukrs                       as Bukrs,
  key fdgrv                       as GrpTesouraria,
  key data                        as Data,
  key hora                        as Hora,
  key tiporel                     as TipoRelatorio,
      valor                       as Valor,
      cast( 'BRL' as waers_curc ) as Moeda,
      encerrador                  as Encerrador,
      enc_user                    as EncUser,
      enc_data                    as EncData,
      enc_hora                    as EncHora,
      aprov1                      as Aprov1,
      ap1_user                    as Ap1User,
      ap1_data                    as Ap1Data,
      ap1_hora                    as Ap1Hora,
      aprov2                      as Aprov2,
      ap2_user                    as Ap2User,
      ap2_data                    as Ap2Data,
      ap2_hora                    as Ap2Hora,
      aprov3                      as Aprov3,
      ap3_user                    as Ap3User,
      ap3_data                    as Ap3Data,
      ap3_hora                    as Ap3Hora,
      hbkid                       as Hbkid,

      cast( ap3_data as dodat )   as DataDownload,
      cast( ap3_hora as dotim )   as HoraDownload,

      case encerrador
        when 'X'
          then 3
        else 1
      end                         as EncerradorCrit,

      case aprov1
        when 'X'
          then 3
        else 1
      end                         as Aprov1Crit,

      case aprov2
        when 'X'
          then 3
        else 1
      end                         as Aprov2Crit,

      case aprov3
        when 'X'
          then 3
        else 1
      end                         as Aprov3Crit
}
