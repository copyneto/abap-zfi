@AbapCatalog.sqlViewName: 'ZVFILOGAPVH'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Log Header'
define view ZI_FI_LOG_APV_PGTO_H
  as select from ztfi_log_apv_pgt
{
  key bukrs                         as Bukrs,
  key data                          as Data,
  key tiporel                       as Tiporel,
  key fdgrv                         as Fdgrv,
//  key fdgrv                         as GrpTesouraria,
  key hora                          as Hora,

      @Semantics.amount.currencyCode: 'Moeda'
      cast( sum( valor ) as dmbtr ) as Valor,
      cast( 'BRL' as waers_curc )   as Moeda,
      concat_with_space(
        enc_user,
        concat_with_space(
          Concat(
            Concat(
              Concat(substring(enc_data, 7, 2), '/'),
              Concat(substring(enc_data, 5, 2), '/')
            ),
            Substring(enc_data, 1, 4) )
          ,
          Concat(
            Concat(
              Concat(substring(enc_hora, 1, 2), ':'),
              Concat(substring(enc_hora, 3, 2), ':')
            ),
            Substring(enc_hora, 5, 2) )
         , 1),
      1)                            as Encerrador,
      //      concat_with_space(enc_user, concat_with_space(enc_data, enc_hora, 1), 1) as Encerrador,

      concat_with_space(
        ap1_user,
        concat_with_space(
          Concat(
            Concat(
              Concat(substring(ap1_data, 7, 2), '/'),
              Concat(substring(ap1_data, 5, 2), '/')
            ),
            Substring(ap1_data, 1, 4) )
          ,
          Concat(
            Concat(
              Concat(substring(ap1_hora, 1, 2), ':'),
              Concat(substring(ap1_hora, 3, 2), ':')
            ),
            Substring(ap1_hora, 5, 2) )
         , 1),
      1)                            as Aprov1,
      //      concat_with_space(ap1_user, concat_with_space(ap1_data, ap1_hora, 1), 1) as Aprov1,

      concat_with_space(
        ap2_user,
        concat_with_space(
          Concat(
            Concat(
              Concat(substring(ap2_data, 7, 2), '/'),
              Concat(substring(ap2_data, 5, 2), '/')
            ),
            Substring(ap2_data, 1, 4) )
          ,
          Concat(
            Concat(
              Concat(substring(ap2_hora, 1, 2), ':'),
              Concat(substring(ap2_hora, 3, 2), ':')
            ),
            Substring(ap2_hora, 5, 2) )
         , 1),
      1)                            as Aprov2,
      //      concat_with_space(ap2_user, concat_with_space(ap2_data, ap2_hora, 1), 1) as Aprov2,

      concat_with_space(
        ap3_user,
        concat_with_space(
          Concat(
            Concat(
              Concat(substring(ap3_data, 7, 2), '/'),
              Concat(substring(ap3_data, 5, 2), '/')
            ),
            Substring(ap3_data, 1, 4) )
          ,
          Concat(
            Concat(
              Concat(substring(ap3_hora, 1, 2), ':'),
              Concat(substring(ap3_hora, 3, 2), ':')
            ),
            Substring(ap3_hora, 5, 2) )
         , 1),
      1)                            as Aprov3
      //      concat_with_space(ap3_user, concat_with_space(ap3_data, ap3_hora, 1), 1) as Aprov3
}
where nao_pago = ''
  and encerrador = 'X' 
  and aprov1 = 'X'
  and aprov2 = 'X'
  and aprov3 = 'X'
group by
  bukrs,
  data,
  tiporel,
  fdgrv,
  hora,
  enc_user,
  enc_data,
  enc_hora,
  ap1_user,
  ap1_data,
  ap1_hora,
  ap2_user,
  ap2_data,
  ap2_hora,
  ap3_user,
  ap3_data,
  ap3_hora
  
