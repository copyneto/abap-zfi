FUNCTION zfmfi_reverse_clearing.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_EMP) TYPE  BUKRS
*"     VALUE(IV_DOC) TYPE  BELNR_D
*"     VALUE(IV_YEAR) TYPE  GJAHR
*"     VALUE(IV_ORIG) TYPE  BELNR_D
*"     VALUE(IS_MOT) TYPE  ZI_FI_REVERSAO_POPUP
*"  TABLES
*"      T_MENSAGENS TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------
  FIELD-SYMBOLS: <fs_msg> LIKE LINE OF t_mensagens.

  IF iv_doc IS NOT INITIAL.

    CALL FUNCTION 'CALL_FBRA'
      EXPORTING
        i_bukrs      = iv_emp
        i_augbl      = iv_doc
        i_gjahr      = iv_year
        i_no_auth    = abap_true
      EXCEPTIONS
        not_possible = 1
        OTHERS       = 2.

    IF sy-subrc = 0.

      CALL FUNCTION 'CALL_FB08'
        EXPORTING
          i_bukrs      = iv_emp
          i_belnr      = iv_doc
          i_gjahr      = iv_year
          i_stgrd      = is_mot-motestorno
          i_budat      = is_mot-datalancest
          i_monat      = is_mot-datalancest+4(2)
        EXCEPTIONS
          not_possible = 1
          OTHERS       = 2.

      IF sy-subrc = 0.

        IF t_mensagens IS INITIAL.

          APPEND INITIAL LINE TO t_mensagens ASSIGNING <fs_msg>.
          <fs_msg>-id     = 'ZFI_REVERSAO'.
          <fs_msg>-number = '006'.
          <fs_msg>-type   = 'I'.

        ENDIF.

        APPEND INITIAL LINE TO t_mensagens ASSIGNING <fs_msg>.
        <fs_msg>-id     = 'ZFI_REVERSAO'.
        <fs_msg>-number = '003'.
        <fs_msg>-type   = 'S'.
        <fs_msg>-message_v1 = iv_doc.
        <fs_msg>-message_v2 = iv_emp.
        <fs_msg>-message_v3 = iv_year.

      ELSE.

        APPEND INITIAL LINE TO t_mensagens ASSIGNING <fs_msg>.
        <fs_msg>-id         = 'ZFI_REVERSAO'.
        <fs_msg>-number     = '004'.
        <fs_msg>-type       = 'E'.
        <fs_msg>-message_v1 = iv_doc.
        <fs_msg>-message_v2 = iv_emp.
        <fs_msg>-message_v3 = iv_year.

        APPEND INITIAL LINE TO t_mensagens ASSIGNING <fs_msg>.
        <fs_msg>-id         = sy-msgid.
        <fs_msg>-number     = sy-msgno.
        <fs_msg>-type       = sy-msgty.
        <fs_msg>-message_v1 = sy-msgv1.
        <fs_msg>-message_v2 = sy-msgv2.
        <fs_msg>-message_v3 = sy-msgv3.
        <fs_msg>-message_v4 = sy-msgv4.

      ENDIF.

    ELSE.

      APPEND INITIAL LINE TO t_mensagens ASSIGNING <fs_msg>.
      <fs_msg>-id     = 'ZFI_REVERSAO'.
      <fs_msg>-number = '005'.
      <fs_msg>-type   = 'E'.
      <fs_msg>-message_v1 = iv_doc.
      <fs_msg>-message_v2 = iv_emp.
      <fs_msg>-message_v3 = iv_year.

    ENDIF.

  ENDIF.

  CALL FUNCTION 'CALL_FB08'
    EXPORTING
      i_bukrs      = iv_emp
      i_belnr      = iv_orig
      i_gjahr      = iv_year
      i_stgrd      = is_mot-motestorno
      i_budat      = is_mot-datalancest
      i_monat      = is_mot-datalancest+4(2)
    EXCEPTIONS
      not_possible = 1
      OTHERS       = 2.

  IF sy-subrc = 0.

    IF t_mensagens IS INITIAL.

      APPEND INITIAL LINE TO t_mensagens ASSIGNING <fs_msg>.
      <fs_msg>-id     = 'ZFI_REVERSAO'.
      <fs_msg>-number = '006'.
      <fs_msg>-type   = 'I'.

    ENDIF.

    APPEND INITIAL LINE TO t_mensagens ASSIGNING <fs_msg>.
    <fs_msg>-id     = 'ZFI_REVERSAO'.
    <fs_msg>-number = '003'.
    <fs_msg>-type   = 'S'.
    <fs_msg>-message_v1 = iv_orig.
    <fs_msg>-message_v2 = iv_emp.
    <fs_msg>-message_v3 = iv_year.

  ELSE.

    APPEND INITIAL LINE TO t_mensagens ASSIGNING <fs_msg>.
    <fs_msg>-id         = 'ZFI_REVERSAO'.
    <fs_msg>-number     = '004'.
    <fs_msg>-type       = 'E'.
    <fs_msg>-message_v1 = iv_orig.
    <fs_msg>-message_v2 = iv_emp.
    <fs_msg>-message_v3 = iv_year.

    APPEND INITIAL LINE TO t_mensagens ASSIGNING <fs_msg>.
    <fs_msg>-id         = sy-msgid.
    <fs_msg>-number     = sy-msgno.
    <fs_msg>-type       = sy-msgty.
    <fs_msg>-message_v1 = sy-msgv1.
    <fs_msg>-message_v2 = sy-msgv2.
    <fs_msg>-message_v3 = sy-msgv3.
    <fs_msg>-message_v4 = sy-msgv4.

  ENDIF.

ENDFUNCTION.
