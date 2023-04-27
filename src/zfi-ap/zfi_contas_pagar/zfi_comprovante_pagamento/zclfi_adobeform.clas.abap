"!<p><h2>Impressão e geração de PDF de formulários Adobe</h2></p>
"!<p><strong>Autor:</strong>Marcos Roberto de Souza</p>
"!<p><strong>Data:</strong>8 de set de 2021</p>
CLASS zclfi_adobeform DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      "! Tipo de dados de entrada em formulários Adobe.<p>O campo "parâmetro" deve conter o nome do parâmetro na interface do Adobe.</p><p>O campo "valor" é a referência para a estrutura a ser passada ao AdobeForm</p>
      BEGIN OF ty_params,
        parametro TYPE rs38l_par_,
        valor     TYPE REF TO data,
      END OF ty_params.

    CONSTANTS:
       "!Classe de mensagens utilizada para a geração dos erros através da classe ZCXFI_ADOBE_ERROR
       gc_error_class TYPE symsgid VALUE 'ZFI_COMPR_PAGTOS'.

    METHODS:
      "! Realiza a instância da classe representando o form a ser gerado
      "! @parameter iv_formname | Nome do AdobeForm
      "! @raising zcxfi_adobe_error | Erro caso o form não exista no ambiente
      constructor IMPORTING iv_formname TYPE fpname
                  RAISING   zcxfi_adobe_error,

      "! Recebe os parâmetros do form, utilizando a estrutura do tipo TY_PARAMS
      "! @parameter is_data | Dados a serem considerados na interface Adobe
      "! @raising zcxfi_adobe_error | Erro, caso o parâmetro informado não exista na interface do form
      setup_data IMPORTING is_data TYPE ty_params
                 RAISING   zcxfi_adobe_error,

      "! Altera o device padrão (LP01), caso seja necessário utilizar uma impressora diferente
      "! @parameter iv_device | Nome do device a ser utilizado
      set_device IMPORTING iv_device TYPE rspopname,

      "! Configurar parâmetros para exibição de diálogo de impressão
      "! @parameter iv_print_dialog | <ul><li>ABAP_TRUE - Diálogo Exibido</li><li>ABAP_FALSE - Diálogo suprimido</li></ul>
      show_dialog IMPORTING iv_print_dialog TYPE abap_bool DEFAULT abap_false,

      "! Realiza a impressão do PDF no device indicado (default LP01)
      "! @parameter iv_close_job | Deve ser utilizado caso o job de impressão não possa ser fechado. Ex.: Para realizar várias impressões dentro do mesmo spool.
      "! @raising zcxfi_adobe_error | Erro na situação de haver algum erro durante a impressão
      print      IMPORTING iv_close_job TYPE abap_bool DEFAULT abap_true
                 RAISING   zcxfi_adobe_error,

      "! Obtem o PDF do form no formato binário (XSTRING) para download ou envio por e-mail.
      "! @parameter ev_pdf | PDF gerado e convertido para binário
      "! @parameter et_pdf | PDF gerado e convertido para tabela binária
      "! @raising zcxfi_adobe_error | Erro caso não seja possível gerar o PDF
      get_pdf    EXPORTING ev_pdf TYPE xstring
                           et_pdf TYPE solix_tab
                 RAISING   zcxfi_adobe_error,

      "! Encerrar o job de impressão. É necessário ao final da última impressão caso o método "print" tenha sido chamado com o parâmetro <em>IV_CLOSE_JOB</em> = abap_false
      "! @raising zcxfi_adobe_error | Erro se ocorrer problemas ao encerrar o job de impressão.
      close_job  RAISING zcxfi_adobe_error.

  PROTECTED SECTION.

  PRIVATE SECTION.
    CLASS-DATA:
      "! Flag para definir se o job de impressão está aberto
      gv_job_aberto TYPE abap_bool VALUE abap_false.

    DATA:
      "! Nome interno da função gerada pelo AdobeForm
      gv_internal_name   TYPE funcname,
      "! Estrutura com a definição de interface do form
      gs_interface       TYPE rsfbintfv,
      "! Tabela para chamada dinâmica de funções. Utilizada para passar parâmetros ao form
      gt_param_table     TYPE abap_func_parmbind_tab,
      "! Tabela de exceções do form. Passagem obrigatória na chamda dinâmica de funções
      gt_exception_table TYPE abap_func_excpbind_tab,
      "! Estrutura com parâmetros de impressão do form.
      gs_outputparams    TYPE sfpoutputparams.

    METHODS:

      "! Criar um job de impressão
      "! @raising zcxfi_adobe_error | Erro se ocorrer algum problema durante a abertura do job ou haja parâmetros inválidos
      open_job RAISING zcxfi_adobe_error,

      "! Inicializar a estrutura GS_OUTPUTPARAMS com valores default
      set_default_outputparams,

      "! Realizar a geração do form
      "! @parameter ev_pdf | Parâmetro com o PDF gerado no formato binário
      "! @raising zcxfi_adobe_error | Erro na geração do form
      call_form EXPORTING ev_pdf TYPE xstring
                RAISING   zcxfi_adobe_error.
ENDCLASS.



CLASS ZCLFI_ADOBEFORM IMPLEMENTATION.


  METHOD constructor.

    "Obter a função interna do FORM
    TRY.
        CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
          EXPORTING
            i_name     = iv_formname
          IMPORTING
            e_funcname = gv_internal_name.

      CATCH cx_fp_api_repository cx_fp_api_usage cx_fp_api_internal.
        RAISE EXCEPTION TYPE zcxfi_adobe_error
          EXPORTING
            is_textid = VALUE scx_t100key( msgid = gc_error_class
                                           msgno = '000'
                                           attr1 = iv_formname ). "Adobe Form &1 não encontrado ou inválido
    ENDTRY.

    "Definir valores default de impressão
    me->set_default_outputparams( ).
  ENDMETHOD.


  METHOD setup_data.
    FREE: gs_interface, gt_param_table.
    IF gs_interface IS INITIAL.
      "Obter os dados da interface
      cl_fb_function_utility=>meth_get_interface(
        EXPORTING
          im_name             = CONV #( gv_internal_name )
        IMPORTING
          ex_interface        = gs_interface
        EXCEPTIONS
          error_occured       = 1
          object_not_existing = 2
          OTHERS              = 3 ).

      "Montar dados da exception-table
      gt_exception_table = VALUE #( FOR ls_exception IN gs_interface-except ( name = ls_exception-parameter value = lines( gt_exception_table ) + 1 ) ).

      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcxfi_adobe_error
          EXPORTING
            is_textid = VALUE scx_t100key( msgid = gc_error_class msgno = '001' ). "Não existe interface definida para este form.
      ENDIF.
    ENDIF.

    "Verificar se o parâmetro existe na interface
    IF NOT line_exists( gs_interface-import[ parameter = is_data-parametro ] ). "#EC CI_STDSEQ
      RAISE EXCEPTION TYPE zcxfi_adobe_error
        EXPORTING
          is_textid = VALUE scx_t100key( msgid = gc_error_class msgno = '002' attr1 = is_data-parametro ). "Parâmetro &1 não existe na interface deste form
    ENDIF.

    "Verificar o tipo de parâmetro do form com a entrada
    DATA(lo_type) = cl_abap_typedescr=>describe_by_data_ref( is_data-valor ).
    DATA(ls_if_field) = gs_interface-import[ parameter = is_data-parametro ]. "#EC CI_STDSEQ

    IF lo_type->get_relative_name( ) = ls_if_field-structure.
      "Preparar parâmetro de entrada
      TRY.
          DATA(ls_param) = VALUE abap_func_parmbind( name  = is_data-parametro
                                                     kind  = abap_func_exporting
                                                     value = is_data-valor ).
          INSERT ls_param INTO TABLE gt_param_table.

        CATCH cx_sy_itab_duplicate_key.
          RAISE EXCEPTION TYPE zcxfi_adobe_error
            EXPORTING
              is_textid = VALUE scx_t100key( msgid = gc_error_class
                                             msgno = '004'
                                             attr1 = is_data-parametro ). "Parâmetro &1 já informado anteriormente
      ENDTRY.

    ELSE.
      RAISE EXCEPTION TYPE zcxfi_adobe_error
        EXPORTING
          is_textid = VALUE scx_t100key( msgid = gc_error_class
                                         msgno = '003'
                                         attr1 = is_data-parametro
                                         attr2 = lo_type->get_relative_name( )
                                         attr3 = ls_if_field-structure ). "Parâmetro &1 (tipo &2) difere do tipo da interface &3
    ENDIF.
  ENDMETHOD.


  METHOD get_pdf.

    IF gv_job_aberto = abap_false.
      gs_outputparams-getpdf = abap_true.
      me->open_job( ).
    ENDIF.

    "chamar form para obtenção de pdf
    me->call_form( IMPORTING ev_pdf = ev_pdf ).

    me->close_job( ).

    IF et_pdf IS SUPPLIED.
      et_pdf = cl_bcs_convert=>xstring_to_solix( iv_xstring = ev_pdf ).
    ENDIF.
  ENDMETHOD.


  METHOD print.

    IF gv_job_aberto = abap_false.
      gs_outputparams-getpdf = abap_false.
      me->open_job( ).
    ENDIF.

    "Setar parâmetros de impressão
    me->call_form( ).

    IF iv_close_job = abap_true.
      me->close_job( ).
    ENDIF.
  ENDMETHOD.


  METHOD open_job.

    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = gs_outputparams
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.
    IF sy-subrc = 0.
      gv_job_aberto = abap_true.

    ELSE.
      RAISE EXCEPTION TYPE zcxfi_adobe_error
        EXPORTING
          is_textid = VALUE scx_t100key( msgid = gc_error_class
                                         msgno = '005'
                                         attr1 = COND #( WHEN sy-subrc = 1 THEN 'CANCEL'
                                                         WHEN sy-subrc = 2 THEN 'USAGE_ERROR'
                                                         WHEN sy-subrc = 3 THEN 'SYSTEM_ERROR'
                                                         WHEN sy-subrc = 4 THEN 'INTERNAL_ERROR'
                                                         WHEN sy-subrc = 5 THEN 'OTHERS' ) ). "Parâmetros do job de impressão inválidos. (&1)
    ENDIF.
  ENDMETHOD.


  METHOD close_job.

    IF gv_job_aberto = abap_true.
      CALL FUNCTION 'FP_JOB_CLOSE'
        EXCEPTIONS
          usage_error    = 1
          system_error   = 2
          internal_error = 3
          OTHERS         = 4.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcxfi_adobe_error
          EXPORTING
            is_textid = VALUE scx_t100key( msgid = gc_error_class
                                           msgno = '007' ). "Erro na impressão do form
      ENDIF.
    ENDIF.

    gv_job_aberto = abap_false.
  ENDMETHOD.


  METHOD set_default_outputparams.

    gs_outputparams-nopdf     = abap_false. "Controle de spool
    gs_outputparams-nopreview = abap_true.
    gs_outputparams-nodialog  = abap_true.
    gs_outputparams-reqnew    = abap_true.
    gs_outputparams-reqimm    = abap_true.
    gs_outputparams-dest      = 'LP01'.
    gs_outputparams-device    = 'PRINTER'.
  ENDMETHOD.


  METHOD call_form.

    DATA ls_adobe_return TYPE fpformoutput.

    IF NOT line_exists( gt_param_table[ name = '/1BCDWB/FORMOUTPUT' ] ). "#EC CI_SORTSEQ
      gt_param_table = VALUE #( BASE gt_param_table ( name  = '/1BCDWB/FORMOUTPUT'
                                                      kind  = abap_func_importing
                                                      value =  REF #( ls_adobe_return ) ) ).
    ENDIF.

    TRY.
        CALL FUNCTION gv_internal_name
          PARAMETER-TABLE gt_param_table
          EXCEPTION-TABLE gt_exception_table.

        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcxfi_adobe_error
            EXPORTING
              is_textid = VALUE scx_t100key( msgid = gc_error_class
                                             msgno = '008'
                                             attr1 = gt_exception_table[ value = sy-subrc ]-name ). "#EC CI_HASHSEQ "Erro na chamada do Form (&1)
        ENDIF.

      CATCH cx_sy_dyn_call_param_missing INTO DATA(lo_error).
        RAISE EXCEPTION TYPE zcxfi_adobe_error
          EXPORTING
            is_textid = VALUE scx_t100key( msgid = gc_error_class
                                           msgno = '006'
                                           attr1 = lo_error->parameter ). "Parâmetro obrigatório do form não definido: &1
    ENDTRY.

    IF ev_pdf IS SUPPLIED.
      ev_pdf = ls_adobe_return-pdf.
    ENDIF.
  ENDMETHOD.


  METHOD set_device.

    gs_outputparams-dest = iv_device.
  ENDMETHOD.


  METHOD show_dialog.

*    gs_outputparams-nopreview = abap_false.
    gs_outputparams-nodialog  = abap_false.
  ENDMETHOD.
ENDCLASS.
