@AbapCatalog.sqlViewName: 'ZVNIVELAPC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Aprovadores contrato'
define view zi_fi_nivel_aprov_cont
  as select distinct from ztfi_cad_nivel   as _Nivel
    inner join            ztfi_cad_aprovad as _Aprovadores on _Aprovadores.nivel = _Nivel.nivel

{
  key _Nivel.nivel        as Nivel,
  key _Aprovadores.branch as Branch,
  key _Aprovadores.bukrs  as Bukrs,
      _Nivel.desc_nivel   as DescNivel
}
