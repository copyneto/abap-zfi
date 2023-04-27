@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Contabilidade: Fornecedores - Gerado'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}    

define view entity ZI_FI_BSIK_CONTAB
   as select from bsik_view as i

   association [1..1] to bseg as b on i.bukrs = b.bukrs
                                   and i.belnr = b.belnr
                                   and i.gjahr = b.gjahr
                                   and i.buzei = b.buzei
 {
    key i.lifnr,
        i.xblnr,
        i.belnr,
        b.fdtag,
        i.bldat,
        i.budat,
        i.blart,
        i.zterm,
//        i.skfbt as Skfbt,
        i.sgtxt,
        i.ebeln,
//        i.wrbtr,
        i.zlsch
        
 }
