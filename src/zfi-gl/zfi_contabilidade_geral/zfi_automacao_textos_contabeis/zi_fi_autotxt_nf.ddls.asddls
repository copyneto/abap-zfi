@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Dados da NF'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_AUTOTXT_NF
  as select from view_sdi_items_p as FaturaItem
    inner join   I_BR_NFItem      as NFItem
      on FaturaItem.vbeln = NFItem.BR_NFSourceDocumentNumber
    inner join   I_BR_NFDocument  as NFHeader
      on NFItem.BR_NotaFiscal = NFHeader.BR_NotaFiscal

{
  key FaturaItem.vgbel,
      FaturaItem.vbeln,
      NFHeader.BR_NotaFiscal,
      NFHeader.BR_NFeNumber
}
