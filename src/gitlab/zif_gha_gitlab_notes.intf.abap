interface ZIF_GHA_GITLAB_NOTES
  public .


  types:
    BEGIN OF ty_list,
           id   TYPE i,
           body TYPE string,
         END OF ty_list .
  types:
    ty_list_tt TYPE STANDARD TABLE OF ty_list WITH EMPTY KEY .

  methods CREATE_MERGE_REQUEST
    importing
      !IV_MERGE_REQUEST_IID type I
      !IV_BODY type STRING .
  methods LIST_MERGE_REQUEST
    importing
      !IV_MERGE_REQUEST_IID type I
    returning
      value(RT_LIST) type TY_LIST_TT .
endinterface.
