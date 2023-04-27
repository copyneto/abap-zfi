FUNCTION zfmfi_wf_docpagar_app.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(I_CHGTYPE)
*"     REFERENCE(I_ORIGIN) LIKE  RSDSWHERE-LINE
*"     REFERENCE(I_TABNAME) LIKE  DNTAB-TABNAME
*"     REFERENCE(I_STRUCTURE) OPTIONAL
*"     REFERENCE(I_WHERE_BUKRS) LIKE  BSEG-BUKRS DEFAULT SPACE
*"     REFERENCE(I_WHERE_KUNNR) LIKE  BSEG-KUNNR DEFAULT ' '
*"     REFERENCE(I_WHERE_LIFNR) LIKE  BSEG-LIFNR DEFAULT ' '
*"     REFERENCE(I_WHERE_UMSKS) LIKE  BSEG-UMSKS DEFAULT ' '
*"     REFERENCE(I_WHERE_UMSKZ) LIKE  BSEG-UMSKZ DEFAULT ' '
*"     REFERENCE(I_WHERE_AUGDT) LIKE  BSEG-AUGDT DEFAULT '10000101'
*"     REFERENCE(I_WHERE_AUGBL) LIKE  BSEG-AUGBL DEFAULT ' '
*"     REFERENCE(I_WHERE_ZUONR) LIKE  BSEG-ZUONR DEFAULT ' '
*"     REFERENCE(I_WHERE_GJAHR) LIKE  BSEG-GJAHR DEFAULT 0000
*"     REFERENCE(I_WHERE_BELNR) LIKE  BSEG-BELNR DEFAULT ' '
*"     REFERENCE(I_WHERE_BUZEI) LIKE  BSEG-BUZEI DEFAULT 000
*"  TABLES
*"      T_STRUCTURE OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  DATA ls_ibsik TYPE bsik.

  IF sy-tcode NE 'FB08'.

    LOOP AT t_structure ASSIGNING FIELD-SYMBOL(<fs_structure>).

      TRY.

          MOVE-CORRESPONDING <fs_structure> TO ls_ibsik .

          SELECT SINGLE *
                   FROM ztfi_wf_log
                   INTO @DATA(lt_log)
                  WHERE empresa   EQ @ls_ibsik-bukrs
                    AND documento EQ @ls_ibsik-belnr
                    AND exercicio EQ @ls_ibsik-gjahr
                    AND item      EQ @ls_ibsik-buzei.

          IF sy-subrc NE 0.

            CALL FUNCTION 'ZFMFI_WF_DOCPAGAR_APP_UPD' IN UPDATE TASK
              EXPORTING
                iv_belnr = ls_ibsik-belnr
                iv_bukrs = ls_ibsik-bukrs
                iv_gjahr = ls_ibsik-gjahr
                iv_buzei = ls_ibsik-buzei.

          ENDIF.

        CATCH cx_sy_conversion_error INTO DATA(lo_conversion_error).

      ENDTRY.

    ENDLOOP.

  ENDIF.

ENDFUNCTION.
