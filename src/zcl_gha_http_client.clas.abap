CLASS zcl_gha_http_client DEFINITION
  PUBLIC
  CREATE PROTECTED .

  PUBLIC SECTION.

    CLASS-METHODS add_header
      IMPORTING
        !iv_name  TYPE string
        !iv_value TYPE string .
    CLASS-METHODS create_by_url
      IMPORTING
        !iv_url          TYPE string
      RETURNING
        VALUE(ro_client) TYPE REF TO zcl_gha_http_client .
    METHODS send_receive
      RETURNING
        VALUE(ri_response) TYPE REF TO if_http_response .
    METHODS set_cdata
      IMPORTING
        !iv_data TYPE string .
    METHODS set_header_field
      IMPORTING
        !iv_name  TYPE string
        !iv_value TYPE string .
    METHODS set_method
      IMPORTING
        !iv_method TYPE string .
  PROTECTED SECTION.

    DATA mi_client TYPE REF TO if_http_client .
    CLASS-DATA mv_name TYPE string .
    CLASS-DATA mv_value TYPE string .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GHA_HTTP_CLIENT IMPLEMENTATION.


  METHOD add_header.

* todo, add to private table intead
    mv_name = iv_name.
    mv_value = iv_value.

  ENDMETHOD.


  METHOD create_by_url.

    ro_client = NEW #( ).

    cl_http_client=>create_by_url(
      EXPORTING
        url                = iv_url
        ssl_id             = 'ANONYM' " todo, make it configurable
*        proxy_host         = todo
*        proxy_service      = todo
      IMPORTING
        client             = ro_client->mi_client
      EXCEPTIONS
        argument_not_found = 1
        plugin_not_active  = 2
        internal_error     = 3
        OTHERS             = 4 ).
    ASSERT sy-subrc = 0. " todo

    ro_client->mi_client->propertytype_logon_popup = if_http_client=>co_disabled.

    IF NOT mv_name IS INITIAL.
      ro_client->set_header_field(
        iv_name  = mv_name
        iv_value = mv_value ).
    ENDIF.

  ENDMETHOD.


  METHOD send_receive.

    mi_client->send( ).

    mi_client->receive(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        OTHERS                     = 4 ).

    IF sy-subrc <> 0.
      mi_client->get_last_error(
        IMPORTING
          code    = DATA(lv_code)
          message = DATA(lv_message) ).

* todo, raise exception
      ASSERT 0 = 1.
    ENDIF.

    ri_response = mi_client->response.

  ENDMETHOD.


  METHOD set_cdata.

    mi_client->request->set_cdata( iv_data ).

  ENDMETHOD.


  METHOD set_header_field.

    mi_client->request->set_header_field(
      name  = iv_name
      value = iv_value ).

  ENDMETHOD.


  METHOD set_method.

    mi_client->request->set_header_field(
        name  = '~request_method'
        value = to_upper( iv_method ) ).

  ENDMETHOD.
ENDCLASS.
