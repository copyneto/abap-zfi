"!<p><h2>Classe de exceções para a geração de documento Adobe</h2></p>
"!<p><strong>Autor:</strong>Marcos Roberto de Souza</p>
"!<p><strong>Data:</strong>8 de set de 2021</p>
CLASS zcxfi_adobe_error DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .

    METHODS constructor
      IMPORTING
        is_textid   LIKE if_t100_message=>t100key OPTIONAL
        is_previous LIKE previous OPTIONAL .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcxfi_adobe_error IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = is_previous.
    CLEAR me->textid.
    IF is_textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = is_textid.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
