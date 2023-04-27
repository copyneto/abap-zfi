@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Header de Arquivo DDA'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity zi_fi_dda_header
  as select from ztfi_dda_header
{
  key bukrs       as Empresa,
  key hbkid       as Banco,
  key data_arq    as DataArquivo,
      arquivo     as NomeArquivo,
      cod_lote    as CodigoLote,
      cod_insc    as CodigoInscricao,
      num_insc    as NumeroInscricao,
      nome_emp    as NomeEmpresa,
      nome_ban    as NomeBanco,
      cod_arquivo as CodigoArquivo,
      dt_gerac    as DataGeracao,
      hr_gerac    as HoraGeracao,
      num_seq     as NumeroSequencial,
      layout      as LayoutArquivo
}
