class ZCL_GHA_GITHUB_PULL_REQUESTS definition
  public
  create public .

public section.

  interfaces ZIF_GHA_GITHUB_PULL_REQUESTS .
protected section.

  methods PARSE_LIST
    importing
      !IV_JSON type STRING
    returning
      value(RT_LIST) type ZIF_GHA_GITHUB_PULL_REQUESTS=>TY_LIST_TT .
private section.
ENDCLASS.



CLASS ZCL_GHA_GITHUB_PULL_REQUESTS IMPLEMENTATION.


  METHOD parse_list.

    DATA(lo_json) = NEW zcl_gha_json_parser( iv_json ).

    LOOP AT lo_json->members( '' ) INTO DATA(lv_member) WHERE NOT table_line IS INITIAL.
      APPEND VALUE #(
        number   = lo_json->value_integer( |/{ lv_member }/number| )
        title    = lo_json->value( |/{ lv_member }/title| )
        state    = lo_json->value( |/{ lv_member }/state| )
        html_url = lo_json->value( |/{ lv_member }/html_url| )
        body     = lo_json->value( |/{ lv_member }/body| )
        base_ref = lo_json->value( |/{ lv_member }/base/ref| )
        base_sha = lo_json->value( |/{ lv_member }/base/sha| )
        head_ref = lo_json->value( |/{ lv_member }/head/ref| )
        head_sha = lo_json->value( |/{ lv_member }/head/sha| )
        ) TO rt_list.
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_gha_github_pull_requests~list.

* todo, add parameters: state + head + base + sort + direction

    DATA(lo_client) = zcl_gha_http_client=>create_by_url(
      |https://api.github.com/repos/{ iv_owner }/{ iv_repo }/pulls| ).

    DATA(li_response) = lo_client->send_receive( ).

    DATA(lv_data) = li_response->get_cdata( ).

    DATA: lt_fields TYPE tihttpnvp.
    li_response->get_header_fields( CHANGING fields = lt_fields ).

    li_response->get_status( IMPORTING code = DATA(lv_code) reason = DATA(lv_reason) ).
    IF lv_code <> 200.
      BREAK-POINT.
    ENDIF.

* todo, handle rate limit error
* todo, pagination?

    rt_list = parse_list( lv_data ).

  ENDMETHOD.
ENDCLASS.
