@AbapCatalog.sqlViewName: 'ZVFIMOVLG'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Movimentos Material Ledger'
define view ZI_FI_MOV_LEDGER_VIEW
  //as select distinct from ML4H_CDS_MLDOCCCSHD
  // as select from mldoc as doc
  //   inner join ckmlhd as hd on   hd.kalnr   = doc.kalnr
  
  as select from ckmlhd as hd
     
     association [0..1] to mldoc as doc on doc.kalnr = hd.kalnr
     
     //association [0..1] to  acdoca as _Acdoca on _Acdoca.awref = doc.awref
     //                                        and _Acdoca.hsl   <> 0
     
{
  key doc.docref,
  key doc.curtp,
  hd.matnr,
  hd.bwkey,
  hd.bwtar,
  //SUBSTRING( current_per , 1,4) as exercicio,
  //SUBSTRING( current_per , 6,7) as periodo,
  SUBSTRING( doc.jahrper , 1,4) as exercicio,
  SUBSTRING( doc.jahrper , 6,7) as periodo,  
  doc.belnr,
  doc.ptyp,
  doc.awref,// as refdoc,
  //_Acdoca.belnr as awref,
  doc.meins,
  doc.quant,
  doc.budat,
  doc.categ,
  doc.kalnr
  
  // _Acdoca
}

where
       doc.curtp  = '10'
  and(
       doc.posart = 'UP'
    or doc.posart = 'PC'
    or doc.posart = 'DC'
    or doc.posart = 'ST'
    or doc.posart = 'MS'
  )
