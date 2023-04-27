@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Modelo para arquivo DDA'
@VDM.viewType: #COMPOSITE
define root view entity zi_fi_arquivo_dda
  as select from zi_fi_dda_header as _dda_header
  inner join    zi_fi_dda_trailer_arquivo as _TrailerArquivo on  _TrailerArquivo.Empresa     = _dda_header.Empresa
                                                                     and _TrailerArquivo.Banco       = _dda_header.Banco
                                                                     and _TrailerArquivo.DataArquivo = _dda_header.DataArquivo
  inner join zi_fi_dda_lote            as _Lote           on  _Lote.Empresa     = _dda_header.Empresa
                                                                     and _Lote.Banco       = _dda_header.Banco
                                                                     and _Lote.DataArquivo = _dda_header.DataArquivo
  inner join zi_fi_dda_trailer_lote    as _TrailerLote    on  _TrailerLote.Empresa     = _dda_header.Empresa
                                                                     and _TrailerLote.Banco       = _dda_header.Banco
                                                                     and _TrailerLote.DataArquivo = _dda_header.DataArquivo
                                                                     and _TrailerLote.CodigoLote = _Lote.CodigoLote
  inner join zi_fi_dda_segmento_g      as _SegmentoG      on  _SegmentoG.Empresa     = _dda_header.Empresa
                                                                     and _SegmentoG.Banco       = _dda_header.Banco
                                                                     and _SegmentoG.DataArquivo = _dda_header.DataArquivo
                                                                     and _SegmentoG.CodigoLote = _Lote.CodigoLote
  left outer join  zi_fi_dda_segmento_h      as _SegmentoH      on  _SegmentoH.Empresa     = _dda_header.Empresa
                                                                     and _SegmentoH.Banco       = _dda_header.Banco
                                                                     and _SegmentoH.DataArquivo = _dda_header.DataArquivo
                                                                     and _SegmentoH.CodigoLote = _Lote.CodigoLote
                                                                     and _SegmentoH.NumeroRegistro = _SegmentoG.NumeroRegistro
{

  key _dda_header.Empresa,
  key _dda_header.Banco,
  key _dda_header.DataArquivo,

      //Header do arquivo
      _dda_header.NomeArquivo,
      _dda_header.NomeEmpresa,
      _dda_header.NomeBanco,

      _Lote.CodigoLote                                                               as CodLote,
      _Lote.Cnpj                                                                     as CnpjCedente,

      //Chave (Segmento G)
      _SegmentoG.FornecedorSap                                                       as Fornecedor,
      _SegmentoG.DocumentoContabil,
      _SegmentoG.Ano,

      //Campos para impressão do boleto
      _SegmentoG.DataVencimento,
      _SegmentoG.AgenciaCobradora                                                    as AgenciaCedente,
      _SegmentoG.NomeCedente,
      _SegmentoG.DataEmissao                                                         as DataDocumento,
      _SegmentoG.NumeroDocumento,
      _SegmentoG.EspecieTitulo,
      _SegmentoG.Carteira,
      cast( _SegmentoG.ValorTitulo as abap.dec( 15, 2 ) )                            as ValorTitulo,
      _SegmentoG.JurosMora,
      _SegmentoG.NossoNum,
      _SegmentoG.CodigoMoedaBr,
      _SegmentoG.DigitoAgencia,
      _SegmentoG.FatorVencimento,
      _SegmentoG.CampoLivre,
      _SegmentoG.CodigoProtesto,
      _SegmentoG.PrazoProtesto,
      _SegmentoG.NumeroInscricao,

      _SegmentoH.ValorAbatimento,
      _SegmentoH.ValorMulta,
      _SegmentoH.NomeAvalista,
      _SegmentoH.Instrucao01,
      _SegmentoH.Instrucao02,

      ( _SegmentoG.ValorTitulo + _SegmentoG.JurosMora - _SegmentoH.ValorAbatimento ) as ValorCobrado
}
