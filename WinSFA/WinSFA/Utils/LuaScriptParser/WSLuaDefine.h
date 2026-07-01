//
//  WSLuaDefine.h
//  WinSFA
//
//  Created by yang on 15/12/11.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#ifndef WSLuaDefine_h
#define WSLuaDefine_h

#define LUA_ON_SUBMIT_FUNCTION                  ("onSubmit")
#define LUA_GET_TABLE_FIRST_COLS_FUNCTION       ("getTableFirstCols")
#define LUA_GET_CUR_STORE_INFO_FUNCTION         ("getCurStoreWithParamInfo")
#define LUA_GET_CUR_STORE_INFO_BY_PARAM_FUNCTION ("getCurStoreInfoByParam")
#define LUA_FIND_ELEMENT_BY_NAME_FUNCTION       ("findElementByName")
#define LUA_SET_TIP_FUNCTION                    ("setTip")
#define LUA_SET_RESULT_FUNCTION                 ("setResult")
#define LUA_SEND_SMS_FUNCTION                   ("sendSMS")

#define LUA_DELETE_STORE_ACTION                 ("deleteStoreAction")               //删除当前门店
#define LUA_CREATE_AND_VISIT_STORE_ACTION       ("createAndVisitStoreAction")       //创建及拜访门店
#define LUA_SAVE_ACVT_DATA                      ("saveAcvtData")       //保存问卷


#define LUA_START_FUNCTION                      ("startFunction")
#define LUA_FIND_ELEMENT_IN_OTHER_FUNCTION      ("findElementInOther")
#define LUA_FIND_ELEMENT_IN_ACVT_QSTS_FUNCTION  ("findElementInAcvtQsts")

#define LUA_MODIFY_QST_REQUIREDSTATE_BY_SELECTEDITEM_FUNCTION ("modifyQstRequiredStateBySelectedItem")
#define LUA_MODIFY_CONTENT_REQUIREDSTATE_BY_BOOLEANEXPRESSION_FUNCTION ("modifyContentRequiredStateByBooleanExpression")
#define LUA_ON_CHECK_FUNCTION                  ("onCheck")

#define LUA_ARITHMETIC_EXPRESSIONS_FUNCTION        ("arithmeticExpressions")

#define LUA_COMPUTE_SUM_TO_TARGET_FUNCTION ("computeSumToTarget")
#define LUA_COMPUTE_TABLE_SUM_FUNCTION ("computeTableSum")
#define LUA_COMPUTE_COL_SUM_FUNCTION ("computeColSum")

#define LUA_CALL_QST_WIDGET_METHOD_BY_QSTNAME_FUNCTION ("callQstWidgetMethodByQstName")
#define LUA_ALLOW_EXAM_FUNCTION ("allowExam")

#define LUA_GENERATE_URL_STRING_WITH_PARAMS_FUNCTION ("generateURLStringWithParams")
#define LUA_GENERATE_URL_FUNCTION ("generateURL")

#define LUA_MEETING_APPLICANT_INFO ("meetingApplicantInfo")
#define LUA_SET_CURRENT_QST_VALUE_WITH_TYPE ("setCurrentQstValueWithType")

#define LUA_REFRESH_STATE_FUNCTION ("refreshState")
#define LUA_SET_UPLOAD_BUTTON_HIDDEN ("setUploadButtonHidden")

#define LUA_CHECK_PRODUCT_VALIDATE_IN_TABLE ("checkProductValidateInTable")
#define LUA_CHECK_PRODUCT_VALIDATE ("checkProductValidate")


#define LUA_CHANGE_QST_VALUE ("changeQstValue")
#define LUA_GET_COL_MAX_VALUE_IN_TABLE ("getColMaxValueInTable")
#define LUA_COMPUTE_ROW_AND_COL_SUM ("computeRowAndColSum")


#define LUA_EXCUSE_ACTION_FUNCTION  ("excuseAction")
#define LUA_WEChAT_IMG_SHARE_ACTION ("exceseWeChatImgShare")            //微信分享

#define LUA_GET_SERVER_QST_VALUE_BY_QST_CODE ("getServerQstValueByQstCode") 
#define LUA_GET_ENTER_STORE_TIME ("getEnterStoreTime")
#define LUA_GET_EXIT_STORE_TIME ("getExitStoreTime")
#define LUA_GET_DURATION_STORE_TIME ("getDurationStoreTime")

#define LUA_REFRESH_ACVT_DIS_DATA_AND_VIEW ("refreshAcvtDisDataAndView")

#define LUA_GET_DATA_BY_METHOD ("getDataByMethod") 
#define LUA_GET_COL_MAX_VALUE_IN_TABLE ("getColMaxValueInTable")
#define LUA_COMPUTE_ROW_AND_COL_SUM ("computeRowAndColSum")

#define LUA_GET_STORE_ID ("getStoreId")

#define LUA_GET_STORE_INFO_BY_COD ("getStoreInfoByCod")

#define LUA_GET_STORE_LAT_LON ("getEnterStoreLatLon")

#define LUA_CALL_QST_WIDGET_METHOD_BY_QSTCODE_FUNCTION ("callQstWidgetMethodByQstCode")

#define LUA_SET_VALUE_TO_TARGET ("setValueToTarget")

#define LUA_CALL_GRID_METHOD_BY_ROWID_AND_COL ("callGridMethodByRowIdAndCol")

//根据某个问题的答案来决定其他几个问题是否有一个必填
#define LUA_CHECK_MUST_FILL_ONE ("checkMustFillOne")

#define LUA_CHECK_MUST_FILL_ANY_MODE ("checkMustFillAnyMode")

#define LUA_GET_TABLE_COL_VALUE_BY_PROD_ID  ("getTableColValueByProId")

#define LUA_SET_TABLE_COL_VALUE_BY_PROD_ID  ("setTableColValueByProId")
#define LUA_SET_TABLE_COL_BY_OTHER_TABLE_COL  ("setTableColByOtherTableCol")

#define LUA_GET_QST_SERVER_DATA_BY_QST_NAME_AND_GENID ("getQstServerDataByQstNameAndGenid") 
#define LUA_GET_QST_SERVER_DATA_BY_QST_CODE_AND_GENID ("getQstServerDataByQstCodeAndGenid")
#define LUA_GET_QST_DATA_BY_QST_CODE_AND_GENID ("getQstDataByQstCodeAndGenid") 

#define LUA_SET_COL_DEFAULT_VALUE_WITH_COL_NAME_AND_INDEX ("setColDefaultValueWithColNameAndIndex")

#define LUA_HANDLE_ACVT_METHOD ("handleAcvtMethod")

#define LUA_CALL_QST_WIDGET_METHOD_BY_QSTCODE_STARTS_FUNCTION ("callQstWidgetMethodByQstCodeStarts")

#define LUA_GET_CUR_STORE_IFNO_BY_PARAM ("getCurStoreInfoByParam")

#define LUA_RESET_MD5_BY_CUSTOM_DATE_STRING ("resetMd5ByCustomDateString")

#define LUA_SAVE_CUSTOM_ENTER_LEAVE_TIME ("saveCustomEnterLeaveTime")

#define LUA_GET_EMP_NAME ("getEmpName")

#define LUA_SET_ACVT_ENABLE_BY_QSTVALUE ("setAcvtEnbleByQstValue")

#define LUA_EXCESE_BLUE_TOOTH_PRINT ("exceseBlueToothPrint")

#endif /* WSLuaDefine_h */
