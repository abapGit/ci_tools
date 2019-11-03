CLASS zcl_gha_gitlab_projects DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_gha_gitlab_projects .
  PROTECTED SECTION.

    METHODS parse
      IMPORTING
        !iv_json       TYPE string
      RETURNING
        VALUE(rt_list) TYPE zif_gha_gitlab_projects=>ty_projects .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GHA_GITLAB_PROJECTS IMPLEMENTATION.


  METHOD parse.

    DATA(lo_json) = NEW zcl_gha_json_parser( iv_json ).

    LOOP AT lo_json->members( '' ) INTO DATA(lv_member) WHERE NOT table_line IS INITIAL.
      APPEND VALUE #(
        id                  = lo_json->value_integer( |/{ lv_member }/id| )
        description         = lo_json->value( |/{ lv_member }/description| )
        name                = lo_json->value( |/{ lv_member }/name| )
        path_with_namespace = lo_json->value( |/{ lv_member }/path_with_namespace| )
        default_branch      = lo_json->value( |/{ lv_member }/default_branch| )
        http_url_to_repo    = lo_json->value( |/{ lv_member }/http_url_to_repo| )
        web_url             = lo_json->value( |/{ lv_member }/web_url| )
        visibility          = lo_json->value( |/{ lv_member }/visibility| )
        ) TO rt_list.
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_gha_gitlab_projects~list_by_user.

    DATA(lo_client) = zcl_gha_http_client=>create_by_url(
      |https://gitlab.com/api/v4/users/{ iv_user }/projects| ).

    DATA(li_response) = lo_client->send_receive( ).

    DATA(lv_data) = li_response->get_cdata( ).

    li_response->get_status( IMPORTING code = DATA(lv_code) reason = DATA(lv_reason) ).
    ASSERT lv_code = 200. "  todo

    rt_projects = parse( lv_data ).

  ENDMETHOD.
ENDCLASS.
