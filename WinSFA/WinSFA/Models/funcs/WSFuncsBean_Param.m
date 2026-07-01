//
//  FuncsBean_Param.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSFuncsBean_Param.h"
#import "WSAppData.h"

@implementation WSFuncsBean_Param

@synthesize col = _col;
@synthesize name = _name;
@synthesize tpy = _tpy;
@synthesize wcol = _wcol;
@synthesize max = _max;
@synthesize min = _min;
@synthesize pcs = _pcs;
@synthesize readonly = _readonly;
@synthesize redis = _redis;
@synthesize value = _value;
@synthesize listener = _listener;
@synthesize iSelectionItems = _iSelectionItems;
@synthesize iDefaultItemIndex = _iDefaultItemIndex;
@synthesize filter = _filter;
@synthesize isMutex = _isMutex;
@synthesize buttonname = _buttonname;
@synthesize isReq = _isReq;
@synthesize isfilled = _isfilled; // "R" must filled
@synthesize idefault = _idefault;
@synthesize ids = _ids;
@synthesize iDependon = _iDependon;
@synthesize hints = _hints;
@synthesize sort = _sort;
@synthesize isSupportEdit = _isSupportEdit;
@synthesize align = _align;
@synthesize AddEdit = _AddEdit;

- (id)initFuncs_ParamWithObject:(id)object
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
            NSDictionary *paramDictionary = (NSDictionary *)object;
            _charNum = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_CharNum]];
            if (!_charNum) {
                _charNum = @"0";
            }

            _col = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_COL]];
            _name = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_NAME]];
            _tpy = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_TPY]];
            _wcol = [[paramDictionary objectForKey:FUNCS_PARAM_WCOL] intValue];
            _max = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_MAX]];
            _min = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_MIN]];
            _pcs = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_PCS]];
            _readonly = [[paramDictionary objectForKey:FUNCS_PARAM_READONLY] intValue];
            _redis = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_REDIS]];
            _value = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_VALUE]];
            _listener = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_LISTENER]];
            _filter = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PRARM_FILTER]];
            _isMutex = [[paramDictionary objectForKey:FUNCS_PRARM_ISMUTEX] intValue];
            _buttonname = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_BUTTONNAME]];
            _isReq = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_ISREQ]];
            _answerColor = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_AnswerColor]];
            _valueSize = [NSString stringWithValue:[paramDictionary objectForKey:ACVT_QST_VALUE_SIZE]];

            // For single selection
            _iSelectionItems = [paramDictionary objectForKey:FUNS_PARAM_SLDS];
            _iDefaultItemIndex = [[paramDictionary objectForKey:FUNS_PARAM_SLDFINDEX] intValue];
            
            //Must filled column
            _isfilled = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_REQUIRED]];
            _idefault = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_DEFAULT]];
            _ids = [[NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_DS]] copy];
            _iDependon = [[NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_DEPENDON]] copy];
            _alert = [[NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_ALERT]] copy];
            
            _isSupperLocalPhoto = [[paramDictionary objectForKey:FUNCS_PRARM_ISSUPPERLOCALPHOTO] boolValue];
            _isSupportEdit = [[paramDictionary objectForKey:FUNCS_PRARM_ISSUPPORTEDIT] boolValue];

            _hints = [[NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PRARM_HINTS]] copy];
            _sort = [[paramDictionary objectForKey:FUNCS_PRARM_SORT] intValue];

            // add 2014-07-15
            _reg = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_REG]];
            
            _gone = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_GONE]];
//            NSString * gone = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_GONE]];
//            if (gone && [gone isEqualToString:@"1"]) {
//                _gone = YES;
//            }
            // add 2015-12-25
            _tip = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PARAM_TIP]];
            
            _isRealtime = [[paramDictionary objectForKey:FUNCS_PARAM_ISREALTIME] boolValue];
            
            _align = [[NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PRARM_ALIGN]] copy];
            
            _paramDescript = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PRARM_DESCRIPT]];
            
            _groupName = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PRARM_GROUPNAME]];
            
            _widthPercent = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PRARM_WIDTH_PERCENT]];
            
            _hideQstName = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PRARM_HIDE_QST_NAME]];
            
            _AddEdit = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PRARM_ADD_EDIT]];
            
            _needValidateMoreProdRedisValue = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PRARM_NEED_VALIDATE_MORE_PROD_REDIS_VALUE]];
            
            _parent = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PRARM_PARENT]];
            
            _isRedisNoMoreHome = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PRARM_REDIS_NO_MORE_HOME]];
            
            _isNotUploadEmpty = [[paramDictionary objectForKey:FUNCS_PRARM_ISNOTUPLOADEMPTY] boolValue];
            
            _coljumpinput = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PRARM_COLJUMPINPUT]];
            
            _ispopup = [NSString stringWithValue:[paramDictionary objectForKey:FUNCS_PRARM_ISPOPUP]];

        }
    }
    return self;
}

/*
 *  根据 col 的称名，找出在 prodspec 中的 index
 */
- (NSInteger)specIndex {
    NSArray *spec = [WSAppData getObjectbyKey:PRODSPEC];
    int index = 0;
    for (NSString *col in spec) {
        if ([col isEqualToString:self.col])
            return index;
        index++;
    }
    return -1;
}

- (id)initFuncsParamWithAcvtQstBean:(WSAcvtBean_qst *)acvtQstBean
{
    self = [super init];
    
    if (self) {
        _col = acvtQstBean.qstId;
        _name = acvtQstBean.qstName;
        _tpy = acvtQstBean.qstType;
        _wcol = 50;
        _readonly = [acvtQstBean.readonly integerValue];
        _isReq = acvtQstBean.is_req;
        _max = acvtQstBean.mnum;
        _min = acvtQstBean.snum;
        // 安卓用的是 mlen 表示照片的最大照片数   SFA 箭牌 WRIGLEY-1757
        if ([acvtQstBean.qstType isEqualToString:FUNCS_PARAM_typ_photo]) {
            _max = acvtQstBean.mlen;
        }
        _pcs = acvtQstBean.dlen;
        _idefault = acvtQstBean.defaultValue;
        _redis = @"1";
        _charNum = acvtQstBean.charNum;
        _answerColor = acvtQstBean.answerColor;
        _valueSize = acvtQstBean.valueSize;
        _filter = acvtQstBean.filter;
        _gone = acvtQstBean.isHidden;
        _mappingAcvtQstId = acvtQstBean.acvtQstId;
        _mappingAcvtQstDs = acvtQstBean.ds;
        _isHidden = acvtQstBean.isHidden;
        _hints = acvtQstBean.hint;
        _parent = acvtQstBean.parent;
        _iDependon = acvtQstBean.dependon;
        return self;
    }
    
    return nil;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    WSFuncsBean_Param *param = [[[self class] alloc] init];
    param.charNum = [self.charNum copy];
    param.answerColor = [self.answerColor copy];
    param.valueSize = [self.valueSize copy];
    param.col = [self.col copy];
    param.name = [self.name copy];
    param.tpy = [self.tpy copy];
    param.wcol = self.wcol;
    param.max = [self.max copy];
    param.min = [self.min copy];
    param.pcs = [self.pcs copy];
    param.readonly = self.readonly;
    param.redis = [self.redis copy];
    param.value = [self.value copy];
    param.listener = [self.listener copy];
    param.filter = [self.filter copy];
    param.isMutex = self.isMutex;
    param.buttonname = [self.buttonname copy];
    param.isReq = [self.isReq copy];
    param.iSelectionItems = [self.iSelectionItems copy];
    param.iDefaultItemIndex = self.iDefaultItemIndex;
    param.isfilled = [self.isfilled copy];
    param.idefault = [self.idefault copy];
    param.isSupperLocalPhoto = self.isSupperLocalPhoto;
    param.isSupportEdit = self.isSupportEdit;
    param.hints = [self.hints copy];
    param.sort = self.sort;
    param.isRealtime = self.isRealtime;
    param.ids = [self.ids copy];
    param.iDependon = [self.iDependon copy];
    param.mappingAcvtQstDs = [self.mappingAcvtQstDs copy];
    param.alert = [self.alert copy];
    param.reg = [self.reg copy];
    param.gone = self.gone;
    param.tip = [self.tip copy];
    param.mappingAcvtQstId = [self.mappingAcvtQstId copy];
    param.isHidden = [self.isHidden copy];
    param.align = [self.align copy];
    param.paramDescript = [self.paramDescript copy];
    param.groupName = [self.groupName copy];
    param.widthPercent = [self.widthPercent copy];
    param.hideQstName = [self.hideQstName copy];
    param.AddEdit = [self.AddEdit copy];
    param.needValidateMoreProdRedisValue = [self.needValidateMoreProdRedisValue copy];
    param.parent = [self.parent copy];
    param.isRedisNoMoreHome = [self.isRedisNoMoreHome copy];
    param.coljumpinput = [self.coljumpinput copy];
    param.ispopup = [self.ispopup copy];
    
    return param;
}


@end
