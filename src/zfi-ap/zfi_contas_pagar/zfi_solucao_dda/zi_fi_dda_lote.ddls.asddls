@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Lote de arquivo DDA'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity zi_fi_dda_lote
  as select from ztfi_dda_lote
{
  key bukrs    as Empresa,
  key hbkid    as Banco,
  key data_arq as DataArquivo,
  key cod_lote as CodigoLote,
      cnpj     as Cnpj,
      operacao as Operacao,
      cod_serv as CodigoServico,
      layout   as Layout,
      cod_insc as CodigoInscricao,
      num_insc as NumeroInscricao,
      nome_emp as NomeEmpresa
}
