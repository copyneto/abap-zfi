@EndUserText.label: 'Log Diferimento - Docs Mensagens'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_LOG_DIFER_M as projection on ZI_FI_LOG_DIFER_M {
    key IdLog,
    key IdMsg,
    key IdBapi,
    Type,
    Message,
    MgCor,
    /* Associations */
    _LOG_DIFER_H : redirected to parent ZC_FI_LOG_DIFER_H
}
