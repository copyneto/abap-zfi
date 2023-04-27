@AbapCatalog.sqlViewName: 'ZVFI_CREDI_CLI'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Documentos Créditos Union'
define view ZI_FI_CREDITOS_CLI_U as select from ZI_FI_CREDITOS_CLI_CDCLI as CdCli {
   CdCli.Empresa          as Empresa,
   CdCli.Documento        as Documento,
   CdCli.Ano              as Ano,
   CdCli.Linha            as Linha,
   CdCli.Cliente          as Cliente,
   CdCli.RaizId           as RaizId,
   CdCli.RaizSN           as RaizSn,
   CdCli.CodCliente       as CodCliente,
   CdCli.Residual         as Residual,
   CdCli.TipoDocumento    as TipoDocumento,
   CdCli.ChaveLancamento  as ChaveLancamento,
   CdCli.CodigoRZE        as CodigoRZE,
   CdCli.VencimentoLiquido as VencimentoLiquido,
   CdCli.Atribuicao       as Atribuicao,
   CdCli.Referencia       as Referencia,
   CdCli.DataLancamento   as DataLancamento,
   CdCli.FormaPagamento   as FormaPagamento,
   CdCli.CondicaoPagamento as CondicaoPagamento,
   CdCli.Moeda            as Moeda,
   CdCli.Montante         as Montante,
   CdCli.Desconto         as Desconto,
   CdCli.CreatedBy        as CreatedBy,
   CdCli.CreatedAt        as CreatedAt,
   CdCli.LastChangedBy    as LastChangedBy,
   CdCli.LastChangedAt    as LastChangedAt,
   CdCli.LocalLastChangedAt as LocalLastChangedAt
} union  select from ZI_FI_CREDITOS_CLI_CDCLI as CdCli
 inner join ZI_FI_CREDITOS_CLI_RAIZID as RaizId on RaizId.Empresa = CdCli.Empresa
{
   CdCli.Empresa          as Empresa,
   RaizId.Documento        as Documento,
   RaizId.Ano              as Ano,
   RaizId.Linha            as Linha,
   RaizId.Cliente          as Cliente,
   RaizId.RaizId           as RaizId,
   RaizId.RaizSN           as RaizSn,
   RaizId.CodCliente       as CodCliente,
   RaizId.Residual         as Residual,
   RaizId.TipoDocumento    as TipoDocumento,
   RaizId.ChaveLancamento  as ChaveLancamento,
   RaizId.CodigoRZE        as CodigoRZE,
   RaizId.VencimentoLiquido as VencimentoLiquido,
   RaizId.Atribuicao       as Atribuicao,
   RaizId.Referencia       as Referencia,
   RaizId.DataLancamento   as DataLancamento,
   RaizId.FormaPagamento   as FormaPagamento,
   RaizId.CondicaoPagamento as CondicaoPagamento,
   RaizId.Moeda            as Moeda,
   RaizId.Montante         as Montante,
   RaizId.Desconto         as Desconto,
   RaizId.CreatedBy        as CreatedBy,
   RaizId.CreatedAt        as CreatedAt,
   RaizId.LastChangedBy    as LastChangedBy,
   RaizId.LastChangedAt    as LastChangedAt,
   RaizId.LocalLastChangedAt as LocalLastChangedAt
}
