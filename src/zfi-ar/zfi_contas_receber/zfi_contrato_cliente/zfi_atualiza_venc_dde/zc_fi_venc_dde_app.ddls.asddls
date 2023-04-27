@EndUserText.label: 'CDS Consumo Venc. DDE'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_VENC_DDE_APP as projection on ZI_FI_VENC_DDE_APP {
    key Empresa,
    key Documento,
    key Exercicio,
    key Cliente,
    key Fatura,
    @EndUserText.label: 'Remessa'
    key Remessa,
    @EndUserText.label: 'Data Entrega'
    DataEntregaz
}
//eliminar
