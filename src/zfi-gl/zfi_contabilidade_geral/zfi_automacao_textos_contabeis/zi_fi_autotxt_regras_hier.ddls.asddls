@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Autom.Txt.Contáb. Regras, crit. e campos'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_AUTOTXT_REGRAS_HIER
  as select from    ztfi_autotext   as Regras

    left outer join ztfi_sel_empr   as Empresa
      on Empresa.id_regra = Regras.id

    left outer join ztfi_sel_tpdoc  as TipoDoc
      on TipoDoc.id_regra = Regras.id

    left outer join ztfi_sel_conta  as Conta
      on Conta.id_regra = Regras.id

    left outer join ztfi_sel_chave  as ChaveLancto
      on ChaveLancto.id_regra = Regras.id

    left outer join ztfi_sel_flowtp as TipoAtualizacao
      on TipoAtualizacao.id_regra = Regras.id

    left outer join ztfi_sel_prodtp as TipoProduto
      on TipoProduto.id_regra = Regras.id

{

  key Regras.id                    as IdRegra,
  key Empresa.id                   as IdSelCompany,
  key TipoDoc.id                   as IdSelDocType,
  key Conta.id                     as IdSelAccount,
  key ChaveLancto.id               as IdSelPostingKey,
  key TipoAtualizacao.id           as IdSelTreasuryUpdateType,
  key TipoProduto.id               as IdSelFIProdType,

      Regras.regra                 as Regra,
      Regras.texto_fixo            as TextoFixo,
      Regras.descricao             as Descricao,

      Empresa.cod_criterio         as CritSelCompany,
      Empresa.sign                 as SignCompany,
      Empresa.opt                  as OptCompany,
      Empresa.low                  as LowCompany,
      Empresa.high                 as HighCompany,

      TipoDoc.cod_criterio         as CritSelDocType,
      TipoDoc.sign                 as SignDocType,
      TipoDoc.opt                  as OptDocType,
      TipoDoc.low                  as LowDocType,
      TipoDoc.high                 as HighDocType,

      Conta.cod_criterio           as CritSelAccount,
      Conta.sign                   as SignAccount,
      Conta.opt                    as OptAccount,
      Conta.low                    as LowAccount,
      Conta.high                   as HighAccount,

      ChaveLancto.cod_criterio     as CritSelPostingKey,
      ChaveLancto.sign             as SignPostingKey,
      ChaveLancto.opt              as OptPostingKey,
      ChaveLancto.low              as LowPostingKey,
      ChaveLancto.high             as HighPostingKey,


      TipoAtualizacao.cod_criterio as CritSelTreasuryUpdateType,
      TipoAtualizacao.sign         as SignTreasuryUpdateType,
      TipoAtualizacao.opt          as OptTreasuryUpdateType,
      TipoAtualizacao.low          as LowTreasuryUpdateType,
      TipoAtualizacao.high         as HighTreasuryUpdateType,

      TipoProduto.cod_criterio     as CritSelFIProdType,
      TipoProduto.sign             as SignFIProdType,
      TipoProduto.opt              as OptFIProdType,
      TipoProduto.low              as LowFIProdType,
      TipoProduto.high             as HighFIProdType


}
