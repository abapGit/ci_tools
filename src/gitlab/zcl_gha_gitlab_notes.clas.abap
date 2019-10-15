class ZCL_GHA_GITLAB_NOTES definition
  public
  create protected

  global friends ZCL_GHA_GITLAB_FACTORY .

public section.

  interfaces ZIF_GHA_GITLAB_NOTES .

  methods CONSTRUCTOR
    importing
      !IV_PROJECT_ID type I .
protected section.

  data MV_PROJECT_ID type I .

  methods PARSE
    importing
      !IV_JSON type STRING
    returning
      value(RT_LIST) type ZIF_GHA_GITLAB_NOTES=>TY_LIST_TT .
private section.
ENDCLASS.



CLASS ZCL_GHA_GITLAB_NOTES IMPLEMENTATION.


  METHOD constructor.

    mv_project_id = iv_project_id.

  ENDMETHOD.


  METHOD parse.

    DATA(lo_json) = NEW zcl_gha_json_parser( iv_json ).

    LOOP AT lo_json->members( '' ) INTO DATA(lv_member) WHERE NOT table_line IS INITIAL.
      APPEND VALUE #(
        id   = lo_json->value_integer( |/{ lv_member }/id| )
        body = lo_json->value( |/{ lv_member }/body| )
        ) TO rt_list.
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_gha_gitlab_notes~create_merge_request.

* todo

  ENDMETHOD.


  METHOD zif_gha_gitlab_notes~list_merge_request.

    DATA(lo_client) = zcl_gha_http_client=>create_by_url(
      |https://gitlab.com/api/v4/projects/{ mv_project_id }/merge_requests/{ iv_merge_request_iid }/notes| ).

    DATA(li_response) = lo_client->send_receive( ).

    DATA(lv_data) = li_response->get_cdata( ).

    li_response->get_status( IMPORTING code = DATA(lv_code) reason = DATA(lv_reason) ).
    ASSERT lv_code = 200. "  todo

    rt_list = parse( lv_data ).

  ENDMETHOD.
ENDCLASS.
