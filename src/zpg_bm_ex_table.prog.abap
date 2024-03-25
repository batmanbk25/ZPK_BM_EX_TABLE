*&---------------------------------------------------------------------*
*& Report ZPG_BM_EX_TABLE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

REPORT ZPG_BM_EX_TABLE.
INCLUDE ZIM_BM_EX_TABLETOP                      .    " Global Data

* INCLUDE ZIM_BM_EX_TABLEO01                      .  " PBO-Modules
* INCLUDE ZIM_BM_EX_TABLEI01                      .  " PAI-Modules
 INCLUDE ZIM_BM_EX_TABLEF01                      .  " FORM-Routines

AT SELECTION-SCREEN OUTPUT.
  PERFORM 1000_PBO.

AT SELECTION-SCREEN.
  PERFORM 1000_PAI.

START-OF-SELECTION.
  PERFORM 0000_MAIN_PROC.
