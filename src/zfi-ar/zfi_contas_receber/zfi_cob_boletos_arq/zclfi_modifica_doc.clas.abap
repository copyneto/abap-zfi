CLASS zclfi_modifica_doc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF  ty_bsid.
*             verzn TYPE verzn.
        INCLUDE TYPE zi_fi_canc_cli.
    TYPES: END OF ty_bsid .
    TYPES:
      BEGIN OF  ty_bsid_banc,
        verzn TYPE verzn.
        INCLUDE TYPE zi_fi_doc_canc_banc.
    TYPES: END OF ty_bsid_banc .
    TYPES:
      tt_bsid      TYPE TABLE OF ty_bsid .
    TYPES:
      tt_bsid_banc TYPE TABLE OF ty_bsid_banc .

    DATA gt_ret TYPE bapiret2_tab .
    DATA gt_return TYPE bapiret2_tab .

    METHODS change_doc
      EXPORTING
        !et_msg  TYPE zsfi_bapiret2   "bapiret2_tab
      CHANGING
        !ct_bsid TYPE tt_bsid .
    METHODS task_finish
      IMPORTING
        !p_task TYPE clike .
    METHODS change_doc_banc
      IMPORTING
        iv_report TYPE boolean OPTIONAL
      EXPORTING
        !et_msg   TYPE zsfi_bapiret2
      CHANGING
        !ct_bsid  TYPE tt_bsid_banc .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS: BEGIN OF gc_values,
                 fdname  TYPE fieldname VALUE 'DTWS1', "DTWS1',
                 olddata TYPE olddata VALUE 'A',
                 newval  TYPE newdata   VALUE '02',
                 erro    TYPE bapi_mtype  VALUE 'E',
               END OF gc_values.

    METHODS: fill_fields
      CHANGING ct_fields TYPE tpit_t_fname,
      fill_bseg_bapi
        IMPORTING is_bsid        TYPE ty_bsid
        RETURNING VALUE(rs_bseg) TYPE bseg,
      fill_buztab
        IMPORTING is_bsid   TYPE ty_bsid
        EXPORTING et_return TYPE tpit_t_buztab.


ENDCLASS.



CLASS zclfi_modifica_doc IMPLEMENTATION.


  METHOD change_doc.

    DATA(lt_bsid_cop) = ct_bsid.

    CLEAR: ct_bsid[].

    LOOP AT lt_bsid_cop ASSIGNING FIELD-SYMBOL(<fs_bsid>).

      CLEAR: gt_return[].

      DATA(ls_acchg) = VALUE accchg( fdname = gc_values-fdname newval = gc_values-newval ).

      CALL FUNCTION 'ZFMFI_DOCUMENT_CHANGE'
        STARTING NEW TASK 'BACKGROUND' CALLING task_finish ON END OF TASK
        EXPORTING
          iv_buzei = <fs_bsid>-buzei
          iv_bukrs = <fs_bsid>-bukrs
          iv_belnr = <fs_bsid>-belnr
          iv_gjahr = <fs_bsid>-gjahr
          is_acchg = ls_acchg
        TABLES
          et_ret   = me->gt_return.

      WAIT FOR ASYNCHRONOUS TASKS UNTIL me->gt_return IS NOT INITIAL.

      IF NOT line_exists( gt_return[ type = gc_values-erro ] ).
        APPEND <fs_bsid> TO ct_bsid.
      ENDIF.

      IF gt_return IS NOT INITIAL.

        et_msg = VALUE zsfi_bapiret2(
              belnr    = <fs_bsid>-belnr
              buzei    = <fs_bsid>-buzei
              bapiret2 = VALUE #( FOR ls_ret IN gt_return (
                                            type       = ls_ret-type
                                            id         = ls_ret-id
                                            number     = ls_ret-number
                                            message_v1 = ls_ret-message_v1
                                            message_v2 = ls_ret-message_v2
                                            message_v3 = ls_ret-message_v3
                                            message_v4 = ls_ret-message_v4
                                  ) )
         ).

*        APPEND INITIAL LINE TO et_msg ASSIGNING FIELD-SYMBOL(<fs_msg>).
*        <fs_msg> = VALUE #(
*          type       = VALUE #( gt_return[ 1 ]-type       OPTIONAL )
*          id         = VALUE #( gt_return[ 1 ]-id         OPTIONAL )
*          number     = VALUE #( gt_return[ 1 ]-number     OPTIONAL )
*          message_v1 = VALUE #( gt_return[ 1 ]-message_v1 OPTIONAL )
*          message_v2 = VALUE #( gt_return[ 1 ]-message_v2 OPTIONAL )
*          message_v3 = VALUE #( gt_return[ 1 ]-message_v3 OPTIONAL )
*          message_v4 = VALUE #( gt_return[ 1 ]-message_v4 OPTIONAL )
*        ).
*

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD fill_fields.

    FIELD-SYMBOLS <fs_field> LIKE LINE OF ct_fields.

    CLEAR ct_fields.

    APPEND INITIAL LINE TO ct_fields ASSIGNING <fs_field>.
    <fs_field>-fname = 'ZLSPR'.
    <fs_field>-aenkz = abap_true.

  ENDMETHOD.


  METHOD fill_bseg_bapi.

    rs_bseg  = VALUE bseg(
        bukrs = is_bsid-bukrs
        belnr = is_bsid-belnr
        gjahr = is_bsid-gjahr
        buzei = is_bsid-buzei
        zlspr = space ).

  ENDMETHOD.


  METHOD fill_buztab.

    APPEND INITIAL LINE TO et_return ASSIGNING FIELD-SYMBOL(<fs_buztab>).
    <fs_buztab>-bukrs = is_bsid-bukrs.
    <fs_buztab>-belnr = is_bsid-belnr.
    <fs_buztab>-gjahr = is_bsid-gjahr.
    <fs_buztab>-buzei = is_bsid-buzei.

  ENDMETHOD.


  METHOD task_finish.

    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_DOCUMENT_CHANGE'
      TABLES
        et_ret = me->gt_return.

    RETURN.

  ENDMETHOD.


  METHOD change_doc_banc.

    DATA(lt_bsid_cop) = ct_bsid.

    CLEAR: ct_bsid[].

    LOOP AT lt_bsid_cop ASSIGNING FIELD-SYMBOL(<fs_bsid>).

      IF <fs_bsid>-anfbn IS NOT INITIAL.

        CLEAR: gt_return[].

        DATA(ls_acchg) = VALUE accchg( fdname = gc_values-fdname  newval = gc_values-newval ).

        IF iv_report = abap_true.

          CALL FUNCTION 'ZFMFI_DOCUMENT_CHANGE'
            STARTING NEW TASK 'BACKGROUND' CALLING task_finish ON END OF TASK
            EXPORTING
              iv_buzei = <fs_bsid>-buzei
              iv_bukrs = <fs_bsid>-bukrs
              iv_belnr = <fs_bsid>-belnr
              iv_gjahr = <fs_bsid>-gjahr
              is_acchg = ls_acchg
            TABLES
              et_ret   = me->gt_return.

        ELSE.

          CALL FUNCTION 'ZFMFI_DOCUMENT_CHANGE'
            STARTING NEW TASK 'BACKGROUND' CALLING task_finish ON END OF TASK
            EXPORTING
              iv_buzei = <fs_bsid>-rebzz
              iv_bukrs = <fs_bsid>-bukrs
              iv_belnr = <fs_bsid>-rebzg
              iv_gjahr = <fs_bsid>-rebzj
              is_acchg = ls_acchg
            TABLES
              et_ret   = me->gt_return.



        ENDIF.

        WAIT FOR ASYNCHRONOUS TASKS UNTIL me->gt_return IS NOT INITIAL.

        IF NOT line_exists( gt_return[ type = gc_values-erro ] ).
          APPEND <fs_bsid> TO ct_bsid.
        ENDIF.

        IF gt_return IS NOT INITIAL.

          et_msg = VALUE zsfi_bapiret2(
           belnr    = <fs_bsid>-belnr
           buzei    = <fs_bsid>-buzei
           bapiret2 = VALUE #( FOR ls_ret IN gt_return (
                                      type       = ls_ret-type
                                      id         = ls_ret-id
                                      number     = ls_ret-number
                                      message_v1 = ls_ret-message_v1
                                      message_v2 = ls_ret-message_v2
                                      message_v3 = ls_ret-message_v3
                                      message_v4 = ls_ret-message_v4
                            ) )
          ).

        ENDIF.

      ELSE.

        "Sol.LC Branco Fatura & & & Não houve modificações.
        et_msg = VALUE zsfi_bapiret2(
           belnr    = <fs_bsid>-belnr
           buzei    = <fs_bsid>-buzei
           bapiret2 = VALUE #( (
                                      type       = 'S'
                                      id         = 'ZFI_BOLETO'
                                      number     = '017'
                                      message_v1 = <fs_bsid>-belnr
                                      message_v2 = <fs_bsid>-gjahr
                                      message_v3 = <fs_bsid>-bukrs
                            ) )
          ).


      ENDIF.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
