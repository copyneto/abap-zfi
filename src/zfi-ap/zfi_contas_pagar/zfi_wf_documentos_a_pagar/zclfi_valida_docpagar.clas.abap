"!<p>Validações para <strong>Documentos a pagar em FI</strong>. <br/>
"! Esta classe é utilizada no Pool de módulos <em>ZRGGBR000</em> <br/> <br/>
"!<p><strong>Autor:</strong> Anderson Miazato - Meta</p>
"!<p><strong>Data:</strong> 30/nov/2021</p>
class ZCLFI_VALIDA_DOCPAGAR definition
  public
  final
  create public .

public section.

  constants:
      "! Valores possíveis para Resultado da Validação
    BEGIN OF gc_result,
        true  TYPE c VALUE 'T',
        false TYPE c VALUE 'F',
      END OF gc_result .
  constants GC_SEPARA_DEPARTAMENTO type C value '/' ##NO_TEXT.

      "! Validação Exit do Form U101
      "! @parameter iv_DocType | Tipo do documento a ser validado
      "! @parameter iv_Text    | Texto do cabeçalho/Departamento
      "! @parameter cv_result  | Resultado da validação (T ou F)
  methods VALIDA_U101
    importing
      !IV_DOCTYPE type BLART
      !IV_TEXT type BKTXT
    changing
      !CV_RESULT type C .
  methods VALIDA_U102
    importing
      !IV_BKPF type BKPF
      !IV_BSEG type BSEG
    changing
      !CV_RESULT type C .
  PROTECTED SECTION.
private section.
ENDCLASS.



CLASS ZCLFI_VALIDA_DOCPAGAR IMPLEMENTATION.


  METHOD valida_u101.

    DATA:
      lt_outlines TYPE STANDARD TABLE OF sy-msgv1.

    DATA:
      lt_textos_validos TYPE SORTED TABLE OF string WITH NON-UNIQUE KEY table_line.

    DATA:
      lv_departamentos(200) TYPE c.

    SELECT documenttext
      FROM zi_fi_wf_docpagar
        WHERE documenttype EQ @iv_doctype
      INTO TABLE @lt_textos_validos.

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

*    IF line_exists( lt_textos_validos[ table_line = to_upper( iv_text ) ] ).
    IF line_exists( lt_textos_validos[ table_line = iv_text ] ).
      RETURN.
    ENDIF.

    LOOP AT lt_textos_validos ASSIGNING FIELD-SYMBOL(<fs_textos_validos>).

      IF lv_departamentos IS INITIAL.

        lv_departamentos = <fs_textos_validos>.
        CONTINUE.
      ENDIF.

      lv_departamentos = lv_departamentos && gc_separa_departamento && |{ <fs_textos_validos> }|.

    ENDLOOP.

    CONDENSE lv_departamentos NO-GAPS.

    CALL FUNCTION 'RKD_WORD_WRAP'
      EXPORTING
        textline            = lv_departamentos
        delimiter           = gc_separa_departamento
        outputlen           = 50
      TABLES
        out_lines           = lt_outlines
      EXCEPTIONS
        outputlen_too_large = 1
        OTHERS              = 2.

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.


    cv_result = gc_result-false.

    " Separa departamentos por variável de mensagem para exibição na tela da mensagem
    DATA(lv_msgv1) = COND sy-msgv1( WHEN line_exists( lt_outlines[ 1 ] ) THEN lt_outlines[ 1 ] ).

    DATA(lv_msgv2) = COND sy-msgv2( WHEN line_exists( lt_outlines[ 2 ] ) THEN lt_outlines[ 2 ] ).

    DATA(lv_msgv3) = COND sy-msgv3( WHEN line_exists( lt_outlines[ 3 ] ) THEN lt_outlines[ 3 ] ).

    DATA(lv_msgv4) = COND sy-msgv4( WHEN line_exists( lt_outlines[ 4 ] ) THEN lt_outlines[ 4 ] ).

    MESSAGE e001(zfi_wf_docpagar) WITH lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.

  ENDMETHOD.


  METHOD valida_u102.

    DATA: lv_wf TYPE char02.

    IMPORT lv_wf TO lv_wf FROM MEMORY ID 'ZCLFI_DOC_PAGAR_WF'.

    CHECK lv_wf NE abap_true.

    SELECT SINGLE zlspr
             FROM bseg
             INTO @DATA(lv_zlspr)
            WHERE bukrs EQ @iv_bseg-bukrs
              AND belnr EQ @iv_bseg-belnr
              AND gjahr EQ @iv_bseg-gjahr
              AND buzei EQ @iv_bseg-buzei.

    CHECK sy-subrc EQ 0 AND lv_zlspr EQ 'A'.

    SELECT documenttext
      FROM zi_fi_wf_docpagar
     WHERE documenttype EQ @iv_bkpf-blart
INTO TABLE @DATA(lt_textos_validos).

    IF sy-subrc EQ 0.
      IF line_exists( lt_textos_validos[ table_line = to_upper( iv_bkpf-bktxt ) ] )."#EC CI_STDSEQ
        cv_result = gc_result-true.
        MESSAGE e002(zfi_wf_docpagar).
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
