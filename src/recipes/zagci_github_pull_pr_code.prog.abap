REPORT zagci_github_pull_pr_code.

PARAMETERS: p_owner TYPE text100 DEFAULT 'larshp' OBLIGATORY,
            p_repo  TYPE text100 DEFAULT 'abapOpenChecks' OBLIGATORY.

START-OF-SELECTION.
  PERFORM run.

FORM run.

  DATA(lt_plist) = zcl_gha_github_factory=>get_pull_requests(
    iv_owner = CONV #( p_owner )
    iv_repo  = CONV #( p_repo ) )->list( ).

  LOOP AT lt_plist INTO DATA(ls_pr).
    WRITE: / ls_pr-number, ls_pr-title, ls_pr-head_sha.

    DATA(lt_clist) = zcl_gha_github_factory=>get_check_suites(
      iv_owner = CONV #( p_owner )
      iv_repo  = CONV #( p_repo ) )->list( ls_pr-head_sha ).
    LOOP AT lt_clist INTO DATA(ls_suite).
      WRITE: / ls_suite-id, ls_suite-status, ls_suite-conclusion.
    ENDLOOP.

    WRITE: /.
  ENDLOOP.

ENDFORM.
