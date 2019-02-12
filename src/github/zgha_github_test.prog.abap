REPORT zgha_github_test.

PARAMETERS: p_token TYPE text100 OBLIGATORY,
            p_plis  TYPE c RADIOBUTTON GROUP g1,
            p_pcre  TYPE c RADIOBUTTON GROUP g1,
            p_clis  TYPE c RADIOBUTTON GROUP g1,
            p_pclo  TYPE c RADIOBUTTON GROUP g1.

START-OF-SELECTION.
  PERFORM run.

FORM run.

  zcl_gha_http_client=>add_header(
    iv_name = 'Authorization'
    iv_value = |token { p_token }| ).

******************

  CASE abap_true.
    WHEN p_plis.
      DATA(lt_plist) = zcl_gha_github_factory=>get_pull_requests(
        iv_owner = 'Microsoft'
        iv_repo  = 'vscode' )->list( ).
    WHEN p_pcre.
      zcl_gha_github_factory=>get_pull_requests(
        iv_owner = 'abapGit'
        iv_repo  = 'abap_git_hosts_apis' )->create(
          iv_title = 'title'
          iv_head  = 'branch'
          iv_base  = 'master' ).
    WHEN p_clis.
      DATA(lt_clist) = zcl_gha_github_factory=>get_comments(
          iv_owner = 'abapGit'
          iv_repo  = 'abap_git_hosts_apis' )->list( 3 ).
    WHEN p_pclo.
      zcl_gha_github_factory=>get_pull_requests(
        iv_owner = 'abapGit'
        iv_repo  = 'abap_git_hosts_apis' )->update(
          iv_number = 4
          iv_state = 'closed' ).
  ENDCASE.

ENDFORM.
