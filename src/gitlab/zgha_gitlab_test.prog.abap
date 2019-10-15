REPORT zgha_gitlab_test.

PARAMETERS: p_token TYPE text100 OBLIGATORY,
            p_plis  TYPE c RADIOBUTTON GROUP g1,
            p_pcre  TYPE c RADIOBUTTON GROUP g1.

START-OF-SELECTION.
  PERFORM run.

FORM run.

  zcl_gha_http_client=>add_header(
    iv_name = 'Authorization'
    iv_value = |token { p_token }| ).

******************

  CASE abap_true.
    WHEN p_plis.
      DATA(lt_plist) = zcl_gha_gitlab_factory=>get_merge_requests( )->list(
        iv_project_id = 2248898
        iv_state      = 'opened' ).
  ENDCASE.

ENDFORM.
