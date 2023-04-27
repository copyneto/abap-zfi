@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Query CPC2L-01'
define root view entity ZI_FI_QRY_CPC2L
  as select from ZI_FI_ZFIR326
  association [1..1] to I_BusinessPartner as _Lifnr on _Lifnr.BusinessPartner = $projection.lifnr
  association [1..1] to I_BusinessPartner as _Kunnr on _Kunnr.BusinessPartner = $projection.lifnr
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
      lifnr_mseg,
      kunnr_mseg,
      //@Semantics.amount.currencyCode: 'waers'
      sum( wrbtr )                   as wrbtr,
      //@Semantics.quantity.unitOfMeasure: 'meins'
      sum( menge )                   as menge,
      Ktext,
      KategorieText,
      _Lifnr.BusinessPartnerFullName as Fornecedor,
      _Kunnr.BusinessPartnerFullName as Cliente,
      /* Associations */
      _Kateg,
      _Ptyp,

      _Lifnr,
      _Kunnr
}
group by
  belnr,
  poper,
  bdatj,
  bwkey,
  bwtar,
  matnr,
  meins,
  ptyp_proc,
  kategorie,
  waers,
  budat,
  xblnr,
  lifnr,
  lifnr_mseg,
  kunnr_mseg,
  Ktext,
  KategorieText,
  _Lifnr.BusinessPartnerFullName,
  _Kunnr.BusinessPartnerFullName
