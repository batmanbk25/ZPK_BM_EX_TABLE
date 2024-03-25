*&---------------------------------------------------------------------*
*& Include ZIM_BM_EX_TABLETOP                  - Report ZPG_BM_EX_TABLE
*&---------------------------------------------------------------------*

**********************************************************************
* TYPES                                                         *
**********************************************************************

**********************************************************************
* DATA                                                               *
**********************************************************************
FIELD-SYMBOLS:
  <GFT_NEW_DATA>     TYPE STANDARD TABLE,
  <GFT_ORG_DATA>     TYPE STANDARD TABLE,
  <GFT_ORG_DATA_TMP> TYPE STANDARD TABLE.
DATA:
  GW_TABNAME  TYPE TABNAME,
  GT_FIELDCAT TYPE LVC_T_FCAT,
  GT_DATA_RAW TYPE TABLE OF ZST_BM_EXTB_DATA_RAW.

**********************************************************************
* PARAMETERS                                                         *
**********************************************************************
SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN COMMENT  1(33) TEXT-004.
  SELECTION-SCREEN POSITION 35.
  PARAMETERS:
  P_UPLOAD RADIOBUTTON GROUP ID  DEFAULT 'X' USER-COMMAND UC1.
  SELECTION-SCREEN COMMENT  36(10) TEXT-002 FOR FIELD P_UPLOAD.
  SELECTION-SCREEN POSITION 55.
  PARAMETERS:
  P_DOWNTP RADIOBUTTON GROUP ID.
  SELECTION-SCREEN COMMENT  57(17) TEXT-003  FOR FIELD P_DOWNTP.

SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN POSITION 35.
  PARAMETERS:
  P_GENSS RADIOBUTTON GROUP ID .
  SELECTION-SCREEN COMMENT  37(17) TEXT-005 FOR FIELD P_UPLOAD.
  SELECTION-SCREEN POSITION 55.
  PARAMETERS:
  P_DOWNSS RADIOBUTTON GROUP ID.
  SELECTION-SCREEN COMMENT  57(17) TEXT-006  FOR FIELD P_DOWNTP.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN COMMENT  1(33) FOR FIELD P_VIEWNM.
*  SELECTION-SCREEN POSITION 35.
  PARAMETERS:
    P_VIEWNM TYPE ZTB_BM_EXTB_TAB-VIEWNAME.
  SELECTION-SCREEN POSITION 68.
  PARAMETERS:
  P_DESCR TYPE ZTB_BM_EXTB_TAB-DESCR.
SELECTION-SCREEN END OF LINE.

PARAMETERS:
  P_TABNM  TYPE ZTB_BM_EXTB_TAB-TABNAME,
  P_FILENM TYPE ESEFTFRONT MATCHCODE OBJECT ICL_DIAGFILENAME MODIF ID GR1,
  P_GETORG TYPE XMARK DEFAULT 'X'  NO-DISPLAY.
