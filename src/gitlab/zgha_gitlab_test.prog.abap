REPORT zgha_gitlab_test.

PARAMETERS: p_token TYPE text100 OBLIGATORY,
            p_plis  TYPE c RADIOBUTTON GROUP g1,
            p_nlmr  TYPE c RADIOBUTTON GROUP g1.

START-OF-SELECTION.
  PERFORM run.

FORM run.

  zcl_gha_http_client=>add_header(
    iv_name = 'PRIVATE-TOKEN'
    iv_value = |{ p_token }| ).

******************

  CASE abap_true.
    WHEN p_plis.
      DATA(lt_plist) = zcl_gha_gitlab_factory=>get_merge_requests( )->list(
        iv_project_id = 2248898
        iv_state      = 'opened' ).
    WHEN p_nlmr.
      DATA(lt_nlist) = zcl_gha_gitlab_factory=>get_notes( 2248898 )->list_merge_request( 1 ).
      BREAK-POINT.
  ENDCASE.

ENDFORM.
