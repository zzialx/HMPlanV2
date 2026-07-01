//
//  FuncsBean_opt.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSFuncsBean_opt.h"

@implementation WSFuncsBean_opt
@synthesize isPic = _isPic;
@synthesize isGps = _isGps;
@synthesize typGps = _typGps;
@synthesize isMemo = _isMemo;
@synthesize numMemo = _numMemo;
@synthesize label = _label;
@synthesize isCode = _isCode;
@synthesize isMore = _isMore;
@synthesize isScan = _isScan;
@synthesize isSeq = _isSeq;
@synthesize title = _title;
@synthesize name = _name;
@synthesize isAdd = _isAdd;
@synthesize isRedisMoreHome = _isRedisMoreHome;
@synthesize isAttendance = _isAttendance;
@synthesize isIntentToStore = _isIntentToStore;
@synthesize isSupperLocalPhoto = _isSupperLocalPhoto;
@synthesize maxPhoto = _maxPhoto;
@synthesize isOpenGeo = _isOpenGeo;
@synthesize isSearchable = _isSearchable;
@synthesize storeFiletr = _storeFiletr;
@synthesize searchTag = _searchTag;
@synthesize serverCount = _serverCount;
@synthesize searchTagAlert = _searchTagAlert;
@synthesize showStyle = _showStyle;
@synthesize filterStyle = _filterStyle;
@synthesize isHiddenFilledOutStatusImageView = _isHiddenFilledOutStatusImageView;
@synthesize leaveModify = _leaveModify;
@synthesize nextAcvtNode = _nextAcvtNode;
@synthesize prodtree_checked_name = _prodtree_checked_name;
@synthesize isNeedShowStoreName = _isNeedShowStoreName;


- (id)initFuncs_optWithObject:(id)object
{
    if (nil == object)
    {
        return nil;
    }
    
    self = [super init];
    if (self)
    {
        if ([object isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *optDictionary = (NSDictionary *)object;
            _filterStyle = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_filterStyle]];
            _showStyle = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_showStyle]];
            _isPic = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_isPic]];
            _isGps = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_isGps]];
            _automaticDeparture = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_automaticDeparture]];
            _typGps = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_typGps]];
            _isMemo = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_isMemo]];
            _numMemo = [[optDictionary objectForKey:FUNCS_OPT_numMemo] intValue];
            _label = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_label]];
            _isCode = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_isCode]];
            _isMore = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_isMore]];
            
            // 兼容如果后台下发值是Y和N的情况
            if ([[NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_isScan]] isEqualToString:@"Y"]){
                _isScan = [NSString stringWithValue:@1];
            }else if ([[NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_isScan]] isEqualToString:@"N"]){
                _isScan = [NSString stringWithValue:@0];
            }else
                _isScan = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_isScan]];
            
            _isSeq = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_isSeq]];
            _title = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_title]];
            _name = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_name]];
            _isAdd = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_isAdd]];
            _isAttendance = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_isAttendance]];
            _isIntentToStore = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_isIntentToStore]];
            _isRedisMoreHome = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_isRedisMoreHome]];
            _isOpenGeo = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IsOpenGeo]];
            _searchTag = [NSString stringNotNilWithValue:[optDictionary objectForKey:FUNCS_OPT_SearchTag]];
            _isSearchable = [NSString stringNotNilWithValue:[optDictionary objectForKey:FUNCS_OPT_IsSearchable]];
            _storeFiletr = [NSString stringNotNilWithValue:[optDictionary objectForKey:FUNCS_OPT_StoreFiletr]];

            _SMS = [NSString stringNotNilWithValue:[optDictionary objectForKey:FUNCS_OPT_SMS]];
            _searchSource = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_SPEC_SEARCH_SOURCE]];
            _needSelect = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_NEEDSELECT]];
            _isUseNewId = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_ISUSENEWID]];
            _isShowActionTip = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_ISSHOWACTIONTIP]];
            _serverCount = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_SERVERCOUNT]];
            _searchTagAlert = [NSString stringWithValue:[optDictionary objectForKey: FUNCS_OPT_SEARCH_TAG_ALERT]];
            
            _showdetails = [NSString stringWithValue:[optDictionary objectForKey: FUNCS_OPT_SHOW_DETAILS]];
            
            _isShortCut = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_ISSHORTCUT]];
            
            _visitedFlag = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_VISITEDFLAG]];
            
            _searchHint = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_SEARCH_HINT]];
            
            _searchQuestion = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_SEARCH_QUESTION]];
            
            _acvtSearch = [NSString stringNotNilWithValue:optDictionary[FUNCS_OPT_ACVT_SEARCH]];
            
            _autoJumpNext = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_AUTO_JUMP_NEXT]];
            
            _autoAddMore = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_AUTO_Add_MORE]];

            _deleteButton = [NSString stringWithValue:optDictionary[FUNCS_OPT_DELETE_BUTTON]];
            
            _isOpenSubTrackMap = [[NSString stringWithValue:optDictionary[FUNCS_OPT_IS_OPEN_SUB_TRACKMAP]] boolValue];
            
            _addType = [NSString stringWithValue:optDictionary[FUNCS_OPT_ADD_TYPE]];
            _naviDis = [NSString stringWithValue:optDictionary[FUNCS_OPT_NAVDIS_VISIBLE]];
            if (_naviDis == nil) {
                _naviDis = [NSString stringWithValue:optDictionary[FUNCS_OPT_LOWER_NAVDIS_VISIBLE]];
            }

            _rn_iosv = [NSString stringWithValue:optDictionary[FUNCS_OPT_RN_IOSV]];
            _rn_formcode = [NSString stringWithValue:optDictionary[FUNCS_OPT_RN_FORMCODE]];
            _rn_androidv = [NSString stringWithValue:optDictionary[FUNCS_OPT_RN_ANDROIDV]];
            _rn_url = [NSString stringWithValue:optDictionary[FUNCS_OPT_RN_URL]];
            _rn_rptcode = [NSString stringWithValue:optDictionary[FUNCS_OPT_RN_RPTCODE]];
            _isChat = [NSString stringWithValue:optDictionary[FUNCS_OPT_CHAT_VISIBLE]];
            
            
            _acvtSort = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_ACVT_SORT]];
            
            _tagBottom = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_ACVT_TAGBOTTOM]];

            
            
            _contextMenu = [NSString stringWithValue:optDictionary[FUNCS_OPT_CONTEXT_MENU]];
            _isTipsMenu = [NSString stringWithValue:optDictionary[FUNCS_OPT_IS_TIPS_MENU]];
            _distancesSort = [NSString stringWithValue:optDictionary[FUNCS_OPT_DISTANCES_SORT]];
            _visitTimeSort = [NSString stringWithValue:optDictionary[FUNCS_OPT_VISIT_TIME_SORT]];
            _downByMap = [NSString stringWithValue:optDictionary[FUNCS_OPT_DOWN_BY_MAP]];

            _isCountry = [NSString stringWithValue:optDictionary[FUNCS_OPT_IS_COUNTRY]];

            _refreshNodeName = [NSString stringWithValue:optDictionary[FUNCS_OPT_REFRESH_NODE_NAME]];
            
            
            _isOnlySub = [NSString stringWithValue:optDictionary[FUNCS_OPT_IS_ONLYSUB]];
            
            _isRefresh = [NSString stringWithValue:optDictionary[FUNCS_OPT_isRefresh]];
            
            _sendRequest = [NSString stringWithValue:optDictionary[FUNCS_OPT_SENDREQUEST]];
            
            _isJumpCallPlan = [NSString stringWithValue:optDictionary[FUNCS_OPT_ISJUMPCALLPLAN]];
            
            _updateMenu = [NSString stringWithValue:optDictionary[FUNCS_OPT_UPDATEMENU]];
            _unreadNumFlag = [NSString stringWithValue:optDictionary[FUNCS_OPT_UNREADNUMFLAG]];

            
            //所有门店页面右上角地图按钮显示控制开关 默认显示不需要配置，isMap为N时，关闭不显示
            //SFA-23933
            if ([[NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_ISMAP]] isEqualToString:@"Y"] || [[NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_ISMAP]] isEqualToString:@"1"]) {
                
                _isMap = YES;
            }else{
                
                _isMap = NO;
            }
            _parentStoreFc = [NSString stringWithValue:optDictionary[FUNCS_OPT_PARENT_STORE_FC]];

            
             //sanofi 新增 isShowUpdated 回显只读数据；removeDay 不显示全天
            if ([[NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_REMOVEDAY]] isEqualToString:@"Y"]){
                _removeDay = YES;
            }else{
                _removeDay = NO;
            }
            
            if ([[NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_ISSHOWUPDATED]] isEqualToString:@"Y"]){
                _isShowUpdated = YES;
            }else{
                _isShowUpdated = NO;
            }
           
            id tmp = [optDictionary objectForKey:FUNCS_OPT_isSupperLocalPhoto];
            if (tmp && ![tmp isKindOfClass:[NSNull class]]) {
                _isSupperLocalPhoto = [tmp intValue];
            }else {
                _isSupperLocalPhoto = 0;
            }
            
            tmp = [optDictionary objectForKey:FUNCS_OPT_maxPhoto];
            if (tmp && ![tmp isKindOfClass:[NSNull class]]) {
                _maxPhoto = [tmp intValue];
            }else {
                _maxPhoto = 0;
            }
            
            tmp = [optDictionary objectForKey:FUNCS_OPT_ISRETURNHOME];
            if (tmp && [tmp isKindOfClass:[NSString class]]) {
                self.isReturnHome = tmp;
            }else {
                self.isReturnHome = @"1";
            }
            
            if ([[NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_isRead]] isEqualToString:@"1"]) {
                _isRead = YES ;
            }
            else{
                
                _isRead = NO;
            }
            if ([[NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_USE_PARENT_FUNC]] isEqualToString:@"1"]) {
                
                _isUseParentFunc = YES;
            }else{
                
                _isUseParentFunc = NO;
            }
            if ([[NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_Today_Visist]] isEqualToString:@"1"]) {
                
                _isTodayVisit = YES;
            }else{
                
                _isTodayVisit = NO;
            }
            
            if ([[NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_HIDE_TITLE]] isEqualToString:@"1"]) {
                _isHideTitle = YES;
            } else {
                _isHideTitle = NO;
            }
            
            _isExhibitionNavTitle = (([[NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_EXHIBITION_NAV_TITLE]] isEqualToString:@"Y"]) ? YES : NO);

            if ([[NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_QST_NAME]] isEqualToString:@"1"]) {
                _isQstName = YES;
            } else {
                _isQstName = NO;
            }
            
            if ([[NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_SHOW_FOOT_NAV]] isEqualToString:@"0"]) {
                _isShowFootNavigate = NO;
            } else {
                _isShowFootNavigate = YES;
            }
            
            _hidePlanOrbit = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_HIDE_PLAN_OR_BIT]];
            if ([optDictionary objectForKey:FUNCS_OPT_SELECTDATE]) {
                NSString *slectDate = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_SELECTDATE]];
                NSDictionary *selectDict = [slectDate objectFromJSONString];
                _minWeek = [NSString stringWithValue: [selectDict objectForKey:FUNCS_OPT_SELECTDATE_MINWEEK]];
                _maxWeek = [NSString stringWithValue:[selectDict objectForKey:FUNCS_OPT_SELECTDATE_MMXWEEK]];
            }
            
            _hideCount = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_HIDE_COUNT]];
            
            _prodtrees = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_PROD_TREES]];

            _mapIconType = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_MAP_ICON_TYPE]];
            
            _jumpToInput = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_JUMP_TO_INPUT]];
        
            _searchCondReqNode = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_SEARCH_COND_REQ_NODE]];
            _menuBgColor = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_MENU_BG_COLOR]];
            _gpsCityLevel = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_GPS_CITY_LEVEL]];
            
            _appendprop = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_APPENDPROP]];
            
            _hNewStyleProdSelect = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_NEW_STYLE_PROD_SELECT]];
        
            _isShowAlreadyFilledStatus = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_SHOW_ALREADY_FILLED_STATUS]];

            _isAcvtListCanDelete = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_ACVTLIST_CAN_DELETE]];
            _storeListAcvtCode = [NSString stringWithValue:[optDictionary objectForKey:@"storeListAcvtCode"]];
            
            _leaveStoreTip = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_LEAVESTORE_TIP]];
            
            _isSaveData_back = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_SAVE_DATA_BACK]];
            
            _uploadInTheFollowing = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_UPLOAD_IN_THE_FOLLOWING]];

            _isAddProductStyle = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_ADD_PRODUCT_STYLE]];
            _isCollectionStyle = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_COLECTION_STYLE]];

            
            _followStore = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_FOLLOW_STORE]];
            _showSub = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_SHOW_SUB]];

            _isHiddenFilledOutStatusImageView = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_Hidden_FilledOutStatusImageView]];
            
            _addFilterType = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_ADD_FILTER_TYPE]];
            _isShowSubArea = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_SHOW_SUBAREA]];
            _acvtVisitStatus = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_ACVT_VISIT_STATUS]];
            _cusMailList = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_CUS_MAIL_LIST]];
            
            _leaveModify = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_LEAVE_MODIFY]];
            
            _listStyleShowColNum = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_LIST_STYLE_SHOW_COL_NUM]];
            
            _batchUpload = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_BATCH_UPLOAD]];
            
            _uploadStyle = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_UPLOAD_STYLE]];
            
            if ([(NSString *)[optDictionary objectForKey:FUNCS_OPT_IS_CURRENT_GEO] isEqualToString:@"Y"]) {
                _isCurrentGeo = YES;
            }
            
            _hiddenCode = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_HIDDEN_CODE]]; //隐藏编码 SFA-19954
            
            
            _isSetFocus = NO;
            if ([[NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_SET_FOCUS]] isEqualToString:@"1"]) {
                _isSetFocus = YES;
            }
            
            _loginUrl = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_LOGIN_URL]];
            _password = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_PASS_WORD]];
            _passwordEncrypt = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_PASS_WORD_ENCRYPT]];
            _username = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_USER_NAME]];
            
            _moreProdType = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_MORE_PROD_TYPE]];
            _refresh = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_REFRESH]];
            _backDialog_tip = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_BACK_DIALOG_TIP]];
            _uploadDialog_tip = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_UPLOADDIALOG_TIP]];
            _notReqCheck_tip = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_NOT_REQ_CHECK_TIP]];
            _nextAcvtNode = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_NEXT_ACVT_NODE]];
            
            _isUploadCheckReplace = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_UPLOAD_CHECK_REPLACE]];
            _downloadInfoNum = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_DOWNLOAD_INFO_NUM]];
            _leaveStoreTipFunc = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_LEAVESTORE_TIPFUNC]];
            _requestTimeout = [[NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_REQUEST_TIMEOUT]] integerValue];
            
            _isUpdateStoreIcon = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_Is_Update_Store_Icon]];
            _needRepeatProd = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_NEED_REPEATE_PROD]];
            
            _checkCallingStore = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_CHECK_CALLING_STORE]];
            _leaveTipFlag = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_LEAVE_TIP_FLAG]];
            
            _isVisitCompleteModuleReadonlyTip = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_VISIT_COMPLETE_MODULE_READONLY_TIP]];
            _prodtree_checked_name = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_PRODTREE_CHECKED_NAME]];
            _isNeedShowStoreName = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_NEED_SHOW_STORENAME]];
           
            _subTitleBgColor = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_SUB_TITLE_BG_COLOR]];
            _remoteOrderProductInfo = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_REMOTE_ORDER_PRODUCT_INFO]];

            _customFormatImgName = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_CUSTOM_FORMAT_IMG_NAME]];
            
            _isCancelSearchCode = NO;
            if ([(NSString *)[optDictionary objectForKey:FUNCS_OPT_CANCEL_SEARCH_CODE] isEqualToString:@"Y"]) {
                _isCancelSearchCode = YES;
            }
            _isBranchStoreDownload = NO;
            if ([[NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_BRANCH_STORE_DOWNLOAD]] isEqualToString:@"1"]) {
                _isBranchStoreDownload = YES;
            }
            
            _isNeedBack = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_NEED_BACK]];
            
            _imgCompress = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IMG_COMPRESS]];
            _imgShootWidth = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_SHOOT_WIDTH]];
            _imgCompress_iOS = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IMG_COMPRESS_IOS]];
            _imgShootWidth_iOS = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_SHOOT_WIDTH_IOS]];
            _isSrid = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_SRID]];
            _isSingleQstToAutoJump = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_SINGLE_QST_TO_AUTOJUMP]];
            _isCheckEnterStore = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_CHECK_ENTER_STORE]];
            _isCheckPushView = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_CHECK_PUSH_VIEW]];
            
            _isCurrEmpId =  [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_CHECK_PUSH_VIEW]];
            _resourceForm =  [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_REMOTE_RESOURCEFORM]];
            _showReqTips = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_SHOWTIPS]];
            _routeVisitFC = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_ROUYEVISITFC]];
            _independentShowSub = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_INDEPENDENT_SHOW_SUB]];
            _jumpUrlLink = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_JUMP_URL_LINK]];
            _routeSearchurl = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_SEARCHROUTE_URL]];
            _visitMax = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_VISIT_MAX]];
            _jumpStoreInfoUrl = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_STOREINOF_URL]];
            _webBackUpdateJS = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_WEB_BACK_UPDATE_JS]];
            _saveNode = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_SAVENODE]];
            _mOrderByDis = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_MORDERDIS]];
            
            _isReminderVisit = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_REMINDER_VISIT]];
            _isReminderOperate = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_REMINDER_OPERATE]];
            _jumpPrivacyAgreement = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_JUMPPRIVACYAGREEMENT]];
            
            _addRouteUrl = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_ADDROUTE]];
            _batchModifyUrl = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_BATCH_UPDATE_ROUTE]];
            
            _salesAssistanceMenu = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_HELP_SALES]];
            _isUseNewPage = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_ISUSERNEW_PAGE]];
            _isBackgroundCache = [NSString stringWithValue:[optDictionary objectForKey:FUNCS_OPT_IS_BACKGROUND_CACHE]];
            _suggestOrderNode = [NSString stringWithValue:[optDictionary objectForKey:FUNC_OPT_SUGGEST_ORDER_NODE]];
            _isHiddenBack = [NSString stringWithValue:[optDictionary objectForKey:FUNC_OPT_ISHIDDEN_BACK]];
            _funcTipType = [NSString stringWithValue:[optDictionary objectForKey:FUNC_OPT_FUNCTIP_TYPE]];
        }
    }
    return self;

}

@end
