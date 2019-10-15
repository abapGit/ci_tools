CLASS zcl_gha_gitlab_merge_requests DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_gha_gitlab_merge_requests .
  PROTECTED SECTION.

    METHODS parse_list
      IMPORTING
        !iv_json       TYPE string
      RETURNING
        VALUE(rt_list) TYPE zif_gha_gitlab_merge_requests=>ty_list_tt .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GHA_GITLAB_MERGE_REQUESTS IMPLEMENTATION.


  METHOD parse_list.

    DATA(lo_json) = NEW zcl_gha_json_parser( iv_json ).

    LOOP AT lo_json->members( '' ) INTO DATA(lv_member) WHERE NOT table_line IS INITIAL.
      APPEND VALUE #(
        id            = lo_json->value_integer( |/{ lv_member }/id| )
        iid           = lo_json->value_integer( |/{ lv_member }/iid| )
        project_id    = lo_json->value_integer( |/{ lv_member }/project_id| )
        title         = lo_json->value( |/{ lv_member }/title| )
        description   = lo_json->value( |/{ lv_member }/description| )
        state         = lo_json->value( |/{ lv_member }/state| )
        sha           = lo_json->value( |/{ lv_member }/sha| )
        target_branch = lo_json->value( |/{ lv_member }/target_branch| )
        source_branch = lo_json->value( |/{ lv_member }/source_branch| )
        ) TO rt_list.
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_gha_gitlab_merge_requests~list.

    IF NOT iv_state IS INITIAL.
      DATA(lv_query) = |?state={ iv_state }|.
    ENDIF.

    DATA(lo_client) = zcl_gha_http_client=>create_by_url(
      |https://gitlab.com/api/v4/projects/{ iv_project_id }/merge_requests{ lv_query }| ).

    DATA(li_response) = lo_client->send_receive( ).

    DATA(lv_data) = li_response->get_cdata( ).

    li_response->get_status( IMPORTING code = DATA(lv_code) reason = DATA(lv_reason) ).
    ASSERT lv_code = 200. "  todo

    rt_list = parse_list( lv_data ).

  ENDMETHOD.
ENDCLASS.
