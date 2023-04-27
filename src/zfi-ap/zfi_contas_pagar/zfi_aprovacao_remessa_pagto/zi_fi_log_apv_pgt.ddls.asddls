@AbapCatalog.sqlViewName: 'ZVFILOGAPVPGT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Log de Aprovação dos Documentos'
define view zi_fi_log_apv_pgt
  as select from ztfi_log_apv_pgt
{
  key bukrs                     as Bukrs,
  key fdgrv                     as Fdgrv,
  key data                      as Data,
  @Semantics.time: true
  key hora  as Hora,
  key tiporel                   as Tiporel,
 cast( hora as abap.char(6) )  as dataConv,
      valor                     as Valor,
      encerrador                as Encerrador,
      enc_user                  as EncUser,
      enc_data                  as EncData,
      enc_hora                  as EncHora,
      aprov1                    as Aprov1,
      ap1_user                  as Ap1User,
      ap1_data                  as Ap1Data,
      ap1_hora                  as Ap1Hora,
      aprov2                    as Aprov2,
      ap2_user                  as Ap2User,
      ap2_data                  as Ap2Data,
      ap2_hora                  as Ap2Hora,
      aprov3                    as Aprov3,
      ap3_user                  as Ap3User,
      ap3_data                  as Ap3Data,
      ap3_hora                  as Ap3Hora,

      cast(
        case
          when aprov3 = 'X'     then '4'
          when aprov2 = 'X'     then '3'
          when aprov1 = 'X'     then '2'
          when encerrador = 'X' then '1'
          else '0'
        end as ze_nivel_aprov ) as NivelAtual
}
