REPORT zgha_github_test.

START-OF-SELECTION.
  PERFORM run.

FORM run.

  DATA(lt_list) = zcl_gha_github_factory=>get_pull_requests( )->list(
    iv_owner = 'Microsoft'
    iv_repo  = 'vscode' ).

  BREAK-POINT.

ENDFORM.
