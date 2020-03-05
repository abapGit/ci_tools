REPORT zagci_run_unit_tests.

PARAMETERS: p_devc TYPE tdevc-devclass OBLIGATORY.

START-OF-SELECTION.
  PERFORM run.

FORM run RAISING zcx_abapgit_exception.

  DATA(lt_result) = NEW zcl_agci_unit_tests( )->run( p_devc ).

  LOOP AT lt_result INTO DATA(ls_result).
    WRITE: / ls_result-tadir-obj_name, ls_result-tadir-devclass, ls_result-has_skipped.

    LOOP AT ls_result-tests INTO DATA(ls_test).
      IF ls_test-kind IS INITIAL.
        WRITE: / icon_green_light, ls_test-class_name, ls_test-method_name, ls_test-kind.
      ELSE.
        WRITE: / icon_red_light, ls_test-class_name, ls_test-method_name, ls_test-kind.
      ENDIF.
    ENDLOOP.

    WRITE: /.
  ENDLOOP.

ENDFORM.
