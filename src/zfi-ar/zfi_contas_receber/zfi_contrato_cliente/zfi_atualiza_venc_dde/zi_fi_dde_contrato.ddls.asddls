@AbapCatalog.sqlViewName: 'ZVFI_DDECTR'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Busca dados DDE Contrato'
define view ZI_FI_DDE_CONTRATO
  as select from    ztfi_contrato    as _Contrato
    inner join      ztfi_raiz_cnpj   as _Raiz   on  _Contrato.contrato = _Raiz.contrato
                                                and _Contrato.aditivo  = _Raiz.aditivo
    left outer join ztfi_cont_janela as _Janela on  _Contrato.contrato = _Janela.contrato
                                                and _Contrato.aditivo  = _Janela.aditivo
{
  _Contrato.contrato,
  _Contrato.aditivo,
  _Contrato.status,
  _Contrato.bukrs,
  left( _Raiz.cnpj_raiz, 8 ) as cnpjroot,
  _Janela.atributo_2         as classificacao,
  _Janela.familia_cl         as familia,
  _Janela.prazo,
  _Janela.dia_mes_fixo,
  _Janela.dia_semana

}
where
     _Contrato.status = '4'
  or _Contrato.status = '7'
  or _Contrato.status = '8'
