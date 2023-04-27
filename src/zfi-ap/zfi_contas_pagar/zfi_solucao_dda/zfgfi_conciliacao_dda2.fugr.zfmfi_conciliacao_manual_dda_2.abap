FUNCTION zfmfi_conciliacao_manual_dda_2.
*"--------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IS_CONCILIACAO) TYPE  ZSFI_CONCILIACAO_MANUAL
*"     VALUE(IV_XBLNR) TYPE  XBLNR OPTIONAL
*"     VALUE(IV_FISCALYEAR) TYPE  GJAHR OPTIONAL
*"     VALUE(IV_DOCNUMER) TYPE  BELNR_R OPTIONAL
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"--------------------------------------------------------------------

  DATA ls_input TYPE zclfi_bapi_dda=>ty_input.

  ls_input-bukrs   = is_conciliacao-bukrs.
  ls_input-belnr   = is_conciliacao-belnr.
  ls_input-gjahr   = is_conciliacao-gjahr.
  ls_input-buzei   = is_conciliacao-buzei.
  ls_input-lifnr   = is_conciliacao-lifnr.
  ls_input-barcode = is_conciliacao-barcode.
  ls_input-xblnr   = is_conciliacao-xblnr.

  DATA(lt_return) = NEW zclfi_bapi_dda( ls_input )->process( ).

  LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<fs_ret>).

    APPEND INITIAL LINE TO et_return ASSIGNING FIELD-SYMBOL(<fs_funcret>).

    <fs_funcret>-id         = <fs_ret>-id.
    <fs_funcret>-number     = <fs_ret>-number.
    <fs_funcret>-type       = <fs_ret>-type.
    <fs_funcret>-message_v1 = <fs_ret>-message_v1.
    <fs_funcret>-message_v2 = <fs_ret>-message_v2.
    <fs_funcret>-message_v3 = <fs_ret>-message_v3.
    <fs_funcret>-message_v4 = <fs_ret>-message_v4.

  ENDLOOP.

ENDFUNCTION.
