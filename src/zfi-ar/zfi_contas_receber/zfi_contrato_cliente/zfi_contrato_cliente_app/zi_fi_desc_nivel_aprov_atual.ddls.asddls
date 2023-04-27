@AbapCatalog.sqlViewName: 'ZVFINIVELDESC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Descrição do nivel de aprovação atual do contrato'
define view ZI_FI_DESC_NIVEL_APROV_ATUAL
  as select from    ZI_FI_PROXIMO_NIVEl
    left outer join ztfi_cad_nivel on ZI_FI_PROXIMO_NIVEl.Nivel = ztfi_cad_nivel.nivel
{

  key ztfi_cad_nivel.nivel      as Nivel,
  key ZI_FI_PROXIMO_NIVEl.DocUuidH,
      ztfi_cad_nivel.desc_nivel as DescNivel

}
