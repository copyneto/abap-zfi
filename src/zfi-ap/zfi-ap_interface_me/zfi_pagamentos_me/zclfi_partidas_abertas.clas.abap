class ZCLFI_PARTIDAS_ABERTAS definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_bsik,
             bukrs TYPE bukrs,
             gjahr TYPE gjahr,
             lifnr TYPE lifnr,
             xblnr TYPE xblnr1,
             belnr TYPE belnr_d,
*             fdtag TYPE fdtag,
             bldat TYPE bldat,
             budat TYPE budat,
             blart TYPE blart,
             zterm TYPE dzterm,
             skfbt TYPE skfbt,
             sgtxt TYPE sgtxt,
             ebeln TYPE ebeln,
             wrbtr TYPE wrbtr,
             zlsch TYPE schzw_bseg,
           END OF ty_bsik .

  data GS_DOCUMENTHEADER type BAPIACHE09 .
  data GV_OBJ_KEY type BAPIACHE09-OBJ_KEY .
  data GS_OUTPUT type ZCLFI_MT_CONTAS_APAGAR .
  data GT_CONTAS_APAGAR_CON_TAB type ZCLFI_DT_CONTAS_APAGAR_CO_TAB1 .
  data:
    gt_bsik                  TYPE TABLE OF ty_bsik .
  data GS_BSIK type TY_BSIK .

      "! Constructor
  methods CONSTRUCTOR
    importing
      !IV_OBJ_KEY type BAPIACHE09-OBJ_KEY
      !IS_DOCUMENTHEADER type BAPIACHE09 optional .
      "! Envia dados processados para a interface do mercado eletronico
  methods SEND_INTERFACE_ME
    exceptions
      ZCXCA_ERRO_INTERFACE .
  PROTECTED SECTION.
  PRIVATE SECTION.


    CONSTANTS: BEGIN OF gc_erros,
                 interface TYPE string VALUE 'SIENVIARCONTASAPAGAROUT'  ##NO_TEXT,
                 metodo    TYPE string VALUE 'interface_me'               ##NO_TEXT,
                 classe    TYPE string VALUE 'ZCLFI_PARTIDAS_ABERTAS'     ##NO_TEXT,
               END OF gc_erros.

    METHODS:

      "! Processa Dados da BAPI
      process_data,

      "! Return error raising
      error_raise
        IMPORTING
          is_ret TYPE scx_t100key
        RAISING
          zcxca_erro_interface.

ENDCLASS.



CLASS ZCLFI_PARTIDAS_ABERTAS IMPLEMENTATION.


  METHOD constructor.
    MOVE iv_obj_key TO gv_obj_key.
    MOVE-CORRESPONDING is_documentheader TO gs_documentheader.
    me->process_data( ).
  ENDMETHOD.


  METHOD process_data.

    SELECT bukrs,
           gjahr,
           lifnr,
           xblnr,
           belnr,
           bldat,
           budat,
           blart,
           zterm,
           skfbt,
           sgtxt,
           ebeln,
           wrbtr,
           zlsch
        INTO TABLE @gt_bsik
        FROM bsik_view
        WHERE belnr = @gv_obj_key(10).
    IF sy-subrc = 0.

      SELECT ebeln,
             ebelp,
             ped_me,
             mblnr,
             docnum,
             elikz,
             lifnr
          INTO TABLE @DATA(lt_pedido_me)
          FROM ztmm_pedido_me
          FOR ALL ENTRIES IN @gt_bsik
          WHERE ebeln = @gt_bsik-ebeln.
      IF sy-subrc = 0.

        DATA: ls_contas_apagar_borgs TYPE zclfi_dt_contas_apagar_borgs1,
              lv_skfbt               TYPE skfbt.

        LOOP AT gt_bsik ASSIGNING FIELD-SYMBOL(<fs_bsik>).

          ls_contas_apagar_borgs-wrbtr      = <fs_bsik>-wrbtr.
          ls_contas_apagar_borgs-zlsch      = <fs_bsik>-zlsch.
          ls_contas_apagar_borgs-with_item  = <fs_bsik>-bukrs && <fs_bsik>-belnr && <fs_bsik>-gjahr.

          IF <fs_bsik>-skfbt NE 0.
            lv_skfbt = <fs_bsik>-skfbt.
          ELSE.
            lv_skfbt = <fs_bsik>-wrbtr.
          ENDIF.

          APPEND VALUE #(
              lifnr = <fs_bsik>-lifnr
              xblnr = <fs_bsik>-xblnr
              belnr = <fs_bsik>-belnr
*              fdtag = <fs_bsik>-fd
              bldat = <fs_bsik>-bldat
              budat = <fs_bsik>-budat
              blart = <fs_bsik>-blart
              zterm = <fs_bsik>-zterm
              skfbt = lv_skfbt
              sgtxt = <fs_bsik>-sgtxt
              ebeln = <fs_bsik>-ebeln
              borgs = ls_contas_apagar_borgs
          ) TO gt_contas_apagar_con_tab.

        ENDLOOP.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD send_interface_me.

    TRY.

        NEW zclfi_co_si_enviar_contas_apag(  )->si_enviar_contas_apagar_out(
            EXPORTING
               output = VALUE zclfi_mt_contas_apagar( mt_contas_apagar-msg_contas_apagar_list-itens-conta_apagar = gt_contas_apagar_con_tab )
         ).

      CATCH cx_ai_system_fault.
    ENDTRY.

  ENDMETHOD.


  METHOD error_raise.
    RAISE EXCEPTION TYPE zcxca_erro_interface
      EXPORTING
        textid = VALUE #(
                          attr1 = is_ret-attr1
                          attr2 = is_ret-attr2
                          attr3 = is_ret-attr3
                          msgid = is_ret-msgid
                          msgno = is_ret-msgno
                          ).
  ENDMETHOD.
ENDCLASS.
