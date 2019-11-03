REPORT zagci_gitlab_mr_comment_pull.

PARAMETERS: p_id    TYPE i OBLIGATORY,
            p_token TYPE text100 OBLIGATORY.

START-OF-SELECTION.
  PERFORM run.

FORM run.

  zcl_gha_http_client=>add_header(
    iv_name = 'PRIVATE-TOKEN'
    iv_value = |{ p_token }| ).

  DATA(lt_list) = zcl_gha_gitlab_factory=>get_merge_requests( )->list(
    iv_project_id = p_id
    iv_state      = 'opened' ).

  LOOP AT lt_list INTO DATA(ls_list) WHERE target_branch = 'master' AND work_in_progress = 'false'.
    DATA(lv_comment) = |Hello from ZAGCI_GITLAB_MR_COMMENT_PULL|.

    DATA(lt_nlist) = zcl_gha_gitlab_factory=>get_notes( p_id )->list_merge_request( ls_list-iid ).

    IF line_exists( lt_nlist[ body = lv_comment ] ).
      WRITE: / 'already commented'.
      CONTINUE.
    ENDIF.

    zcl_gha_gitlab_factory=>get_notes( p_id )->create_merge_request(
      iv_merge_request_iid = ls_list-iid
      iv_body              = lv_comment ).
    WRITE: / 'comment added'.
  ENDLOOP.

ENDFORM.
