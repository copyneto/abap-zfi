@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Movimentos Material Ledger'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_MOV_LEDGER
  as select from ZI_FI_MOV_LEDGER_VIEW as _Mov

    //inner join   mldoc                 as _Doc on _Mov.kalnr = _Doc.kalnr


  association to mbewh          as _MB  on  _Mov.matnr     = _MB.matnr
                                        and _Mov.bwkey     = _MB.bwkey
                                        and _Mov.bwtar     = _MB.bwtar
                                        and _Mov.exercicio = _MB.lfgja
                                        and _Mov.periodo   = _MB.lfmon

  //association to mldoc          as _Doc on  _Mov.kalnr = _Doc.kalnr


  association to ckmlmv009t     as _MV9 on  _Mov.ptyp  = _MV9.ptyp
                                        and _MV9.spras = 'P'

  association to ZI_FI_FORN_DOC as _RB  on  _Mov.awref     = _RB.Belnr
                                        and _Mov.exercicio = _RB.Gjahr

  association to dd07t          as _Cat on  _Cat.domname    = 'CKML_CATEG'
                                        and _Cat.ddlanguage = 'P'
                                        and _Cat.domvalue_l = _Mov.categ
                                        
                                        
  association [0..1] to  acdoca as _Acdoca on  _Acdoca.docln = '000001'
                                           and _Acdoca.awref = _Mov.awref
                                           and _Acdoca.hsl   <> 0                                        
{
  key _Mov.docref,
  key _Mov.curtp,
  key _Mov.matnr,
  key _Mov.bwkey,

  key _Mov.bwtar,
  key _Mov.exercicio,
  key _Mov.periodo,
  key _Mov.belnr,
  key _Mov.categ,
      _Mov.kalnr,
      //_Mov.awref,
      _Acdoca.belnr as awref,
      _Cat.ddtext                                                                                                                             as Categoria,
      _Mov.budat,
      cast( _MB.stprs as abap.dec( 11, 2 )  )                                                                                                 as Preco,
      _MB.peinh                                                                                                                               as peinh,
      _Mov.ptyp,

      //_Doc.meins                                                                                                                              as Meins,
      //      @Semantics.quantity.unitOfMeasure : 'Meins'
      //cast( _Doc.quant as abap.dec( 23, 2 ) )                                                                                                 as Quant,

      _Mov.meins                                                                                                                              as Meins,
      //      @Semantics.quantity.unitOfMeasure : 'Meins'
      cast( _Mov.quant as abap.dec( 23, 2 ) )  as Quant,

      //cast( division( cast(_MB.stprs as abap.dec( 11, 2 ) ) , _MB.peinh , 3 ) * cast( _Doc.quant as abap.dec( 23, 3 ) ) as abap.dec( 25, 2) ) as CustoReal,      
      //fltp_to_dec(cast(_MB.stprs as abap.fltp) / cast(_MB.peinh as abap.fltp) * cast(_Doc.quant as abap.fltp) as abap.dec(20, 2)) as CustoReal,      
      fltp_to_dec(cast(_MB.stprs as abap.fltp) / cast(_MB.peinh as abap.fltp) * cast(_Mov.quant as abap.fltp) as abap.dec(20, 2)) as CustoReal,      

      _MV9.ktext,
      _RB.Xblnr,
      _RB.lifnr,
      _RB.Name1
}
where
    //cast(_Doc.quant as abap.dec(23,2)) <> 0 
    cast(_Mov.quant as abap.dec(23,2)) <> 0 
