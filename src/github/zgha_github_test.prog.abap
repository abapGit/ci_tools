REPORT zgha_github_test.

PARAMETERS: p_token TYPE text100 OBLIGATORY.

START-OF-SELECTION.
  PERFORM run.

FORM run.

  zcl_gha_http_client=>add_header(
    iv_name = 'Authorization'
    iv_value = |token { p_token }| ).

******************

*  DATA(lt_list) = zcl_gha_github_factory=>get_pull_requests(
*    iv_owner = 'Microsoft'
*    iv_repo  = 'vscode' )->list( ).

*  zcl_gha_github_factory=>get_pull_requests(
*    iv_owner = 'abapGit'
*    iv_repo  = 'abap_git_hosts_apis' )->create(
*      iv_title = 'title'
*      iv_head  = 'branch'
*      iv_base  = 'master' ).

  DATA(lt_list) = zcl_gha_github_factory=>get_comments(
      iv_owner = 'abapGit'
      iv_repo  = 'abap_git_hosts_api' )->list( 1 ).

  BREAK-POINT.

ENDFORM.
