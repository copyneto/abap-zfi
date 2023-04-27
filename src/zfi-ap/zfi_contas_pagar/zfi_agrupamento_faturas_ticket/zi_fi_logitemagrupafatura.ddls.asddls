@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Log Agrupamento de faturas - Itens'
define view entity ZI_FI_LOGITEMAGRUPAFATURA
  as select from ztfi_agruplinhas

  association        to parent ZI_FI_LOGHEADERAGRUPAFATURA as _HeaderLog
    on $projection.IdArquivo = _HeaderLog.IdArquivo

  association [0..1] to ZI_FI_VH_AGRUPA_ITEM_STATUS        as _ItemStatus
    on $projection.ItemStatus = _ItemStatus.StatusId

{
  key id_arquivo            as IdArquivo,
  key id                    as Id,
      bukrs                 as CompanyCode,
      lifnr                 as Supplier,
      xblnr1                as NotaFiscal,
      arq_data              as DataArquivo,
      tipo_nf               as TipoNF,
      chave_acesso          as ChaveAcesso,
      cnpj                  as Cnpj,
      zfbdt                 as DueDate,
      status_proc           as ItemStatus,

      //Critically information
      case status_proc
        when '0' then 0 -- Não processado  | 0: unknown
        when '1' then 1 -- Erro            | 1: red color
        when '2' then 2 -- Avisos          | 2: yellow color
        when '3' then 3 -- Ok              | 3: green color
        else 0
      end                   as ItemCriticality,

      arq_dmbtr             as ValorNFArquivo,
      doc_dmbtr             as ValorNFFatura,
      waers                 as CurrencyCode,
      belnr                 as AccountingDocument,
      gjahr                 as FiscalYear,
      buzei                 as AccountingItem,
      arq_bldat             as DtEmissaoArquivo,
      doc_bldat             as DtEmissaoFatura,
      bupla                 as BusinessPlace,
      zuonr                 as Assignment,
      sgtxt                 as ItemText,
      prctr                 as ProfitCenter,
      msg                   as Msg,
      forn_agrupador        as FornAgrupador,
      fatura_agrupada       as FaturaAgrupada,
      ref_agrupada          as RefAgrupada,

      /* Campos de controle */
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      /*Associations*/
      _HeaderLog,
      _ItemStatus
}
