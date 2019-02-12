class ZCL_GHA_GITHUB_FACTORY definition
  public
  create public .

public section.

  methods GET_PULL_REQUESTS
    returning
      value(RI_INSTANCE) type ref to ZIF_GHA_GITHUB_PULL_REQUESTS .
protected section.
private section.
ENDCLASS.



CLASS ZCL_GHA_GITHUB_FACTORY IMPLEMENTATION.


  METHOD get_pull_requests.

    ri_instance = NEW zcl_gha_github_pull_requests( ).

  ENDMETHOD.
ENDCLASS.
