@EndUserText.label: 'CPC2L - Custo e Estoque'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_FI_QRY_CPC2L
  as projection on ZI_FI_QRY_CPC2L
{
  key belnr,
  key poper,
  key bdatj,
  key bwkey,
  key bwtar,
  key matnr,
      meins,
      ptyp_proc,
      kategorie,
      waers,
      budat,
      xblnr,
      lifnr,
      @ObjectModel.text.element: ['Fornecedor']
      lifnr_mseg,
      @ObjectModel.text.element: ['Cliente']
      kunnr_mseg,
      //@Semantics.amount.currencyCode: 'waers'
      wrbtr,
      //@Semantics.quantity.unitOfMeasure: 'meins'
      menge,
      Ktext,
      KategorieText,
      Fornecedor,
      Cliente,
      /* Associations */
      _Kateg,
      _Kunnr,
      _Lifnr,
      _Ptyp
}
