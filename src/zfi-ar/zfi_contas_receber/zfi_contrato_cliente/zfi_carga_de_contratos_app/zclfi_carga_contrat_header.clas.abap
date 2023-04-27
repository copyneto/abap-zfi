class ZCLFI_CARGA_CONTRAT_HEADER definition
  public
  final
  create public .

public section.

  methods UPLOAD_HEADER
    importing
      !IV_FILETYPE type ZE_CARGA_CONTRATOS
    exporting
      !ET_RETURN type BAPIRET2_T .
protected section.
private section.

  methods GET_NEXT_DOCUMENTNO
    exporting
      !ET_RETURN type BAPIRET2_T
    returning
      value(RV_DOCNUMBER) type ZTFI_CARGA_CONTH-DOCUMENTNO .
  methods GET_NEXT_GUID
    exporting
      !EV_GUID type SYSUUID_X16
      !ET_RETURN type BAPIRET2_T
    returning
      value(RV_GUID) type SYSUUID_X16 .
ENDCLASS.



CLASS ZCLFI_CARGA_CONTRAT_HEADER IMPLEMENTATION.


  METHOD get_next_documentno.

    DATA: ls_return TYPE bapiret2,
          lv_object TYPE nrobj VALUE 'ZFICARGATA',
          lv_range  TYPE nrnr  VALUE '01'.

    FREE: et_return, rv_docnumber.

* ---------------------------------------------------------------------------
* Travar objeto de numeração
* ---------------------------------------------------------------------------
    CALL FUNCTION 'NUMBER_RANGE_ENQUEUE'
      EXPORTING
        object           = lv_object
      EXCEPTIONS
        foreign_lock     = 1
        object_not_found = 2
        system_failure   = 3
        OTHERS           = 4.

    IF sy-subrc NE 0.
      et_return[] =  VALUE #( BASE et_return ( type = sy-msgty id = sy-msgid number = sy-msgno
                                               message_v1 = sy-msgv1
                                               message_v2 = sy-msgv2
                                               message_v3 = sy-msgv3
                                               message_v4 = sy-msgv4 ) ).
      RETURN.
    ENDIF.

* ---------------------------------------------------------------------------
* Recuperar novo número da requisição
* ---------------------------------------------------------------------------
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = lv_range
        object                  = lv_object
      IMPORTING
        number                  = rv_docnumber
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.

    IF sy-subrc NE 0.
      et_return[] =  VALUE #( BASE et_return ( type = sy-msgty id = sy-msgid number = sy-msgno
                                               message_v1 = sy-msgv1
                                               message_v2 = sy-msgv2
                                               message_v3 = sy-msgv3
                                               message_v4 = sy-msgv4 ) ).
    ENDIF.

* ---------------------------------------------------------------------------
* Destravar objeto de numeração
* ---------------------------------------------------------------------------
    CALL FUNCTION 'NUMBER_RANGE_DEQUEUE'
      EXPORTING
        object           = lv_object
      EXCEPTIONS
        object_not_found = 1
        OTHERS           = 2.

    IF sy-subrc NE 0.
      et_return[] =  VALUE #( BASE et_return ( type = sy-msgty id = sy-msgid number = sy-msgno
                                               message_v1 = sy-msgv1
                                               message_v2 = sy-msgv2
                                               message_v3 = sy-msgv3
                                               message_v4 = sy-msgv4 ) ).
    ENDIF.

  ENDMETHOD.


  METHOD get_next_guid.

    FREE: ev_guid.

    TRY.
        rv_guid = ev_guid = cl_system_uuid=>create_uuid_x16_static( ).

      CATCH cx_root INTO DATA(lo_root).
        DATA(lv_message) = CONV bapi_msg( lo_root->get_longtext( ) ).
        et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZCA_EXCEL' number = '000'
                                                message_v1 = lv_message+0(50)
                                                message_v2 = lv_message+50(50)
                                                message_v3 = lv_message+100(50)
                                                message_v4 = lv_message+150(50) ) ).
        RETURN.
    ENDTRY.
  ENDMETHOD.


  METHOD upload_header.

    DATA: ls_header TYPE ztfi_carga_conth.


    ls_header-doc_uuid_h             = me->get_next_guid( ).
    ls_header-documentno             = me->get_next_documentno( IMPORTING et_return = et_return ).
    ls_header-data_carga             = sy-datum.
    ls_header-tipo_carga             = iv_filetype.
    ls_header-created_by             = sy-uname.
    GET TIME STAMP FIELD ls_header-created_at.
    ls_header-local_last_changed_at  = ls_header-created_at.


    IF ls_header IS NOT INITIAL.

      MODIFY ztfi_carga_conth FROM ls_header.

      IF sy-subrc NE 0.
        " Falha ao salvar dados de carga.
        et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZFI_CARGA_CONTAB' number = '014' ) ).
        RETURN.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
