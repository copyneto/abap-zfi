"!<p>Classe de exceção para a interface com o sistema RM</p>
"!<p><strong>Autor:</strong> Rodrigo Felix Farias</p>
"!<p><strong>Data:</strong> 24 de Jan de 2022</p>
CLASS zcxfi_erro_interface DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .

    "! @parameter textid |Erro apontado pela exceção
    "! @parameter previous |Erro anterior (utilizado para a propagação de erros)
    METHODS constructor
      IMPORTING
        !textid   LIKE if_t100_message=>t100key OPTIONAL
        !previous LIKE previous OPTIONAL .
  PRIVATE SECTION.
ENDCLASS.

CLASS zcxfi_erro_interface IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
