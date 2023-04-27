@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Interface - Contabilização Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_CONTAB_ITEM
  as select from ztfi_contab_item as Item

  association to parent ZI_FI_CONTAB_CAB as _Header on  _Header.Id            = $projection.Id
                                                    and _Header.Identificacao = $projection.Identificacao
{
  key id            as Id,
  key identificacao as Identificacao,
  key item          as Item,
      deb_cred      as DebCred,
      atribuicao    as Atribuicao,
      conta         as Conta,
      divisao       as Divisao,
      centro_custo  as CentroCusto,
      centro_lucro  as CentroLucro,
      segmento      as Segmento,
      texto_item    as TextoItem,
      @Semantics.amount.currencyCode : 'Moeda'
      valor         as Valor,
      
      case deb_cred
        when 'S' then 3
        when 'H' then 1
      end           as ValorCriticality,
      
      moeda         as Moeda,
      texto_erro    as TextoErro,
      
      _Header
}
