class ZCLFI_CICLOS_CESCIM_CONTRAT definition
  public
  final
  create public .

public section.

  methods CHECK_CICLO
    importing
      !IV_PERIODICIDADE type ZE_PERIODIC
      !IT_CICLOS type ZCTGFI_CICLOS_CRESC_CTRT
    exporting
      !ES_RETURN type BAPIRET2 .
protected section.
private section.

  constants GC_MSGID type SY-MSGID value 'ZFI_CONTRATO_CLIENTE' ##NO_TEXT.
  constants GC_ERROR type SY-MSGTY value 'E' ##NO_TEXT.
  constants GC_SUCESS type SY-MSGTY value 'S' ##NO_TEXT.
  constants GC_E_CLO_1 type SY-MSGNO value '022' ##NO_TEXT.
  constants GC_E_CLO_1_2 type SY-MSGNO value '023' ##NO_TEXT.
  constants GC_E_CLO_2 type SY-MSGNO value '024' ##NO_TEXT.
  constants GC_E_CLO_2_2 type SY-MSGNO value '025' ##NO_TEXT.
  constants GC_E_CLO_3 type SY-MSGNO value '026' ##NO_TEXT.
  constants GC_E_CLO_3_2 type SY-MSGNO value '027' ##NO_TEXT.
  constants GC_E_CLO_4 type SY-MSGNO value '028' ##NO_TEXT.
  constants GC_E_CLO_4_2 type SY-MSGNO value '029' ##NO_TEXT.
  constants GC_E_CLO_5 type SY-MSGNO value '030' ##NO_TEXT.
  constants GC_E_CLO_5_2 type SY-MSGNO value '031' ##NO_TEXT.
  constants GC_E_CLO_6 type SY-MSGNO value '032' ##NO_TEXT.
ENDCLASS.



CLASS ZCLFI_CICLOS_CESCIM_CONTRAT IMPLEMENTATION.


  METHOD check_ciclo.

    CASE iv_periodicidade.
      WHEN 'A'. " Anual
        IF lines( it_ciclos ) > 1.

          es_return-id     = gc_msgid.
          es_return-type   = gc_error.
          es_return-number = gc_e_clo_1.

        ELSE.

          LOOP AT it_ciclos ASSIGNING FIELD-SYMBOL(<fs_ciclos>).

            IF <fs_ciclos>-ciclo NE '01'.

              es_return-id     = gc_msgid.
              es_return-type   = gc_error.
              es_return-number = gc_e_clo_1_2.

              EXIT.
            ENDIF.
          ENDLOOP.

        ENDIF.

      WHEN 'S'. " Semestral
        IF lines( it_ciclos ) > 2.

          es_return-id     = gc_msgid.
          es_return-type   = gc_error.
          es_return-number = gc_e_clo_2.

        ELSE.

          LOOP AT it_ciclos ASSIGNING <fs_ciclos>.

            IF <fs_ciclos>-ciclo NE '01'
           AND <fs_ciclos>-ciclo NE '02'.

              es_return-id     = gc_msgid.
              es_return-type   = gc_error.
              es_return-number = gc_e_clo_2_2.

              EXIT.
            ENDIF.
          ENDLOOP.

        ENDIF.

      WHEN 'Q'. " Quadrimestral
        IF lines( it_ciclos ) > 3.

          es_return-id     = gc_msgid.
          es_return-type   = gc_error.
          es_return-number = gc_e_clo_3.

        ELSE.

          LOOP AT it_ciclos ASSIGNING <fs_ciclos>.

            IF <fs_ciclos>-ciclo NE '01'
           AND <fs_ciclos>-ciclo NE '02'
           AND <fs_ciclos>-ciclo NE '03'.

              es_return-id     = gc_msgid.
              es_return-type   = gc_error.
              es_return-number = gc_e_clo_3_2.

              EXIT.
            ENDIF.
          ENDLOOP.

        ENDIF.

      WHEN 'T'. " Trimestral
        IF lines( it_ciclos ) > 4.

          es_return-id     = gc_msgid.
          es_return-type   = gc_error.
          es_return-number = gc_e_clo_4.

        ELSE.

          LOOP AT it_ciclos ASSIGNING <fs_ciclos>.

            IF <fs_ciclos>-ciclo NE '01'
           AND <fs_ciclos>-ciclo NE '02'
           AND <fs_ciclos>-ciclo NE '03'
           AND <fs_ciclos>-ciclo NE '04'.

              es_return-id     = gc_msgid.
              es_return-type   = gc_error.
              es_return-number = gc_e_clo_4_2.

              EXIT.
            ENDIF.
          ENDLOOP.

        ENDIF.

      WHEN 'B'. " Bimestral
        IF lines( it_ciclos ) > 6.

          es_return-id     = gc_msgid.
          es_return-type   = gc_error.
          es_return-number = gc_e_clo_5.

        ELSE.

          LOOP AT it_ciclos ASSIGNING <fs_ciclos>.

            IF <fs_ciclos>-ciclo NE '01'
           AND <fs_ciclos>-ciclo NE '02'
           AND <fs_ciclos>-ciclo NE '03'
           AND <fs_ciclos>-ciclo NE '04'
           AND <fs_ciclos>-ciclo NE '05'
           AND <fs_ciclos>-ciclo NE '06'.

              es_return-id     = gc_msgid.
              es_return-type   = gc_error.
              es_return-number = gc_e_clo_5_2.

              EXIT.
            ENDIF.
          ENDLOOP.

        ENDIF.

      WHEN 'M'. " Mensal
        IF lines( it_ciclos ) > 12.

          es_return-id     = gc_msgid.
          es_return-type   = gc_error.
          es_return-number = gc_e_clo_6.

        ENDIF.

      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
