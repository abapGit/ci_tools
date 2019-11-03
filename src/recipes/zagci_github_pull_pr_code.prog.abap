REPORT zagci_github_pull_pr_code.

PARAMETERS: p_owner TYPE text100 DEFAULT 'larshp' OBLIGATORY,
            p_repo  TYPE text100 DEFAULT 'abapOpenChecks' OBLIGATORY.

START-OF-SELECTION.
  PERFORM run.

FORM run RAISING zcx_abapgit_exception.

  DATA(lt_plist) = zcl_gha_github_factory=>get_pull_requests(
    iv_owner = CONV #( p_owner )
    iv_repo  = CONV #( p_repo ) )->list( ).

  LOOP AT lt_plist INTO DATA(ls_pr).
    WRITE: / ls_pr-number, ls_pr-title, ls_pr-head-sha.

    DATA(lt_clist) = zcl_gha_github_factory=>get_check_suites(
      iv_owner = CONV #( p_owner )
      iv_repo  = CONV #( p_repo ) )->list( ls_pr-head-sha ).
    LOOP AT lt_clist INTO DATA(ls_suite).
      WRITE: / ls_suite-id, ls_suite-status, ls_suite-conclusion.
    ENDLOOP.

    DATA(lo_repo) = NEW zcl_agci_abapgit_utils( )->find_repo_by_url(
      iv_url1 = ls_pr-base-html_url
      iv_url2 = ls_pr-base-clone_url ).
    IF lo_repo IS BOUND.
      WRITE: / 'found, known by abapGit'.
      NEW zcl_agci_abapgit_utils( )->pull_by_sha1(
        io_repo = lo_repo
        iv_sha1 = ls_pr-head-sha ).
    ELSE.
      WRITE: / 'unknown by abapGit'.
    ENDIF.

    WRITE: /.
  ENDLOOP.

ENDFORM.
