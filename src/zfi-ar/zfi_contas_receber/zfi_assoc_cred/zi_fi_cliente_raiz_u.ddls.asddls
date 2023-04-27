@AbapCatalog.sqlViewName: 'ZVFI_CLI_RAIZ'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Raiz CNPJ por Cliente'
define view ZI_FI_CLIENTE_RAIZ_U
  as select from kna1
{
  key kunnr as Cliente,
      case stcd1
        when ''
        then cast( left(stcd2,9) as char9 )
        else case stcd2 when '' then cast( left(stcd1,8) as char9 )
        end end as RaizId,
      name1 as Nome
} where stcd1 is not initial 

/* union

 select from kna1 {
     key cast('' as kunnr ) as Cliente,
         case stcd1
           when '' then cast( substring(stcd2,1,9) as char9 )
           else         cast( substring(stcd1,1,8) as char9 ) end
               as RaizId,
         cast('' as name1 ) as Nome
 }
 */
