@EndUserText.label: 'Log Diferimento - Docs Mensagens'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_LOG_DIFER_D as projection on ZI_FI_LOG_DIFER_D {
    key IdLog,
    key Empresa,
    key Gjahr,
    key Belnr,
    GjahrRec,
    BelnrRec,
    GjahrRaz,
    BelnrRaz, 

    /* Associations */
    _LOG_DIFER_H: redirected to parent ZC_FI_LOG_DIFER_H
}
