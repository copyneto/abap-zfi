@AbapCatalog.sqlViewName: 'ZVIFIZFIR326'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CPC 02 - Estoques e Custos'
define view ZI_FI_ZFIR326
  as select from ZC_FI_CPC2L as _Qcp2l
  association [1..*] to ZI_FI_VH_PROC_TYPE as _Ptyp  on _Ptyp.Ptyp = _Qcp2l.ptyp_proc
  association [1..*] to ZI_FI_VH_KATEGORIE as _Kateg on _Kateg.Kategorie = _Qcp2l.kategorie
{
  key _Qcp2l.belnr,
  key _Qcp2l.poper,
  key _Qcp2l.bdatj,
  key _Qcp2l.bwkey,
  key _Qcp2l.bwtar,
  key _Qcp2l.matnr,
      //      @Semantics.quantity.unitOfMeasure: 'meins'
      //      _Qcp2l.lbkum,
      _Qcp2l.meins,
      //      _Qcp2l.psart,
      @ObjectModel.text.element: ['Ktext']
      _Qcp2l.ptyp_proc,
      @ObjectModel.text.element: ['KategorieText']
      _Qcp2l.kategorie,
      //      _Qcp2l.awref,
      //      _Qcp2l.awtyp,
      //      _Qcp2l.vgart,
      //      _Qcp2l.stprs_old,
      _Qcp2l.waers,
      //      _Qcp2l.pvprs_old,
      //      _Qcp2l.salkv,
      //      @Semantics.amount.currencyCode: 'waers'
      //      _Qcp2l.salk3,
      //      _Qcp2l.curtp,
      //      _Qcp2l.posnr,
      //      _Qcp2l.peinh,
      //      _Qcp2l.ptyp,
      //      _Qcp2l.bvalt,
      //      _Qcp2l.ptyp_kat,
      //      _Qcp2l.ptyp_bvalt,
      //      _Qcp2l.process,
      _Qcp2l.budat,
      //      _Qcp2l.cpudt,
      //      _Qcp2l.tcode,
      _Qcp2l.xblnr,
      _Qcp2l.lifnr,
      lifnr_mseg,
      kunnr_mseg,
      //      @Semantics.amount.currencyCode: 'waers'
      //      _Qcp2l.prod,
      //@Semantics.amount.currencyCode: 'waers'
      _Qcp2l.wrbtr,
      //@Semantics.quantity.unitOfMeasure: 'meins'
      _Qcp2l.menge,

      _Ptyp.Ktext,
      _Kateg.KategorieText,

      _Ptyp,
      _Kateg

}
