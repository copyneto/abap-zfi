class ZCLFI_SUBMIT_JOB definition
  public
  final
  create public .

public section.

  types:
    ty_buks  TYPE RANGE OF bukrs .
  types:
    ty_gjahr TYPE RANGE OF gjahr .
  types:
    ty_budat TYPE RANGE OF budat .

  methods EXECUTE
    importing
      !IV_JOBNAME type BTCJOB
      !IV_JOBCOUNT type BTCJOBCNT
      !IR_BUKRS type TY_BUKS
      !IR_GJAHR type TY_GJAHR
      !IR_BUDAT type TY_BUDAT .
protected section.
private section.
ENDCLASS.



CLASS ZCLFI_SUBMIT_JOB IMPLEMENTATION.


  METHOD execute.

    "Chama o programa
    SUBMIT zfir_automacao_txt_contab
        WITH s_bukrs IN ir_bukrs
        WITH s_gjahr IN ir_gjahr
        WITH s_budat IN ir_budat
        VIA JOB iv_jobname
            NUMBER iv_jobcount
        AND RETURN.

    "Inicia JOB
    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobcount             = iv_jobcount
        jobname              = iv_jobname
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

  ENDMETHOD.
ENDCLASS.
