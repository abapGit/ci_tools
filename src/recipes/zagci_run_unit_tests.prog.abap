REPORT zagci_run_unit_tests.

PARAMETERS: p_devc TYPE tdevc-devclass OBLIGATORY,
            p_unit RADIOBUTTON GROUP grp1 DEFAULT 'X',
            p_cov  RADIOBUTTON GROUP grp1.

START-OF-SELECTION.
  PERFORM run.

FORM run RAISING zcx_abapgit_exception.

  DATA: lv_branch_executed      TYPE i,
        lv_branch_total         TYPE i,
        lv_branch_procentage    TYPE decfloat16,
        lv_block_executed       TYPE i,
        lv_block_total          TYPE i,
        lv_block_procentage     TYPE decfloat16,
        lv_statement_executed   TYPE i,
        lv_statement_total      TYPE i,
        lv_statement_procentage TYPE decfloat16.

  IF p_unit = abap_true.
    DATA(lt_result) = NEW zcl_agci_unit_tests( )->run( p_devc ).
  ELSE.
    lt_result = NEW zcl_agci_unit_tests( )->run_with_coverage( p_devc ).
  ENDIF.

  LOOP AT lt_result INTO DATA(ls_result).
    WRITE: / ls_result-tadir-obj_name, ls_result-tadir-devclass, ls_result-has_skipped.

    LOOP AT ls_result-tests INTO DATA(ls_test).
      IF ls_test-kind IS INITIAL.
        WRITE: / icon_green_light, ls_test-class_name, ls_test-method_name, ls_test-kind.
      ELSE.
        WRITE: / icon_red_light, ls_test-class_name, ls_test-method_name, ls_test-kind.
      ENDIF.
      WRITE: /.
      LOOP AT ls_result-coverages INTO DATA(ls_coverage).
        CASE ls_coverage-type.
          WHEN 'Branch Coverage'.
            lv_branch_executed = lv_branch_executed + ls_coverage-executed.
            lv_branch_total = lv_branch_total + ls_coverage-executed + ls_coverage-not_executed.
          WHEN 'Processing Block Coverage'.
            lv_block_executed = lv_block_executed + ls_coverage-executed.
            lv_block_total = lv_block_total + ls_coverage-not_executed.
          WHEN 'Statement Coverage'.
            lv_statement_executed = lv_statement_executed + ls_coverage-executed.
            lv_statement_total = lv_statement_total + ls_coverage-executed + ls_coverage-not_executed.
        ENDCASE.
      ENDLOOP.

    ENDLOOP.

    WRITE: /.
  ENDLOOP.

  IF p_cov = abap_true.
    lv_branch_procentage = lv_branch_executed / lv_branch_total.
    lv_block_procentage = lv_block_executed / lv_block_total.
    lv_statement_procentage = lv_statement_executed / lv_statement_total.

    WRITE:/ `Branch Executed :           `, lv_branch_executed, `/`, lv_branch_total,  lv_branch_procentage, `%`.
    WRITE:/ `Processing block Executed : `, lv_block_executed, `/`, lv_block_total, lv_block_procentage, `%`.
    WRITE:/ `Statement Executed :        `, lv_statement_executed, `/`, lv_statement_total, lv_statement_procentage, `%`.
  ENDIF.

ENDFORM.
