@EndUserText.label: 'Arquivo Agrupamento de faturas'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZI_FI_AGRUPAFATURAS
  as select from ztfi_agrupfatura

  composition [1..*] of ZI_FI_AGRUPALINHAS         as _Linhas

  association [0..1] to ZI_FI_VH_AGRUPA_ARQ_STATUS as _Status
    on $projection.StatusProcessamento = _Status.StatusId

{
  key id_arquivo            as IdArquivo,

      arquivo               as Arquivo,
      data                  as DataImportacao,
      status_proc           as StatusProcessamento,
      bukrs                 as CompanyCode,
      forn_agrupador        as FornAgrupador,
      vencimento            as Vencimento,
      ref_agrupada          as Referencia,
      hora                  as HoraImportacao,

      //Critically information
      case status_proc
        when '0' then 0 -- Não processado           | 0: unknown
        when '1' then 1 -- Não é possível processar | 1: red color
        when '2' then 2 -- Disponível p/ agrupar    | 2: yellow color
        when '3' then 3 -- Agrupado                 | 3: green color
        when '4' then 2 -- Erro ao agrupar          | 1: red color
        else 0
      end                   as StatusCriticality,

      /* Campos de Abstract Entity */
      ''                    as selCompanyCode,
      ''                    as selFornAgrupa,
      ''                    as selDueDate,
      ''                    as selReference,
      ''                    as selPostingDate,
      ''                    as selDocumentDate,
      ''                    as selCostCenter,
      @Semantics.amount.currencyCode: 'selCurrency'
      cast('0' as wrbtr)    as selDesconto,
      cast('BRL' as waers)  as selCurrency,

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
      _Linhas,
      _Status

}
