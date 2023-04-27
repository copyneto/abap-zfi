@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'GKO - Incoming Invoice - NF'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_TM_GKO_NF
  as select from j_1bnfdoc as _Nf
{
  key _Nf.docnum                   as docnum,
      _Nf.nfnum                    as nfnum,
      _Nf.nfenum                   as nfenum,
      _Nf.series                   as series,
      _Nf.partyp                   as partyp,
      _Nf.direct                   as direct,
      _Nf.cancel                   as cancel,
      _Nf.subseq                   as subseq,
      _Nf.nfesrv                   as nfesrv,
      _Nf.bukrs                    as bukrs,
      _Nf.branch                   as bupla,
      _Nf.belnr                    as belnr,
      _Nf.gjahr                    as gjahr,
      _Nf.parid                    as parid,
      _Nf.docref                   as docref,
      concat(_Nf.belnr, _Nf.gjahr) as awkey
}
