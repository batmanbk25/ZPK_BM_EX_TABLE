*&---------------------------------------------------------------------*
*& Include          ZIM_BM_EX_TABLEF01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  0000_MAIN_PROC
*&---------------------------------------------------------------------*
*       Main process
*----------------------------------------------------------------------*
FORM 0000_MAIN_PROC.
  CASE 'X'.
    WHEN P_UPLOAD.
      PERFORM 0000_UPLOAD_DATA.
    WHEN P_DOWNTP.
      PERFORM 0000_DOWNLOAD_TEMPLATE.
    WHEN P_GENSS.
      PERFORM 0000_GENERATE_SM35.
    WHEN P_DOWNSS.
      PERFORM 0000_DOWNLOAD_SESSION.
  ENDCASE.

ENDFORM.                    " 0000_MAIN_PROC

*&---------------------------------------------------------------------*
*&      Form  1000_PAI
*&---------------------------------------------------------------------*
*       PAI for screen 1000
*----------------------------------------------------------------------*
FORM 1000_PAI .
  DATA:
    LW_FILENAME TYPE STRING,
    LW_RESULT   TYPE XMARK,
    LW_SUBRC    TYPE SY-SUBRC,
    LS_EXTB     TYPE ZTB_BM_EXTB_TAB,
    LW_MAINFLAG TYPE DD02L-MAINFLAG.

  CLEAR: P_DESCR, P_TABNM.
  IF P_VIEWNM IS INITIAL.
    IF SY-UCOMM = 'ONLI'.
      MESSAGE S001(ZMS_EXTB) DISPLAY LIKE 'E' WITH 'View name'.
      SET CURSOR FIELD 'P_VIEWNM'.
      STOP.
    ENDIF.
  ELSE.
    SELECT SINGLE * "VIEWNAME
      FROM ZTB_BM_EXTB_TAB
      INTO LS_EXTB
     WHERE VIEWNAME = P_VIEWNM.
    IF SY-SUBRC IS INITIAL.
      SELECT SINGLE MAINFLAG
        FROM DD02L
        INTO LW_MAINFLAG
       WHERE TABNAME = P_VIEWNM.
      IF SY-SUBRC IS INITIAL
      AND ( LW_MAINFLAG = 'X' OR LW_MAINFLAG IS INITIAL ).
        P_DESCR = LS_EXTB-DESCR.
        P_TABNM = LS_EXTB-TABNAME.
      ELSE.
        MESSAGE S005(ZMS_EXTB) DISPLAY LIKE 'E' WITH P_VIEWNM.
        SET CURSOR FIELD 'P_VIEWNM'.
        STOP.
      ENDIF.
    ELSEIF SY-UCOMM = 'ONLI'.
      MESSAGE S007(ZMS_EXTB) DISPLAY LIKE 'E' WITH P_VIEWNM.
      SET CURSOR FIELD 'P_VIEWNM'.
      STOP.
    ENDIF.
  ENDIF.

  IF P_UPLOAD IS NOT INITIAL AND SY-UCOMM = 'ONLI'.
    LW_FILENAME = P_FILENM.
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIST
      EXPORTING
        FILE                 = LW_FILENAME
      RECEIVING
        RESULT               = LW_RESULT
      EXCEPTIONS
        CNTL_ERROR           = 1
        ERROR_NO_GUI         = 2
        WRONG_PARAMETER      = 3
        NOT_SUPPORTED_BY_GUI = 4
        OTHERS               = 5.
    IF SY-SUBRC <> 0 OR LW_RESULT IS INITIAL.
      MESSAGE S006(ZMS_EXTB) DISPLAY LIKE 'E'  WITH LW_FILENAME.
      SET CURSOR FIELD 'P_FILENM'.
      STOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " 1000_PAI
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'ZGS_0100'.
  SET TITLEBAR 'ZGT_0100'.

  PERFORM 0100_PBO.

ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CALL FUNCTION 'ZFM_SCR_SIMPLE_FC_PROCESS'.
  CASE SY-UCOMM.
    WHEN 'SAVE'.
      PERFORM 0100_PROCESS_FC_SAVE.
    WHEN 'FC_OLDDATA'.
      PERFORM 0100_FC_OLDDATA.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Form  0100_PROCESS_FC_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0100_PROCESS_FC_SAVE .
  CONSTANTS:
    LC_PACK     TYPE I VALUE 5000.
  DATA:
    LW_PACK  TYPE I,
    LW_LINES TYPE I.

  WHILE <GFT_NEW_DATA>[] IS NOT INITIAL.
    LW_LINES = LINES( <GFT_NEW_DATA> ).
    CLEAR: <GFT_ORG_DATA_TMP>.
    IF LW_LINES > LC_PACK.
      LW_PACK = LC_PACK.
    ELSE.
      LW_PACK = LINES( <GFT_NEW_DATA> ).
    ENDIF.
    APPEND LINES OF <GFT_NEW_DATA>
      FROM 1 TO LW_PACK TO <GFT_ORG_DATA_TMP> .
    DELETE <GFT_NEW_DATA> FROM 1 TO LW_PACK.
    INSERT (GW_TABNAME)
      FROM TABLE <GFT_ORG_DATA_TMP> ACCEPTING DUPLICATE KEYS.
    IF SY-SUBRC IS NOT INITIAL.
      UPDATE (GW_TABNAME) FROM TABLE <GFT_ORG_DATA_TMP>.
    ENDIF.
  ENDWHILE.

  COMMIT WORK.
  MESSAGE TEXT-001 TYPE 'S'." S009(ZMS_COL_LIB).
ENDFORM.                    " 100_PROCESS_FC_SAVE

*&---------------------------------------------------------------------*
*&      Form  0100_PBO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0100_PBO .
  DATA:
    LS_LAYOUT  TYPE LVC_S_LAYO,
    LT_EXCL_FC TYPE UI_FUNCTIONS.

  LS_LAYOUT-CWIDTH_OPT  = 'X'.

  CALL FUNCTION 'ZFM_ALV_EXCL_EDIT_FC'
    IMPORTING
      T_EXCL_FC = LT_EXCL_FC.


  CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR'
    EXPORTING
      I_CUS_CONTROL_NAME = 'CUS_ALV_DATA'
      IS_LAYOUT          = LS_LAYOUT
*     IT_TOOLBAR_EXCLUDING = LT_EXCL_FC
*   IMPORTING
*     E_ALV_GRID         =
    CHANGING
      IT_OUTTAB          = <GFT_NEW_DATA>
      IT_FIELDCATALOG    = GT_FIELDCAT.
ENDFORM.                    " 100_PBO

*&---------------------------------------------------------------------*
*& Form 0010_BUILD_STRUCTURE_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LPW_TABNM
*&      <-- LPT_FIELDCAT
*&---------------------------------------------------------------------*
FORM 0010_BUILD_STRUCTURE_FIELD
  USING    LPW_VIEWNM    TYPE TABNAME
  CHANGING LPT_FIELDCAT TYPE LVC_T_FCAT.

  DATA:
    LT_KEYS     TYPE TABLE OF FIELDNAME,
    LS_FIELDCAT TYPE LVC_S_FCAT,
    LR_DATA     TYPE REF TO DATA,
    LS_DATA_RAW TYPE ZST_BM_EXTB_DATA_RAW,
    BEGIN OF LS_VIEW_INFO,
      TABNAME   TYPE DD02L-TABNAME,
      TABCLASS  TYPE DD02L-TABCLASS,
      CLIDEP    TYPE DD02L-CLIDEP,
      MAINFLAG  TYPE DD02L-MAINFLAG,
      VIEWCLASS TYPE DD02L-VIEWCLASS,
      ROOTTAB   TYPE DD25L-ROOTTAB,
    END OF LS_VIEW_INFO.
  FIELD-SYMBOLS:
    <LF_FCAT> type LVC_S_FCAT.


  SELECT SINGLE TABNAME TABCLASS CLIDEP MAINFLAG T~VIEWCLASS ROOTTAB
    INTO LS_VIEW_INFO
    FROM DD02L AS  T LEFT JOIN DD25L AS V
      ON T~TABNAME  = V~VIEWNAME
     AND T~AS4LOCAL = V~AS4LOCAL
     AND T~AS4VERS  = V~AS4VERS
   WHERE T~AS4LOCAL = 'A'
     AND T~TABNAME = LPW_VIEWNM.

* If object is view, set root table for transport
  IF LS_VIEW_INFO-TABCLASS = 'VIEW'.
    GW_TABNAME  = LS_VIEW_INFO-ROOTTAB.
* If object is table, set table for transport
  ELSEIF LS_VIEW_INFO-TABCLASS = 'TRANSP'.
    GW_TABNAME = LS_VIEW_INFO-TABNAME.
  ENDIF.

* Get fieldcatalog
  IF LPT_FIELDCAT IS INITIAL.
    CHECK LPW_VIEWNM IS NOT INITIAL.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        I_STRUCTURE_NAME       = LPW_VIEWNM
        I_INTERNAL_TABNAME     = LPW_VIEWNM
      CHANGING
        CT_FIELDCAT            = LPT_FIELDCAT
      EXCEPTIONS
        INCONSISTENT_INTERFACE = 1
        PROGRAM_ERROR          = 2
        OTHERS                 = 3.
  ENDIF.

* Init
  CLEAR LT_KEYS.
  LOOP AT LPT_FIELDCAT ASSIGNING <LF_FCAT>.
    IF <LF_FCAT>-KEY = 'X'.
      APPEND <LF_FCAT>-FIELDNAME TO LT_KEYS.
    ENDIF.
    <LF_FCAT>-TABNAME = GW_TABNAME.
  ENDLOOP.

* Create table and assign to field symbols
  CREATE DATA LS_DATA_RAW-REFDATA TYPE STANDARD TABLE OF
         (GW_TABNAME) WITH KEY (LT_KEYS).
  LS_DATA_RAW-FILENAME = P_FILENM.
  TRY.
      CALL METHOD CL_SYSTEM_UUID=>IF_SYSTEM_UUID_STATIC~CREATE_UUID_C32
        RECEIVING
          UUID = LS_DATA_RAW-FNHASH.
    CATCH CX_UUID_ERROR.
  ENDTRY.
  LS_DATA_RAW-TABNAME   = GW_TABNAME.
  LS_DATA_RAW-FIELDCAT  = LPT_FIELDCAT.
* VIEWNAME

  APPEND LS_DATA_RAW TO GT_DATA_RAW.

  CREATE DATA LR_DATA TYPE STANDARD TABLE OF
         (GW_TABNAME) WITH KEY (LT_KEYS).
  ASSIGN LR_DATA->* TO <GFT_NEW_DATA>.

  CREATE DATA LR_DATA TYPE STANDARD TABLE OF
         (GW_TABNAME) WITH KEY (LT_KEYS).
  ASSIGN LR_DATA->* TO <GFT_ORG_DATA>.

  CREATE DATA LR_DATA TYPE STANDARD TABLE OF
         (GW_TABNAME) WITH KEY (LT_KEYS).
  ASSIGN LR_DATA->* TO <GFT_ORG_DATA_TMP>.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = GW_TABNAME
      I_INTERNAL_TABNAME     = GW_TABNAME
    CHANGING
      CT_FIELDCAT            = LPT_FIELDCAT
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form 0020_GET_ORIGINAL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <GFT_NEW_DATA>
*&      --> GT_FIELDCAT
*&      <-- <GFT_ORG_DATA>
*&---------------------------------------------------------------------*
FORM 0020_GET_ORIGINAL_DATA
  USING LPT_TABLE_CURRENT     TYPE ANY TABLE
        LPT_FIELDCAT          TYPE LVC_T_FCAT
  CHANGING LPT_TABLE_ORIGINAL TYPE ANY TABLE.
  DATA:
    LS_WHERE     TYPE RSDSWHERE,
    LT_WHERE     TYPE RSDS_WHERE_TAB,
    LT_DATA      TYPE REF TO DATA,
    LS_DATA      TYPE REF TO DATA,
    LW_INTAB_F   TYPE CHAR61,
    LW_WHERE_STR TYPE STRING.

  FIELD-SYMBOLS:
    <LF_VALUE>    TYPE ANY,
    <LF_DATA_STR> TYPE ANY,
    <LF_FIELDCAT> TYPE LVC_S_FCAT.

* Build expression for each key field
  LOOP AT LPT_FIELDCAT ASSIGNING <LF_FIELDCAT>
    WHERE KEY = 'X'.
    CLEAR LS_WHERE.
    CONCATENATE 'LPT_TABLE_CURRENT-'
                <LF_FIELDCAT>-FIELDNAME
           INTO LW_INTAB_F.
    CONCATENATE <LF_FIELDCAT>-FIELDNAME '=' LW_INTAB_F
           INTO LS_WHERE SEPARATED BY SPACE.
    APPEND LS_WHERE TO LT_WHERE.
  ENDLOOP.

  IF  LPT_TABLE_CURRENT IS NOT INITIAL.
    CREATE DATA LS_DATA LIKE LINE OF LPT_TABLE_CURRENT.
    ASSIGN LS_DATA->* TO <LF_DATA_STR>.
  ENDIF.

  CONCATENATE LINES OF LT_WHERE INTO LW_WHERE_STR SEPARATED BY ' AND '.

* Get data from database
  SELECT *
    INTO TABLE LPT_TABLE_ORIGINAL
    FROM (GW_TABNAME)
     FOR ALL ENTRIES IN LPT_TABLE_CURRENT
    WHERE (LW_WHERE_STR).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form 0000_UPLOAD_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM 0000_UPLOAD_DATA .
  DATA:
    LREF_DATA   TYPE REF TO DATA,
    LW_FILENAME TYPE LOCALFILE,
    LS_FIELDCAT TYPE LVC_S_FCAT.
  FIELD-SYMBOLS:
    <LF_NEW_DATA>  TYPE ANY,
    <LF_NEW_VALUE> TYPE ANY,
    <LF_ORG_DATA>  TYPE ANY,
    <LF_ORG_VALUE> TYPE ANY,
    <LF_FCAT>      TYPE lvc_S_FCAT,
    <LF_DATA_RAW>  TYPE ZST_BM_EXTB_DATA_RAW.

* Build structure data
  PERFORM 0010_BUILD_STRUCTURE_FIELD
    USING P_VIEWNM
    CHANGING GT_FIELDCAT.

* Import data from excel
  LW_FILENAME =  P_FILENM.
  CALL FUNCTION 'ZFM_BM_TABLE_EXCEL_UPLOAD'
    EXPORTING
      I_LINE_DATA       = 6 "2
      I_FILENAME        = LW_FILENAME
*     I_STEP            = 1
      I_TECHNAME_LINE   = 4
    CHANGING
      CT_DATA_RAW       = GT_DATA_RAW
    EXCEPTIONS
      CONVERSION_FAILED = 1
      OTHERS            = 2.

  LOOP AT GT_DATA_RAW ASSIGNING <LF_DATA_RAW>.
    ASSIGN <LF_DATA_RAW>-REFDATA->* TO <GFT_NEW_DATA>.

    READ TABLE GT_FIELDCAT INTO LS_FIELDCAT
      WITH KEY DOMNAME = 'MANDT'.
    IF SY-SUBRC IS INITIAL.
      LOOP AT <GFT_NEW_DATA> ASSIGNING <LF_NEW_DATA>.
        ASSIGN COMPONENT LS_FIELDCAT-FIELDNAME OF STRUCTURE <LF_NEW_DATA>
          TO <LF_NEW_VALUE>.
        IF SY-SUBRC IS INITIAL.
          <LF_NEW_VALUE> = SY-MANDT.
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT <LF_DATA_RAW>-MAPFCAT INTO LS_FIELDCAT.
      READ TABLE GT_FIELDCAT ASSIGNING <LF_FCAT>
        WITH KEY FIELDNAME = LS_FIELDCAT-FIELDNAME.
      IF SY-SUBRC IS INITIAL.
        <LF_FCAT>-EMPHASIZE     = 'C500'.
      ENDIF.
    ENDLOOP.

    IF P_GETORG IS NOT INITIAL AND <GFT_NEW_DATA> IS NOT INITIAL.
*     Get original data to update
      PERFORM 0020_GET_ORIGINAL_DATA
        USING <GFT_NEW_DATA>
              GT_FIELDCAT
        CHANGING <GFT_ORG_DATA>.
    ENDIF.

    CREATE DATA LREF_DATA LIKE LINE OF <GFT_ORG_DATA>.
    ASSIGN LREF_DATA->* TO <LF_ORG_DATA>.

*   Loop new data to update original data
    LOOP AT <GFT_NEW_DATA> ASSIGNING <LF_NEW_DATA>.
*     Find original data
      READ TABLE <GFT_ORG_DATA> INTO <LF_ORG_DATA>
        FROM <LF_NEW_DATA>.
      IF SY-SUBRC IS INITIAL.
*        LOOP AT LT_EXCEL_MAPPING INTO LS_EXCEL_MAPPING.
        LOOP AT <LF_DATA_RAW>-MAPFCAT INTO LS_FIELDCAT.
          UNASSIGN: <LF_ORG_VALUE>, <LF_NEW_VALUE>.
          ASSIGN COMPONENT LS_FIELDCAT-FIELDNAME
            OF STRUCTURE <LF_ORG_DATA> TO <LF_ORG_VALUE>.
          ASSIGN COMPONENT LS_FIELDCAT-FIELDNAME
            OF STRUCTURE <LF_NEW_DATA> TO <LF_NEW_VALUE>.
          CHECK: <LF_NEW_VALUE> IS ASSIGNED, <LF_ORG_VALUE> IS ASSIGNED.
          <LF_ORG_VALUE> = <LF_NEW_VALUE>.
        ENDLOOP.
        <LF_NEW_DATA> = <LF_ORG_DATA>.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

* Show change data
  CALL SCREEN 100.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form 0000_DOWNLOAD_TEMPLATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM 0000_DOWNLOAD_TEMPLATE .
  DATA:
    LS_EXCEL          TYPE ZST_BM_EXTB_TEMPLATE,
    LW_LINEIX         TYPE INT4,
    LW_LINKIX         TYPE INT4,
    LW_TABNM          TYPE TABNAME,
    LS_FIELDCAT_DOCID TYPE LVC_S_FCAT,
    LW_LEN            TYPE INT4,
    LW_PARNAME        TYPE CHAR30.

  SELECT SINGLE *
    FROM ZTB_BM_EXTB_TAB
    INTO CORRESPONDING FIELDS OF LS_EXCEL
   WHERE VIEWNAME = P_VIEWNM.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = P_VIEWNM
    CHANGING
      CT_FIELDCAT            = LS_EXCEL-FIELDCAT
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  DELETE LS_EXCEL-FIELDCAT WHERE TECH = 'X'.

  CALL FUNCTION 'ZXLWB_CALLFORM'
    EXPORTING
      IV_FORMNAME    = 'ZXLSX_EXTB_TEMPLATE'
      IV_CONTEXT_REF = LS_EXCEL
    EXCEPTIONS
      OTHERS         = 2.
  IF SY-SUBRC NE 0 .
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 .
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form 1000_PBO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM 1000_PBO .

  LOOP AT SCREEN.
    SCREEN-ACTIVE = '0'.
    CASE 'X'.
      WHEN P_UPLOAD.
        IF SCREEN-GROUP1 = '' OR SCREEN-GROUP1 = 'GR1'.
          SCREEN-ACTIVE = '1'.
        ENDIF.
        MODIFY SCREEN.
      WHEN P_DOWNTP.
        IF SCREEN-GROUP1 = '' OR SCREEN-GROUP1 = 'GR2'.
          SCREEN-ACTIVE = '1'.
        ENDIF.
      WHEN OTHERS.
        SCREEN-ACTIVE = '1'.
    ENDCASE.
    IF SCREEN-NAME = 'P_DESCR'.
      SCREEN-DISPLAY_3D = 0.
      SCREEN-INPUT = 0.
    ELSEIF SCREEN-NAME = 'P_TABNM'.
      SCREEN-INPUT = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form 0100_FC_OLDDATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM 0100_FC_OLDDATA .
  DATA:
    LS_LAYOUT TYPE LVC_S_LAYO.

  LS_LAYOUT-CWIDTH_OPT = 'X'.

  CALL FUNCTION 'ZFM_ALV_DISPLAY'
    EXPORTING
      IT_FIELDCAT   = GT_FIELDCAT
      IS_LAYOUT_LVC = LS_LAYOUT
      I_GRID_TITLE  = 'Old data'
*     I_SCREEN_START_COLUMN = 5
*     I_SCREEN_START_LINE   = 4
*     I_SCREEN_END_COLUMN   = 150
*     I_SCREEN_END_LINE     = 30
*     IT_EXCLUDING  =
    TABLES
      T_OUTTAB      = <GFT_ORG_DATA>.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form 0000_GENERATE_SM35
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM 0000_GENERATE_SM35 .
* Ascii download table
  DATA: BEGIN OF LS_LINE_ASC,
          TEXT(1024) TYPE C,
        END OF LS_LINE_ASC.
  DATA: LT_LINE_ASC LIKE STANDARD TABLE OF LS_LINE_ASC,
        LS_BDCDATA  TYPE BDCDATA,
        LT_BDCDATA  TYPE TABLE OF BDCDATA.

* Get filename
  DATA: LW_FULLPATH TYPE STRING,
        FILENAME    TYPE STRING,
        PATH        TYPE STRING,
        USER_ACTION TYPE I,
        ENCODING    TYPE ABAP_ENCODING,
        LW_QID      TYPE  APQI-QID.


* Download variables
  DATA: LENGTH TYPE I.

  PERFORM 9999_GET_BDC_DATA
    CHANGING LT_BDCDATA.

  CALL FUNCTION 'BDC_OPEN_GROUP'
    EXPORTING
      GROUP               = 'CONFIGROBO'
      KEEP                = 'X'
      USER                = SY-UNAME
    IMPORTING
      QID                 = LW_QID
    EXCEPTIONS
      CLIENT_INVALID      = 1
      DESTINATION_INVALID = 2
      GROUP_INVALID       = 3
      GROUP_IS_LOCKED     = 4
      HOLDDATE_INVALID    = 5
      INTERNAL_ERROR      = 6
      QUEUE_ERROR         = 7
      RUNNING             = 8
      SYSTEM_LOCK_ERROR   = 9
      USER_INVALID        = 10
      OTHERS              = 11.

  CALL FUNCTION 'BDC_INSERT'
    EXPORTING
      TCODE            = 'ZCONFIGROBO'
    TABLES
      DYNPROTAB        = LT_BDCDATA
    EXCEPTIONS
      INTERNAL_ERROR   = 1
      NOT_OPEN         = 2
      QUEUE_ERROR      = 3
      TCODE_INVALID    = 4
      PRINTING_INVALID = 5
      POSTING_INVALID  = 6
      OTHERS           = 7.
  CALL FUNCTION 'BDC_CLOSE_GROUP'
    EXCEPTIONS
      NOT_OPEN    = 1
      QUEUE_ERROR = 2
      OTHERS      = 3.

** Ascii download
*  CALL FUNCTION 'GUI_DOWNLOAD'
*    EXPORTING
*      FILENAME                = FULLPATH
*      FILETYPE                = 'ASC'
*    IMPORTING
*      FILELENGTH              = LENGTH
*    TABLES
*      DATA_TAB                = DATA_TAB_ASC
*    EXCEPTIONS
*      FILE_WRITE_ERROR        = 1
*      NO_BATCH                = 2
*      GUI_REFUSE_FILETRANSFER = 3
*      INVALID_TYPE            = 4
*      NO_AUTHORITY            = 5
*      UNKNOWN_ERROR           = 6
*      HEADER_NOT_ALLOWED      = 7
*      SEPARATOR_NOT_ALLOWED   = 8
*      FILESIZE_NOT_ALLOWED    = 9
*      HEADER_TOO_LONG         = 10
*      DP_ERROR_CREATE         = 11
*      DP_ERROR_SEND           = 12
*      DP_ERROR_WRITE          = 13
*      UNKNOWN_DP_ERROR        = 14
*      ACCESS_DENIED           = 15
*      DP_OUT_OF_MEMORY        = 16
*      DISK_FULL               = 17
*      DP_TIMEOUT              = 18
*      FILE_NOT_FOUND          = 19
*      DATAPROVIDER_EXCEPTION  = 20
*      CONTROL_FLUSH_ERROR     = 21
*      OTHERS                  = 22.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form 0000_DOWNLOAD_SESSION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM 0000_DOWNLOAD_SESSION .
* Ascii download table
  DATA: BEGIN OF LS_LINE_ASC,
          TEXT(1024) TYPE C,
        END OF LS_LINE_ASC.
  DATA: LT_LINE_ASC LIKE STANDARD TABLE OF LS_LINE_ASC,
        LS_BDCDATA  TYPE BDCDATA,
        LT_BDCDATA  TYPE TABLE OF BDCDATA,
        LW_TAB      TYPE C VALUE CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB,
        LW_FULLPATH TYPE STRING,
        LW_EXT      TYPE STRING,
        LW_QID      TYPE  APQI-QID,
        LW_LENGTH   TYPE I,
        LV_OFF      TYPE I.

  PERFORM 9999_GET_BDC_DATA
    CHANGING LT_BDCDATA.

  LOOP AT LT_BDCDATA INTO LS_BDCDATA.
    CONCATENATE LS_BDCDATA-PROGRAM
                LS_BDCDATA-DYNPRO
                LS_BDCDATA-DYNBEGIN
                LS_BDCDATA-FNAM
                LS_BDCDATA-FVAL
           INTO LS_LINE_ASC-TEXT
      SEPARATED BY LW_TAB RESPECTING BLANKS.
*    LS_LINE_ASC = LS_BDCDATA.
    LW_LENGTH = LW_LENGTH + STRLEN( LS_LINE_ASC ).
    APPEND LS_LINE_ASC TO LT_LINE_ASC.
  ENDLOOP.

  FIND ALL OCCURRENCES OF '.' IN P_FILENM MATCH OFFSET LV_OFF.
  LW_FULLPATH = P_FILENM(LV_OFF) && '.session'.

* Ascii download
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      FILENAME                = LW_FULLPATH
      FILETYPE                = 'ASC'
    IMPORTING
      FILELENGTH              = LW_LENGTH
    TABLES
      DATA_TAB                = LT_LINE_ASC
    EXCEPTIONS
      FILE_WRITE_ERROR        = 1
      NO_BATCH                = 2
      GUI_REFUSE_FILETRANSFER = 3
      INVALID_TYPE            = 4
      NO_AUTHORITY            = 5
      UNKNOWN_ERROR           = 6
      HEADER_NOT_ALLOWED      = 7
      SEPARATOR_NOT_ALLOWED   = 8
      FILESIZE_NOT_ALLOWED    = 9
      HEADER_TOO_LONG         = 10
      DP_ERROR_CREATE         = 11
      DP_ERROR_SEND           = 12
      DP_ERROR_WRITE          = 13
      UNKNOWN_DP_ERROR        = 14
      ACCESS_DENIED           = 15
      DP_OUT_OF_MEMORY        = 16
      DISK_FULL               = 17
      DP_TIMEOUT              = 18
      FILE_NOT_FOUND          = 19
      DATAPROVIDER_EXCEPTION  = 20
      CONTROL_FLUSH_ERROR     = 21
      OTHERS                  = 22.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form 9999_GET_BDC_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LPT_BDCDATA
*&---------------------------------------------------------------------*
FORM 9999_GET_BDC_DATA
  CHANGING LPT_BDCDATA TYPE BDCDATA_TAB.
  DATA:
    LS_BDCDATA  TYPE BDCDATA.

  IF P_DOWNSS IS NOT INITIAL.
    CLEAR: LS_BDCDATA.
    LS_BDCDATA-DYNBEGIN = 'M'.
    LS_BDCDATA-FNAM = 'CONFIGROBO'.
    LS_BDCDATA-FVAL = 'CT.TUAN             24112022  142601'.
    APPEND LS_BDCDATA TO LPT_BDCDATA.

    CLEAR: LS_BDCDATA.
    LS_BDCDATA-DYNBEGIN = 'T'.
    LS_BDCDATA-FNAM = 'ZCONFIGROBO'.
    LS_BDCDATA-FVAL = 'BS AA X   F'.
    APPEND LS_BDCDATA TO LPT_BDCDATA.
  ENDIF.

  CLEAR: LS_BDCDATA.
  LS_BDCDATA-PROGRAM = 'ZPG_BM_EX_TABLE'.
  LS_BDCDATA-DYNPRO = '1000'.
  LS_BDCDATA-DYNBEGIN = 'X'.
  APPEND LS_BDCDATA TO LPT_BDCDATA.

  CLEAR: LS_BDCDATA.
  LS_BDCDATA-FNAM = 'BDC_CURSOR'.
  LS_BDCDATA-FVAL = 'P_FILENM'.
  APPEND LS_BDCDATA TO LPT_BDCDATA.

  CLEAR: LS_BDCDATA.
  LS_BDCDATA-FNAM = 'BDC_OKCODE'.
  LS_BDCDATA-FVAL = '=ONLI'.
  APPEND LS_BDCDATA TO LPT_BDCDATA.

  CLEAR: LS_BDCDATA.
  LS_BDCDATA-FNAM = 'P_UPLOAD'.
  LS_BDCDATA-FVAL = 'X'.
  APPEND LS_BDCDATA TO LPT_BDCDATA.

  CLEAR: LS_BDCDATA.
  LS_BDCDATA-FNAM = 'P_VIEWNM'.
  LS_BDCDATA-FVAL = P_VIEWNM.
  APPEND LS_BDCDATA TO LPT_BDCDATA.

  CLEAR: LS_BDCDATA.
  LS_BDCDATA-FNAM = 'P_FILENM'.
  LS_BDCDATA-FVAL = P_FILENM.
  APPEND LS_BDCDATA TO LPT_BDCDATA.

  CLEAR: LS_BDCDATA.
  LS_BDCDATA-PROGRAM = 'ZPG_BM_EX_TABLE'.
  LS_BDCDATA-DYNPRO = '0100'.
  LS_BDCDATA-DYNBEGIN = 'X'.
  APPEND LS_BDCDATA TO LPT_BDCDATA.

  CLEAR: LS_BDCDATA.
  LS_BDCDATA-FNAM = 'BDC_OKCODE'.
  LS_BDCDATA-FVAL = '=SAVE'.
  APPEND LS_BDCDATA TO LPT_BDCDATA.
ENDFORM.
