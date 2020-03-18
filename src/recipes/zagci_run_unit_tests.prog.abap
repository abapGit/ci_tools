REPORT zagci_run_unit_tests.

PARAMETERS: p_devc TYPE tdevc-devclass OBLIGATORY,
            p_unit RADIOBUTTON GROUP grp1 DEFAULT 'X',
            p_cov  RADIOBUTTON GROUP grp1.

START-OF-SELECTION.
  PERFORM run.

FORM run RAISING zcx_abapgit_exception.

  IF p_unit = abap_true.
    DATA(lt_results) = NEW zcl_agci_unit_tests( )->run( p_devc ).
  ELSE.
    DATA(ls_cov_result) = NEW zcl_agci_unit_tests( )->run_with_coverage( p_devc ).
    lt_results = ls_cov_result-results.
  ENDIF.

  LOOP AT lt_results INTO DATA(ls_result).
    WRITE: / ls_result-tadir-obj_name, ls_result-tadir-devclass, ls_result-has_skipped.

    LOOP AT ls_result-tests INTO DATA(ls_test).
      IF ls_test-kind IS INITIAL.
        WRITE: / icon_green_light, ls_test-class_name, ls_test-method_name, ls_test-kind.
      ELSE.
        WRITE: / icon_red_light, ls_test-class_name, ls_test-method_name, ls_test-kind.
      ENDIF.
      WRITE: /.
    ENDLOOP.

    WRITE: /.
  ENDLOOP.

  IF p_cov = abap_true.
    WRITE: / `Branch Executed :          `, ls_cov_result-coverage-branch_percentage, `%`.
    WRITE: / `Processing block Executed :`, ls_cov_result-coverage-block_percentage, `%`.
    WRITE: / `Statement Executed :       `, ls_cov_result-coverage-statement_percentage, `%`.
  ENDIF.

ENDFORM.
