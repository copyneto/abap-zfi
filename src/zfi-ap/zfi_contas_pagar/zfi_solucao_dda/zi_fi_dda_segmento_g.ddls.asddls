@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Segmento "G" de arquivo DDA'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity zi_fi_dda_segmento_g
  as select from ztfi_dda_segto_g
{
  key bukrs        as Empresa,
  key hbkid        as Banco,
  key data_arq     as DataArquivo,
  key cod_lote     as CodigoLote,
  key num_reg      as NumeroRegistro,
      proposta     as Proposta,
      dt_proposta  as DataProposta,
      st_proc      as StatusProcessamento,
      gjahr        as Ano,
      belnr        as DocumentoContabil,
      buzei        as ItemDocContabil,
      usuario      as Usuario,
      data_ajuste  as DataAjuste,
      hora_ajuste  as HoraAjuste,
      cod_banco_br as CodigoBancoBr,
      cod_moeda_br as CodigoMoedaBr,
      dac_br       as DigitoVerCodigoBarras,
      ft_vencto_br as FatorVencimento,
      valor_br_br  as ValorImpressoCodBarras,
      cpo_livre_br as CampoLivre,
      cod_insc     as CodigoInscricao,
      num_insc     as NumeroInscricao,
      nome_ced     as NomeCedente,
      dt_vencto    as DataVencimento,
      valor_tit    as ValorTitulo,
      qt_moeda     as QuantidadetMoeda,
      cod_moeda    as CodigoMoeda,
      num_doc      as NumeroDocumento,
      ag_cobr      as AgenciaCobradora,
      dac_ag       as DigitoAgencia,
      fornec_sap   as FornecedorSap,
      carteira     as Carteira,
      esp_tit      as EspecieTitulo,
      dt_emiss     as DataEmissao,
      juros_mora   as JurosMora,
      dt_pri_desc  as DataPrimeiroDesconto,
      vl_pri_desc  as ValorPrimeiroDesconto,
      cod_protesto as CodigoProtesto,
      prz_protesto as PrazoProtesto,
      dt_limite    as DataLimite,
      num_insc2    as NumeroInscicao2,
      nome_ced2    as NomeCedente2,
      nosso_num    as NossoNum
}
