@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'trailer do lote de arquivo DDA'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity zi_fi_dda_trailer_lote
  as select from ztfi_dda_trail
{
  key bukrs    as Empresa,
  key hbkid    as Banco,
  key data_arq as DataArquivo,
  key cod_lote as CodigoLote,
      qtd_reg  as QuantidadeRegistros,
      vlr_tit  as ValorTitulos
}
