CLASS zcl_gha_gitlab_merge_requests DEFINITION
  PUBLIC
  CREATE PROTECTED
  GLOBAL FRIENDS zcl_gha_gitlab_factory .

  PUBLIC SECTION.

    INTERFACES zif_gha_gitlab_merge_requests .
  PROTECTED SECTION.

    METHODS parse_pipelines_list
      IMPORTING
        !iv_json       TYPE string
      RETURNING
        VALUE(rt_list) TYPE zif_gha_gitlab_merge_requests=>ty_pipeline_list .
    METHODS parse_list
      IMPORTING
        !iv_json       TYPE string
      RETURNING
        VALUE(rt_list) TYPE zif_gha_gitlab_merge_requests=>ty_merge_request_list .
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
        work_in_progress = lo_json->value( |/{ lv_member }/work_in_progress| )
        ) TO rt_list.
    ENDLOOP.

  ENDMETHOD.


  METHOD parse_pipelines_list.

    DATA(lo_json) = NEW zcl_gha_json_parser( iv_json ).

    LOOP AT lo_json->members( '' ) INTO DATA(lv_member) WHERE NOT table_line IS INITIAL.
      APPEND VALUE #(
        id     = lo_json->value_integer( |/{ lv_member }/id| )
        sha    = lo_json->value( |/{ lv_member }/sha| )
        ref    = lo_json->value( |/{ lv_member }/ref| )
        status = lo_json->value( |/{ lv_member }/status| )
        ) TO rt_list.
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_gha_gitlab_merge_requests~list.

* todo: move IV_PROJECT_ID to constructor?

    IF NOT iv_state IS INITIAL.
* todo, provide constants?
      ASSERT iv_state = 'opened' OR iv_state = 'closed' OR iv_state = 'locked' OR iv_state = 'merged'.
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


  METHOD zif_gha_gitlab_merge_requests~list_pipelines.

    DATA(lo_client) = zcl_gha_http_client=>create_by_url(
      |https://gitlab.com/api/v4/projects/{ iv_project_id }/merge_requests/{ iv_merge_request_iid }/pipelines| ).

    DATA(li_response) = lo_client->send_receive( ).

    DATA(lv_data) = li_response->get_cdata( ).

    li_response->get_status( IMPORTING code = DATA(lv_code) reason = DATA(lv_reason) ).
    ASSERT lv_code = 200. "  todo

    rt_list = parse_pipelines_list( lv_data ).

  ENDMETHOD.
ENDCLASS.
