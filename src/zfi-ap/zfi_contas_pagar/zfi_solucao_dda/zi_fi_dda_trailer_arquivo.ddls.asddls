@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Trailer do arquivo DDA'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity zi_fi_dda_trailer_arquivo
  as select from ztfi_dda_tr_file
{
  key bukrs     as Empresa,
  key hbkid     as Banco,
  key data_arq  as DataArquivo,
      tot_lotes as TotalLotes,
      tot_reg   as TotalRegistros
}
