*&---------------------------------------------------------------------*
*& Include          ZXDTAU01
*&---------------------------------------------------------------------*

*---------------------------------------------------------------------------------
* Types
*---------------------------------------------------------------------------------
TYPES: BEGIN OF ty_arq240,
         campo(240),
       END OF ty_arq240,
       " Estrutura para receber o arquivo bancário
       BEGIN OF ty_arq500,
         campo(500),
       END OF ty_arq500.

*-----------------------------------------------------------------------
* Tabelas Internas
*-----------------------------------------------------------------------
DATA: gt_arq240 TYPE TABLE OF ty_arq240, " Tabela para receber o arquivo bancário
      gt_arq500 TYPE TABLE OF ty_arq500. " Tabela para receber o arquivo bancário
*-----------------------------------------------------------------------
* Work Areas
*-----------------------------------------------------------------------
DATA: gs_arq240 TYPE ty_arq240,
      gs_arq500 TYPE ty_arq500.

*-----------------------------------------------------------------------
*Variáveis
*-----------------------------------------------------------------------
DATA: gv_file TYPE string,
      gv_code TYPE i.

*-----------------------------------------------------------------------
* Lógica Principal
*-----------------------------------------------------------------------
CLEAR : gv_file.

" Nome do arquivo que foi gerado
gv_file = t_regut-dwnam.

" Busca o arquivo gerado na máquina do usuário
CALL METHOD cl_gui_frontend_services=>gui_upload
  EXPORTING
    filename                = gv_file
    filetype                = 'ASC'
  CHANGING
    data_tab                = gt_arq500
  EXCEPTIONS
    file_open_error         = 1
    file_read_error         = 2
    no_batch                = 3
    gui_refuse_filetransfer = 4
    invalid_type            = 5
    no_authority            = 6
    unknown_error           = 7
    bad_data_format         = 8
    header_not_allowed      = 9
    separator_not_allowed   = 10
    header_too_long         = 11
    unknown_dp_error        = 12
    access_denied           = 13
    dp_out_of_memory        = 14
    disk_full               = 15
    dp_timeout              = 16
    not_supported_by_gui    = 17
    error_no_gui            = 18
    OTHERS                  = 19.

* Verificar o tipo do arquivo bancario
READ TABLE gt_arq500 INTO gs_arq500 INDEX 1.


CASE gs_arq500(3) .

  WHEN '237'.

    " Busca o arquivo gerado na máquina do usuário
    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename                = gv_file
        filetype                = 'ASC'
      CHANGING
        data_tab                = gt_arq240
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        not_supported_by_gui    = 17
        error_no_gui            = 18
        OTHERS                  = 19.

    DATA(lv_lines) = lines( gt_arq240 ).

    READ TABLE gt_arq240 ASSIGNING FIELD-SYMBOL(<fs_lastline>) INDEX lv_lines.
    IF sy-subrc = 0.


      cl_gui_frontend_services=>file_delete(
     EXPORTING
       filename             = gv_file
           CHANGING
       rc                   = gv_code
     EXCEPTIONS
       file_delete_failed   = 1                " Could not delete file
       cntl_error           = 2                " Control error
       error_no_gui         = 3                " Error: No GUI
       file_not_found       = 4                " File not found
       access_denied        = 5                " Access denied
       unknown_error        = 6                " Unknown error
       not_supported_by_gui = 7                " GUI does not support this
       wrong_parameter      = 8                " Wrong parameter
       OTHERS               = 9
   ).

      IF sy-subrc = 0.


        CALL METHOD cl_gui_frontend_services=>gui_download
          EXPORTING
            filename                  = gv_file
            filetype                  = 'ASC'
            trunc_trailing_blanks_eol = abap_false
            write_lf_after_last_line  = abap_false
          CHANGING
            data_tab                  = gt_arq240
          EXCEPTIONS
            file_write_error          = 1
            no_batch                  = 2
            gui_refuse_filetransfer   = 3
            invalid_type              = 4
            no_authority              = 5
            unknown_error             = 6
            header_not_allowed        = 7
            separator_not_allowed     = 8
            filesize_not_allowed      = 9
            header_too_long           = 10
            dp_error_create           = 11
            dp_error_send             = 12
            dp_error_write            = 13
            unknown_dp_error          = 14
            access_denied             = 15
            dp_out_of_memory          = 16
            disk_full                 = 17
            dp_timeout                = 18
            file_not_found            = 19
            dataprovider_exception    = 20
            control_flush_error       = 21
            not_supported_by_gui      = 22
            error_no_gui              = 23
            OTHERS                    = 24.

      ENDIF.

    ENDIF.


ENDCASE.
