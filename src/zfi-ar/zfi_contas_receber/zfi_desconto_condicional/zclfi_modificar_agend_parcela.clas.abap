"!<p>Classe Consultar Pendência Financeira</p>
"!<p><strong>Autor:</strong>Marcos Rubik</p>
"!<p><strong>Data:</strong> 08 de Março de 2022</p>
CLASS zclfi_modificar_agend_parcela DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    "! Realizar Modificação da Parcela
    "! @parameter iv_bukrs    | Empresa
    "! @parameter iv_belnr    | Nº documento
    "! @parameter iv_gjahr    | Exercício
    "! @parameter iv_buzei    | Nº linha
    "! @parameter it_accchg   | Modificações de docs.FI
    "! @parameter ev_msg      | Mensagem de erro
    "! @parameter rv_subrc    | Retorno execução da BAPI
    METHODS modificar
      IMPORTING
        !iv_bukrs       TYPE bukrs
        !iv_belnr       TYPE belnr_d
        !iv_gjahr       TYPE gjahr
        !iv_buzei       TYPE buzei
        !it_accchg      TYPE fdm_t_accchg
      EXPORTING
        !ev_msg         TYPE bapi_msg
      RETURNING
        VALUE(rv_subrc) TYPE sy-subrc .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCLFI_MODIFICAR_AGEND_PARCELA IMPLEMENTATION.


  METHOD modificar.

    DATA(lt_accchg) = it_accchg[].

    SELECT bukrs, belnr, gjahr, buzei
      FROM bseg
      INTO TABLE @DATA(lt_bseg)
     WHERE bukrs EQ @iv_bukrs
       AND belnr EQ @iv_belnr
       AND gjahr EQ @iv_gjahr
       AND buzei EQ @iv_buzei.

    IF sy-subrc NE 0.
      rv_subrc = sy-subrc.
      ev_msg   = text-001.
      RETURN.
    ENDIF.

    CALL FUNCTION 'FI_DOCUMENT_CHANGE'
      EXPORTING
        i_buzei              = iv_buzei
        i_bukrs              = iv_bukrs
        i_belnr              = iv_belnr
        i_gjahr              = iv_gjahr
      TABLES
        t_accchg             = lt_accchg
      EXCEPTIONS
        no_reference         = 1
        no_document          = 2
        many_documents       = 3
        wrong_input          = 4
        overwrite_creditcard = 5
        OTHERS               = 6.

    IF sy-subrc <> 0.

      rv_subrc = sy-subrc.

      CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
        EXPORTING
          id         = sy-msgid
          number     = sy-msgno
          language   = sy-langu
          textformat = 'ASC'
          message_v1 = sy-msgv1
          message_v2 = sy-msgv2
          message_v3 = sy-msgv3
          message_v4 = sy-msgv4
        IMPORTING
          message    = ev_msg.

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    ELSE.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
