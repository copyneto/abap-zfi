CLASS lcl_Job DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF gc_job_erro,
        id     TYPE symsgid VALUE 'ZFI_AUTO_TXT_CONTAB',
        number TYPE symsgno VALUE '014',
      END OF gc_job_erro,

      BEGIN OF gc_job_concluido,
        id     TYPE symsgid VALUE 'ZFI_AUTO_TXT_CONTAB',
        number TYPE symsgno VALUE '013',
      END OF gc_job_concluido,

      BEGIN OF gc_range_posting_date,
        id     TYPE symsgid VALUE 'ZFI_AUTO_TXT_CONTAB',
        number TYPE symsgno VALUE '012',
      END OF gc_range_posting_date,

      BEGIN OF gc_campo_ate_inferior,
        id     TYPE symsgid VALUE 'ZFI_AUTO_TXT_CONTAB',
        number TYPE symsgno VALUE '018',
      END OF gc_campo_ate_inferior,

      BEGIN OF gc_campo_obrigatorio,
        id     TYPE symsgid VALUE 'ZFI_AUTO_TXT_CONTAB',
        number TYPE symsgno VALUE '011',
      END OF gc_campo_obrigatorio.

    METHODS ExecutaJob FOR MODIFY
      IMPORTING keys FOR ACTION Job~ExecutaJob.

    METHODS SetJobSchedule FOR DETERMINE ON SAVE
      IMPORTING keys FOR Job~SetJobSchedule.

    METHODS CheckJob FOR VALIDATE ON SAVE
      IMPORTING keys FOR Job~CheckJob.

    METHODS authorityCreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Job~authorityCreate.

ENDCLASS.

CLASS lcl_Job IMPLEMENTATION.

  METHOD CheckJob.

    READ ENTITIES OF zi_fi_autotxt_exec_manual IN LOCAL MODE
      ENTITY Job
        FIELDS ( Id
                 Jobname
                 CompanyCodeStart
                 CompanyCodeEnd
                 FiscalYearStart
                 FiscalYearEnd
                 PostingDateStart
                 PostingDateEnd ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_screen) FAILED DATA(ls_erros).


    IF lt_screen IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_screen ASSIGNING FIELD-SYMBOL(<fs_screen>).

      APPEND VALUE #(
        %tky        = <fs_screen>-%tky
        %state_area = 'VALIDA_JOB' )
      TO reported-job.

      IF <fs_screen>-Jobname IS INITIAL.

        APPEND VALUE #( %tky = <fs_screen>-%tky ) TO failed-job.

        APPEND VALUE #(
          %tky        = <fs_screen>-%tky
          %state_area = 'VALIDA_JOB'
          %msg        =  new_message(
            id       = gc_campo_obrigatorio-id
            number   = gc_campo_obrigatorio-number
            severity = if_abap_behv_message=>severity-error
          )
          %element-jobname = if_abap_behv=>mk-on
        ) TO reported-job.

      ENDIF.

      IF  <fs_screen>-CompanyCodeStart GT <fs_screen>-CompanyCodeEnd
        AND <fs_screen>-CompanyCodeEnd IS NOT INITIAL.

        APPEND VALUE #( %tky = <fs_screen>-%tky ) TO failed-job.

        APPEND VALUE #(
          %tky        = <fs_screen>-%tky
          %state_area = 'VALIDA_JOB'
          %msg        =  new_message(
            id       = gc_campo_ate_inferior-id
            number   = gc_campo_ate_inferior-number
            severity = if_abap_behv_message=>severity-error
          )
          %element-companycodestart = if_abap_behv=>mk-on
          %element-companycodeend = if_abap_behv=>mk-on
        ) TO reported-job.

      ENDIF.

      IF  <fs_screen>-FiscalYearStart GT <fs_screen>-FiscalYearEnd
        AND <fs_screen>-FiscalYearEnd IS NOT INITIAL.

        APPEND VALUE #( %tky = <fs_screen>-%tky ) TO failed-job.

        APPEND VALUE #(
          %tky        = <fs_screen>-%tky
          %state_area = 'VALIDA_JOB'
          %msg        =  new_message(
            id       = gc_campo_ate_inferior-id
            number   = gc_campo_ate_inferior-number
            severity = if_abap_behv_message=>severity-error
          )
          %element-FiscalYearstart = if_abap_behv=>mk-on
          %element-FiscalYearend = if_abap_behv=>mk-on
        ) TO reported-job.

      ENDIF.

      IF  <fs_screen>-PostingDateStart GT <fs_screen>-PostingDateEnd
        AND <fs_screen>-PostingDateEnd IS NOT INITIAL.

        APPEND VALUE #( %tky = <fs_screen>-%tky ) TO failed-job.

        APPEND VALUE #(
          %tky        = <fs_screen>-%tky
          %state_area = 'VALIDA_JOB'
          %msg        =  new_message(
            id       = gc_range_posting_date-id
            number   = gc_range_posting_date-number
            severity = if_abap_behv_message=>severity-error
          )
          %element-postingdatestart = if_abap_behv=>mk-on
          %element-postingdateend = if_abap_behv=>mk-on
        ) TO reported-job.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD SetJobSchedule.

    DATA:
      lr_bukrs TYPE RANGE OF bukrs,
      lr_gjahr TYPE RANGE OF gjahr,
      lr_budat TYPE RANGE OF budat.

    DATA:
      lv_jobcount TYPE btcjobcnt.

    READ ENTITIES OF zi_fi_autotxt_exec_manual IN LOCAL MODE
        ENTITY Job
            FIELDS ( Jobname
                     CompanyCodeStart
                     CompanyCodeEnd
                     FiscalYearStart
                     FiscalYearEnd
                     PostingDateStart
                     PostingDateEnd
                     ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_screen_info).

    READ TABLE lt_screen_info ASSIGNING FIELD-SYMBOL(<fs_screen_info>) INDEX 1.
    IF sy-subrc IS INITIAL.

      "Criação do job
      CALL FUNCTION 'JOB_OPEN'
        EXPORTING
          jobname          = <fs_screen_info>-JobName
        IMPORTING
          jobcount         = lv_jobcount
        EXCEPTIONS
          cant_create_job  = 1
          invalid_job_data = 2
          jobname_missing  = 3
          OTHERS           = 4.

      IF sy-subrc NE 0.
        RETURN.
      ENDIF.

      IF <fs_screen_info>-CompanyCodeStart IS NOT INITIAL.

        lr_bukrs = VALUE  #( ( sign = rsmds_c_sign-including
                               option = COND #( WHEN <fs_screen_info>-CompanyCodeEnd IS NOT INITIAL
                                                THEN rsmds_c_option-between
                                                ELSE rsmds_c_option-equal )
                               low = <fs_screen_info>-CompanyCodeStart
                               high = COND #( WHEN <fs_screen_info>-CompanyCodeEnd IS NOT INITIAL
                                                THEN <fs_screen_info>-CompanyCodeEnd ) )
        ).

      ENDIF.

      IF ( <Fs_screen_info>-CompanyCodeStart IS INITIAL AND <fs_screen_info>-CompanyCodeEnd IS NOT INITIAL ).

        lr_budat = VALUE #( ( sign = rsmds_c_sign-including
                              option = rsmds_c_option-equal
                              low  = <fs_screen_info>-CompanyCodeEnd
                    ) ).

      ENDIF.


      IF <fs_screen_info>-FiscalYearStart IS NOT INITIAL.

        lr_gjahr = VALUE #( ( sign = rsmds_c_sign-including
                              option = COND #( WHEN <fs_screen_info>-FiscalYearEnd IS NOT INITIAL
                                                THEN rsmds_c_option-between
                                                ELSE rsmds_c_option-equal )
                              low = <fs_screen_info>-fiscalyearstart
                              high =  COND #( WHEN <fs_screen_info>-FiscalYearEnd IS NOT INITIAL
                                                THEN <fs_screen_info>-FiscalYearEnd ) )
        ).

      ENDIF.

      IF ( <Fs_screen_info>-FiscalYearStart IS INITIAL AND <fs_screen_info>-FiscalYearEnd IS NOT INITIAL ).

        lr_budat = VALUE #( ( sign = rsmds_c_sign-including
                              option = rsmds_c_option-equal
                              low  = <fs_screen_info>-FiscalYearEnd
                    ) ).

      ENDIF.

      IF <fs_screen_info>-PostingDateStart IS NOT INITIAL.

        lr_budat = VALUE #( ( sign = rsmds_c_sign-including
                              option = COND #( WHEN <fs_screen_info>-PostingDateEnd IS NOT INITIAL
                                                THEN rsmds_c_option-between
                                                ELSE rsmds_c_option-equal )
                              low  = <fs_screen_info>-PostingDateStart
                              high =  COND #( WHEN <fs_screen_info>-PostingDateEnd IS NOT INITIAL
                                                THEN <fs_screen_info>-PostingDateEnd )

                    ) ).

      ENDIF.

      IF ( <Fs_screen_info>-PostingDateStart IS INITIAL AND <fs_screen_info>-PostingDateEnd IS NOT INITIAL ).

        lr_budat = VALUE #( ( sign = rsmds_c_sign-including
                              option = rsmds_c_option-equal
                              low  = <fs_screen_info>-PostingDateEnd
                    ) ).

      ENDIF.

      "Chama o programa
      SUBMIT zfir_automacao_txt_contab
          WITH s_bukrs IN lr_bukrs
          WITH s_gjahr IN lr_gjahr
          WITH s_budat IN lr_budat
          VIA JOB <fs_screen_info>-JobName
              NUMBER lv_jobcount
          AND RETURN.

      "Inicia JOB
      CALL FUNCTION 'JOB_CLOSE'
        EXPORTING
          jobcount             = lv_jobcount
          jobname              = <fs_screen_info>-JobName
          strtimmed            = abap_true
        EXCEPTIONS
          cant_start_immediate = 1
          invalid_startdate    = 2
          jobname_missing      = 3
          job_close_failed     = 4
          job_nosteps          = 5
          job_notex            = 6
          lock_failed          = 7
          invalid_target       = 8
          OTHERS               = 9.

      IF sy-subrc NE 0.
        RETURN.
      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD executajob.

    DATA:
      lr_bukrs TYPE RANGE OF bukrs,
      lr_gjahr TYPE RANGE OF gjahr,
      lr_budat TYPE RANGE OF budat.

    DATA:
      lv_jobcount TYPE btcjobcnt.

    READ ENTITIES OF zi_fi_autotxt_exec_manual IN LOCAL MODE
        ENTITY Job
            FIELDS ( Jobname
                     CompanyCodeStart
                     CompanyCodeEnd
                     FiscalYearStart
                     FiscalYearEnd
                     PostingDateStart
                     PostingDateEnd
                     ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_screen_info).

    READ TABLE lt_screen_info ASSIGNING FIELD-SYMBOL(<fs_screen_info>) INDEX 1.
    IF sy-subrc IS INITIAL.

      "Criação do job
      CALL FUNCTION 'JOB_OPEN'
        EXPORTING
          jobname          = <fs_screen_info>-JobName
        IMPORTING
          jobcount         = lv_jobcount
        EXCEPTIONS
          cant_create_job  = 1
          invalid_job_data = 2
          jobname_missing  = 3
          OTHERS           = 4.

      IF sy-subrc NE 0.

        reported-job = VALUE #(
          ( %tky = VALUE #( Id = <fs_screen_info>-id )
            %msg        =
              new_message(
                id       = gc_job_erro-id
                number   = gc_job_erro-number
                severity = CONV #( if_xo_const_message=>error ) )
            ) ).

        RETURN.
      ENDIF.

      IF <fs_screen_info>-CompanyCodeStart IS NOT INITIAL.

        lr_bukrs = VALUE  #( ( sign = rsmds_c_sign-including
                               option = COND #( WHEN <fs_screen_info>-CompanyCodeEnd IS NOT INITIAL
                                                THEN rsmds_c_option-between
                                                ELSE rsmds_c_option-equal )
                               low = <fs_screen_info>-CompanyCodeStart
                               high = COND #( WHEN <fs_screen_info>-CompanyCodeEnd IS NOT INITIAL
                                                THEN <fs_screen_info>-CompanyCodeEnd ) )
        ).

      ENDIF.

      IF ( <Fs_screen_info>-CompanyCodeStart IS INITIAL AND <fs_screen_info>-CompanyCodeEnd IS NOT INITIAL ).

        lr_budat = VALUE #( ( sign = rsmds_c_sign-including
                              option = rsmds_c_option-equal
                              low  = <fs_screen_info>-CompanyCodeEnd
                    ) ).

      ENDIF.


      IF <fs_screen_info>-FiscalYearStart IS NOT INITIAL.

        lr_gjahr = VALUE #( ( sign = rsmds_c_sign-including
                              option = COND #( WHEN <fs_screen_info>-FiscalYearEnd IS NOT INITIAL
                                                THEN rsmds_c_option-between
                                                ELSE rsmds_c_option-equal )
                              low = <fs_screen_info>-fiscalyearstart
                              high =  COND #( WHEN <fs_screen_info>-FiscalYearEnd IS NOT INITIAL
                                                THEN <fs_screen_info>-FiscalYearEnd ) )
        ).

      ENDIF.

      IF ( <Fs_screen_info>-FiscalYearStart IS INITIAL AND <fs_screen_info>-FiscalYearEnd IS NOT INITIAL ).

        lr_budat = VALUE #( ( sign = rsmds_c_sign-including
                              option = rsmds_c_option-equal
                              low  = <fs_screen_info>-FiscalYearEnd
                    ) ).

      ENDIF.


      IF <fs_screen_info>-PostingDateStart IS NOT INITIAL.

        lr_budat = VALUE #( ( sign = rsmds_c_sign-including
                              option = COND #( WHEN <fs_screen_info>-PostingDateEnd IS NOT INITIAL
                                                THEN rsmds_c_option-between
                                                ELSE rsmds_c_option-equal )
                              low  = <fs_screen_info>-PostingDateStart
                              high =  COND #( WHEN <fs_screen_info>-PostingDateEnd IS NOT INITIAL
                                                THEN <fs_screen_info>-PostingDateEnd )

                    ) ).

      ENDIF.

      IF ( <Fs_screen_info>-PostingDateStart IS INITIAL AND <fs_screen_info>-PostingDateEnd IS NOT INITIAL ).

        lr_budat = VALUE #( ( sign = rsmds_c_sign-including
                              option = rsmds_c_option-equal
                              low  = <fs_screen_info>-PostingDateEnd
                    ) ).

      ENDIF.

      "Chama o programa
      SUBMIT zfir_automacao_txt_contab
          WITH s_bukrs IN lr_bukrs
          WITH s_gjahr IN lr_gjahr
          WITH s_budat IN lr_budat
          VIA JOB <fs_screen_info>-JobName
              NUMBER lv_jobcount
          AND RETURN.

      "Inicia JOB
      CALL FUNCTION 'JOB_CLOSE'
        EXPORTING
          jobcount             = lv_jobcount
          jobname              = <fs_screen_info>-JobName
          strtimmed            = abap_true
        EXCEPTIONS
          cant_start_immediate = 1
          invalid_startdate    = 2
          jobname_missing      = 3
          job_close_failed     = 4
          job_nosteps          = 5
          job_notex            = 6
          lock_failed          = 7
          invalid_target       = 8
          OTHERS               = 9.

      IF sy-subrc NE 0.
        CLEAR lv_jobcount.
      ENDIF.

    ENDIF.

    reported-job = VALUE #(
      ( %tky = VALUE #( Id = <fs_screen_info>-id )
        %msg        =
          new_message(
            id       = gc_job_concluido-id
            number   = gc_job_concluido-number
            severity = CONV #( if_xo_const_message=>success ) )
        ) ).

  ENDMETHOD.

  METHOD authoritycreate.

    CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_autotxt_exec_manual IN LOCAL MODE
        ENTITY Job
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    DATA lr_bukrs TYPE RANGE OF t001-bukrs.

    lr_bukrs = VALUE #( ( sign = 'I' option = 'BT' low =  lt_data[ 1 ]-CompanyCodeStart high = lt_data[ 1 ]-CompanyCodeEnd ) ).

    SELECT bukrs
    FROM t001
    INTO TABLE @DATA(lt_bukrs)
    WHERE bukrs IN @lr_bukrs.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      LOOP AT lt_bukrs ASSIGNING FIELD-SYMBOL(<fs_bukrs>).

        IF zclfi_auth_zfibukrs=>bukrs_create( <fs_bukrs>-bukrs ) EQ abap_false.

          APPEND VALUE #( %tky        = <fs_data>-%tky
                          %state_area = lc_area )
                TO reported-Job.

          APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-Job.

          APPEND VALUE #( %tky        = <fs_data>-%tky
                          %state_area = lc_area
                          %msg        = NEW zcxca_authority_check(
                                            severity = if_abap_behv_message=>severity-error
                                            textid   = zcxca_authority_check=>gc_range_empresa )
                          %element-CompanyCodeStart  = if_abap_behv=>mk-on )
            TO reported-Job.

          EXIT.

        ENDIF.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
