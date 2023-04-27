@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Segmento "H" de arquivo DDA'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity zi_fi_dda_segmento_h
  as select from ztfi_dda_segto_h
{
  key bukrs       as Empresa,
  key hbkid       as Banco,
  key data_arq    as DataArquivo,
  key cod_lote    as CodigoLote,
  key num_reg     as NumeroRegistro,
      cdg_ins_ava as CodigoAvalista,
      insc_ava    as InscricaoAvalista,
      nome_ava    as NomeAvalista,
      dt_seg_desc as DataSegundoDesconto,
      vl_seg_desc as ValorSegundoDesconto,
      dt_ter_desc as DataTerceiroDesconto,
      vl_ter_desc as ValorTerceiroDesconto,
      dt_multa    as DataMulta,
      vl_multa    as ValorMulta,
      vl_abat     as ValorAbatimento,
      ints_01     as Instrucao01,
      ints_02     as Instrucao02
}
