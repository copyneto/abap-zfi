"!<p>Classe Consultar Status PDC</p>
"!<p><strong>Autor:</strong>Marcos Rubik</p>
"!<p><strong>Data:</strong> 04 de Março de 2022</p>
class ZCLFI_CONSULTAR_STATUS_PDC definition
  public
  create public .

public section.

  types:
    BEGIN OF ty_bseg_ret,
             bukrs TYPE bseg-bukrs,
             belnr TYPE bseg-belnr,
             gjahr TYPE bseg-gjahr,
             buzei TYPE bseg-buzei,
             augbl TYPE bseg-augbl,
             augdt TYPE bseg-augdt,
             hkont TYPE bseg-hkont,
           END OF ty_bseg_ret .
  types:
    tt_bseg_ret TYPE TABLE OF ty_bseg_ret .

  data:
    gr_agend     TYPE RANGE OF blart .
  data:
    gr_provi     TYPE RANGE OF blart .
  constants:
    BEGIN OF gc_status,
                 provisionado VALUE 'P',
                 agendado     VALUE 'A',
                 liquidado    VALUE 'L',
                 estornado    VALUE 'E',
               END OF gc_status .
  constants:
    BEGIN OF gc_param,
                 modulo   TYPE ztca_param_par-modulo VALUE 'FI-AR',
                 chave1   TYPE ztca_param_par-chave1 VALUE 'PDC',
                 chave3   TYPE ztca_param_par-chave3 VALUE 'TIPODOC',
                 agend    TYPE ztca_param_par-chave2 VALUE 'STATUSAGENDADO',
                 provi    TYPE ztca_param_par-chave2 VALUE 'STATUSPROVISIONADO',
               END OF gc_param .

  methods CONSTRUCTOR .
    "! Realizar consulta do status
    "! @parameter iv_BUKRS | Empresa
    "! @parameter iv_TIPO_DOC | Tipo de documento
    "! @parameter iv_XBLNR    | Nº documento de referência
    "! @parameter ev_BELNR    | Atribuição nºs item doc.material - doc.compra
    "! @parameter ev_GJAHR    | Exercício
    "! @parameter ev_STATUS   | Status
    "! @parameter ev_AUGDT    | Data de compensação
    "! @parameter ev_XBLNR    | Nº documento de referência
  methods CONSULTAR
    importing
      !IV_BUKRS type BUKRS
      !IV_TIPO_DOC type CHAR1
      !IV_XBLNR type XBLNR
    exporting
      !EV_BELNR type BELNR_D
      !EV_GJAHR type GJAHR
      !EV_STATUS type CHAR1
      !EV_AUGDT type AUGDT
      !EV_XBLNR type XBLNR
      !ET_PARCELAS type ZCTGFI_BUSC_PARCELAS .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCLFI_CONSULTAR_STATUS_PDC IMPLEMENTATION.


  METHOD constructor.
      DATA(lo_param) = zclca_tabela_parametros=>get_instance( ). " CHANGE - LSCHEPP - 20.07.2023

      TRY.
          lo_param->m_get_range( EXPORTING iv_modulo = gc_param-modulo
                                           iv_chave1 = gc_param-chave1
                                           iv_chave2 = gc_param-agend
                                           iv_chave3 = gc_param-chave3
                                 IMPORTING et_range  = gr_agend ).

          lo_param->m_get_range( EXPORTING iv_modulo = gc_param-modulo
                                           iv_chave1 = gc_param-chave1
                                           iv_chave2 = gc_param-provi
                                           iv_chave3 = gc_param-chave3
                                 IMPORTING et_range  = gr_provi ).

        CATCH zcxca_tabela_parametros INTO DATA(lo_cx).
          WRITE lo_cx->get_text( ).
      ENDTRY.
  ENDMETHOD.


  METHOD consultar.
    DATA: lt_bseg TYPE tt_bseg_ret.

    DATA: ls_bseg TYPE ty_bseg_ret.

    DATA: lv_status TYPE char1.

    DATA: lr_hkont TYPE RANGE OF bseg-hkont,
          lr_blart TYPE RANGE OF bkpf-blart.

    DATA: lv_xblnr TYPE string.

    CHECK NOT iv_bukrs IS INITIAL.
    CHECK iv_tipo_doc = gc_status-provisionado OR iv_tipo_doc = gc_status-agendado.
    CHECK NOT iv_xblnr IS INITIAL.

    lr_blart[] = COND #( WHEN iv_tipo_doc = gc_status-provisionado THEN gr_provi[] ELSE gr_agend[] ).

    IF iv_xblnr CS '-'.
      SELECT bukrs,
             belnr,
             gjahr,
             blart,
             stblg,
             xref1_hd,
             xblnr
        FROM bkpf
       WHERE bstat = @space
         AND bukrs = @iv_bukrs
         AND xblnr = @iv_xblnr
         AND blart IN @lr_blart
        INTO TABLE @DATA(lt_bkpf).
    ELSE.

      lv_xblnr = iv_xblnr && '%'.

      SELECT bukrs,
             belnr,
             gjahr,
             blart,
             stblg,
             xref1_hd,
             xblnr
        FROM bkpf
       WHERE bstat = @space
         AND bukrs = @iv_bukrs
         AND xblnr LIKE @lv_xblnr
         AND blart IN @lr_blart
        INTO TABLE @lt_bkpf.
    ENDIF.

    CHECK sy-subrc = 0.

*    IF iv_tipo_doc EQ gc_status-provisionado.
*
*      lv_status = iv_tipo_doc.
*
*    ELSE.

    CLEAR: ls_bseg,
           lt_bseg[].

    DATA(lt_bkpf_fae) = lt_bkpf[].

    SORT lt_bkpf_fae BY bukrs
                        belnr
                        gjahr.

    DELETE ADJACENT DUPLICATES FROM lt_bkpf_fae COMPARING bukrs
                                                          belnr
                                                          gjahr.

    SELECT bukrs,
           belnr,
           gjahr,
           buzei,
           augbl,
           augdt,
           hkont
      FROM bseg
       FOR ALL ENTRIES IN @lt_bkpf_fae
      WHERE bukrs = @lt_bkpf_fae-bukrs
        AND belnr = @lt_bkpf_fae-belnr
        AND gjahr = @lt_bkpf_fae-gjahr
        AND koart = 'K'
        AND bschl = '31'
       INTO TABLE @lt_bseg.

    IF sy-subrc IS INITIAL.
      SORT lt_bseg BY bukrs
                      belnr
                      gjahr.
    ENDIF.

*      READ TABLE lt_bseg INTO ls_bseg INDEX 1.
*
*      IF NOT ls_bkpf-stblg IS INITIAL.
*        lv_status = gc_status-estornado.
*      ELSE.
*        IF ls_bseg-augbl IS INITIAL.
*          lv_status = gc_status-agendado.
*        ELSE.
*          lv_status = gc_status-liquidado.
*        ENDIF.
*        IF ls_bkpf-blart IN gr_provi.
*          IF ls_bkpf-xref1_hd(4) = 'APPR'.
*            lv_status = gc_status-estornado.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*
*    ENDIF.

    LOOP AT lt_bkpf ASSIGNING FIELD-SYMBOL(<fs_bkpf>).

      IF iv_tipo_doc EQ gc_status-provisionado.

        lv_status = iv_tipo_doc.

      ELSE.

        READ TABLE lt_bseg ASSIGNING FIELD-SYMBOL(<fs_bseg>)
                                         WITH KEY bukrs = <fs_bkpf>-bukrs
                                                  belnr = <fs_bkpf>-belnr
                                                  gjahr = <fs_bkpf>-gjahr
                                                  BINARY SEARCH.
        IF sy-subrc IS INITIAL.

          IF <fs_bkpf>-stblg IS NOT INITIAL.
            lv_status = gc_status-estornado.
          ELSE.
            IF <fs_bseg>-augbl IS INITIAL.
              lv_status = gc_status-agendado.
            ELSE.
              lv_status = gc_status-liquidado.
            ENDIF.
            IF <fs_bkpf>-blart IN gr_provi.
              IF <fs_bkpf>-xref1_hd(4) = 'APPR'.
                lv_status = gc_status-estornado.
              ENDIF.
            ENDIF.
          ENDIF.

        ELSE.

          IF <fs_bkpf>-stblg IS NOT INITIAL.
            lv_status = gc_status-estornado.
          ELSE.
            IF <fs_bkpf>-blart IN gr_provi.
              IF <fs_bkpf>-xref1_hd(4) = 'APPR'.
                lv_status = gc_status-estornado.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF <fs_bseg> IS ASSIGNED.
        IF <fs_bseg>-augbl IS NOT INITIAL
       AND <fs_bseg>-augdt IS NOT INITIAL.

          NEW zclfi_verificar_pag_efetuado(  )->verifica( EXPORTING iv_bukrs  = <fs_bseg>-bukrs
                                                                    iv_belnr  = <fs_bseg>-belnr
                                                                    iv_gjahr  = <fs_bseg>-gjahr
                                                          RECEIVING rv_return = DATA(lv_pagefetuado) ).

          IF lv_pagefetuado IS NOT INITIAL.
            " Status compensada e paga.
            lv_status = gc_status-liquidado.
          ENDIF.

        ENDIF.
      ENDIF.

      " Retornos de processamento
      et_parcelas = VALUE #( BASE et_parcelas ( belnr  = <fs_bkpf>-belnr
                                                gjahr  = <fs_bkpf>-gjahr
                                                status = lv_status
                                                augdt  = COND #( WHEN ev_status = gc_status-liquidado THEN ls_bseg-augdt )
*                                                xblnr  = <fs_bkpf>-xblnr ) ).
                                                xblnr  = COND #( WHEN iv_tipo_doc        = gc_status-provisionado
                                                                  AND <fs_bkpf>-xref1_hd IS NOT INITIAL THEN |{ <fs_bkpf>-xblnr && '-' && <fs_bkpf>-xref1_hd }|
                                                                    ELSE <fs_bkpf>-xblnr ) ) ).

*      " Retornos de processamento
*      ev_belnr  = ls_bkpf-belnr.
*      ev_gjahr  = ls_bkpf-gjahr.
*      ev_status = lv_status.
*
*      IF ev_status = gc_status-liquidado.
*        ev_augdt = ls_bseg-augdt.
*      ENDIF.
*
*      ev_xblnr = iv_xblnr.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
