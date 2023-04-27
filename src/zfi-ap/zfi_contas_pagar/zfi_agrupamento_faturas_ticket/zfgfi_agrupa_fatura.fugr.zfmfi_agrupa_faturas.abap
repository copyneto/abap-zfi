FUNCTION zfmfi_agrupa_faturas.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_USER) TYPE  SYUNAME DEFAULT SY-UNAME
*"     VALUE(IV_IDARQUIVO) TYPE  ZTFI_AGRUPFATURA-ID_ARQUIVO
*"     VALUE(IS_CAMPOS_POPUP) TYPE  ZI_FI_AGRUPA_FATURAS_POPUP
*"     VALUE(IT_FTPOST) TYPE  FAGL_T_FTPOST
*"     VALUE(IT_FTCLEAR) TYPE  FDM_T_FTCLEAR
*"  TABLES
*"      ET_MENSAGENS TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------



  CONSTANTS:
    lc_background_mode          TYPE rfpdo-allgazmd VALUE 'N',
    lc_sgfunct                  TYPE rfipi-sgfunct  VALUE 'C',
    lc_auglv_transf_compensacao TYPE t041a-auglv    VALUE 'UMBUCHNG',
    lc_tcode                    TYPE sy-tcode       VALUE 'FB05'.

  DATA:
    lt_blntab  TYPE TABLE OF blntab,
    lt_ftpost  TYPE TABLE OF ftpost,
    lt_ftclear TYPE TABLE OF ftclear,
    lt_fttax   TYPE TABLE OF fttax.

  DATA:
    lv_msgid   TYPE sy-msgid,
    lv_msgno   TYPE sy-msgno,
    lv_msgty   TYPE sy-msgty,
    lv_msgv1   TYPE sy-msgv1,
    lv_msgv2   TYPE sy-msgv2,
    lv_msgv3   TYPE sy-msgv3,
    lv_msgv4   TYPE sy-msgv4,
    lv_simular TYPE abap_bool.


  lt_ftpost = it_ftpost.
  lt_ftclear = it_ftclear.

  CALL FUNCTION 'POSTING_INTERFACE_START'
    EXPORTING
      i_function         = lc_sgfunct
      i_mode             = lc_background_mode
      i_user             = iv_user
    EXCEPTIONS
      client_incorrect   = 1
      function_invalid   = 2
      group_name_missing = 3
      mode_invalid       = 4
      update_invalid     = 5
      OTHERS             = 6.

  IF sy-subrc NE 0.

    et_mensagens[] = VALUE #( (   id = sy-msgid
                                  type = sy-msgty
                                  number = sy-msgno
                                  message_v1 = sy-msgv1
                                  message_v2 = sy-msgv2
                                  message_v3 = sy-msgv3
                                  message_v4 = sy-msgv4
                            ) ).
    RETURN.
  ENDIF.

  "Executa processo de compensação
  CALL FUNCTION 'POSTING_INTERFACE_CLEARING'
    EXPORTING
      i_auglv                    = lc_auglv_transf_compensacao
      i_tcode                    = lc_tcode
      i_sgfunct                  = lc_sgfunct
      i_no_auth                  = abap_true
      i_xsimu                    = lv_simular
    IMPORTING
      e_msgid                    = lv_msgid
      e_msgno                    = lv_msgno
      e_msgty                    = lv_msgty
      e_msgv1                    = lv_msgv1
      e_msgv2                    = lv_msgv2
      e_msgv3                    = lv_msgv3
      e_msgv4                    = lv_msgv4
    TABLES
      t_blntab                   = lt_blntab
      t_ftclear                  = lt_ftclear
      t_ftpost                   = lt_ftpost
      t_fttax                    = lt_fttax
    EXCEPTIONS
      clearing_procedure_invalid = 1
      clearing_procedure_missing = 2
      table_t041a_empty          = 3
      transaction_code_invalid   = 4
      amount_format_error        = 5
      too_many_line_items        = 6
      company_code_invalid       = 7
      screen_not_found           = 8
      no_authorization           = 9
      error_message              = 10
      OTHERS                     = 11.


  IF sy-subrc EQ 0 AND lv_msgty NE if_xo_const_message=>error.

    " Checa se a fatura agrupada foi gerada
    TRY.

        DATA(ls_blntab) = lt_blntab[ 1 ].

      CATCH cx_sy_itab_line_not_found.
        CLEAR ls_blntab.
    ENDTRY.

  ENDIF.

  et_mensagens[] =  VALUE #( (  id         = lv_msgid
                                type       = lv_msgty
                                number     = lv_msgno
                                message_v1 = lv_msgv1
                                message_v2 = lv_msgv2
                                message_v3 = lv_msgv3
                                message_v4 = lv_msgv4
                          ) ).


  " Atualiza dados nas tabelas de agrupamento
  NEW zclfi_fatura_agrupada(
    is_campos_popup = is_campos_popup
    iv_idarquivo = iv_idarquivo
    iv_faturaagrupada = ls_blntab-belnr
    iv_exercicioagrupado = ls_blntab-gjahr )->atualiza(
    it_msg = et_mensagens[] ).

ENDFUNCTION.
