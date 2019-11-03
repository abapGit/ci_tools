CLASS zcl_gha_github_check_suites DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_gha_github_check_suites .

    METHODS constructor
      IMPORTING
        !iv_owner TYPE string
        !iv_repo  TYPE string .
  PROTECTED SECTION.

    DATA mv_owner TYPE string .
    DATA mv_repo TYPE string .

    METHODS parse_list
      IMPORTING
        !iv_json       TYPE string
      RETURNING
        VALUE(rt_list) TYPE zif_gha_github_check_suites=>ty_suites .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GHA_GITHUB_CHECK_SUITES IMPLEMENTATION.


  METHOD constructor.

    mv_owner = iv_owner.
    mv_repo = iv_repo.

  ENDMETHOD.


  METHOD parse_list.

    DATA(lo_json) = NEW zcl_gha_json_parser( iv_json ).

    LOOP AT lo_json->members( '/check_suites' ) INTO DATA(lv_member) WHERE NOT table_line IS INITIAL.
      APPEND VALUE #(
        id         = lo_json->value_integer( |/check_suites/{ lv_member }/id| )
        status     = lo_json->value( |/check_suites/{ lv_member }/status| )
        conclusion = lo_json->value( |/check_suites/{ lv_member }/conclusion| )
        ) TO rt_list.
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_gha_github_check_suites~list.

* todo, add input parameter "since"

    DATA(lo_client) = zcl_gha_http_client=>create_by_url(
      |https://api.github.com/repos/{ mv_owner }/{ mv_repo }/commits/{ iv_ref }/check-suites| ).

    lo_client->set_header_field(
      iv_name  = 'Accept'
      iv_value = 'application/vnd.github.antiope-preview+json' ).

    DATA(li_response) = lo_client->send_receive( ).

    DATA(lv_data) = li_response->get_cdata( ).

    li_response->get_status( IMPORTING code = DATA(lv_code) reason = DATA(lv_reason) ).
    ASSERT lv_code = 200. "  todo

* todo, handle rate limit error
* todo, pagination?

    rt_list = parse_list( lv_data ).

  ENDMETHOD.
ENDCLASS.
