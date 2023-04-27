@EndUserText.label: 'Movimentos Material Ledger'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_FI_MOV_LEDGER
  as projection on ZI_FI_MOV_LEDGER
{
  
  key docref,
  key curtp,
  key matnr,
      @EndUserText: {
            label: 'Centro',
            quickInfo: 'Centro'
        }
  key bwkey,

  key bwtar,
  key exercicio,
  key periodo,
  key belnr,
      @EndUserText: {
          label: 'Cod.Categoria',
          quickInfo: 'Cod.Categoria'
      }
  key categ,
      awref,
      @EndUserText: {
          label: 'Categoria',
          quickInfo: 'Categoria'
      }
      Categoria,
      budat,
      Preco,
      @EndUserText: {
          label: 'Unidade de Medida',
          quickInfo: 'Unidade de Medida'
      }
      Meins,
      @EndUserText: {
          label: 'Quantidade',
          quickInfo: 'Quantidade'
      }
      Quant,
      @EndUserText: {
          label: 'Custo Real',
          quickInfo: 'Custo Real'
      }
      CustoReal,
      @EndUserText: {
          label: 'Cod. Categoria do processo',
          quickInfo: 'Cod. Categoria do processo'
      }
      ptyp,
      @EndUserText: {
          label: 'Categoria do processo',
          quickInfo: 'Categoria do processo'
      }
      ktext,
      @EndUserText: {
          label: 'Nota Fiscal',
          quickInfo: 'Nota Fiscal'
      }
      Xblnr,
      @EndUserText: {
          label: 'N° Fornecedor',
          quickInfo: 'N° Fornecedor'
      }
      lifnr,
      @EndUserText: {
          label: 'Descrição Fornecedor',
          quickInfo: 'Descrição Fornecedor'
      }
      Name1
}
