//
//  AcvtBean_qst.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSAcvtBean_qst.h"
#import "WSAcvtBean_qst_opt.h"
#import "NSDictionary+Additional.h"
#import  "I_W_BuildInfo.h"
#import "WSStoreBean.h"
#import "WSDownloadFileTable.h"
#import "WSAppData.h"
#import "IAttachment.h"


@implementation WSAcvtBean_qst

@synthesize dlen = _dlen;
@synthesize mlen = _mlen;
@synthesize opt = _opt;
@synthesize mnum = _mnum;
@synthesize qstDesc = _qstDesc;
@synthesize qstId = _qstId;
@synthesize acvtQstId = _acvtQstId;
@synthesize qstCod = _qstCod;
@synthesize qstName = _qstName;
@synthesize qstType = _qstType;
@synthesize snum = _snum;
@synthesize is_req = _is_req;
@synthesize mc = _mc;
@synthesize range = _range;
@synthesize func = _func;
@synthesize dds = _dds;
@synthesize filter = _filter;
@synthesize groupName = _groupName;
@synthesize parent = _parent;
@synthesize defaultValue = _defaultValue;
@synthesize ds = _ds;
@synthesize isAcvtName = _isAcvtName;
@synthesize isSupperLocalPhoto = _isSupperLocalPhoto;
@synthesize maxPhoto = _maxPhoto;
@synthesize parentQstId = _parentQstId;
@synthesize script = _script;
@synthesize posAndFrame;
@synthesize attachment;
@synthesize colKey = _colKey;
@synthesize isNoInset = _isNoInset;
@synthesize dependon = _dependon;


#pragma mark - class init & dealloc

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithObject:(id)object
{
    if (nil == object) {
        return nil;
    }
    
    self = [super init];
    
    if (self) 
    {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)object;
            _is_req = [NSString stringWithValue: [dic objectForKey:ACVT_QST_ISREQ]];
            _dlen = [NSString stringWithValue: [dic objectForKey:ACVT_DLEN]];
            _mlen = [NSString stringWithValue: [dic objectForKey:ACVT_MLEN]];
            _mnum = [NSString stringWithValue: [dic objectForKey:ACVT_MNUM]];
            _qstDesc = [NSString stringWithValue:[dic objectForKey:ACVT_QSTDESC]];
            _qstId = [NSString stringWithValue:[dic objectForKey:ACVT_QSTID]];
            _acvtQstId = [NSString stringWithValue:[dic objectForKey:ACVT_ACVTQSTID]];
            _qstCod = [NSString stringWithValue:[dic objectForKey:ACVT_QSTCOD]];
            _qstName = [NSString stringWithValue:[dic objectForKey:ACVT_QSTNAME]];
            _qstType = [NSString stringWithValue:[dic objectForKey:ACVT_QSTTYPE]];
            _snum = [NSString stringWithValue: [dic objectForKey:ACVT_SNUM]];
            _align = [NSString stringWithValue:[dic objectForKey:ACVT_ALIGN]];
            NSArray *optarray = [dic objectForKey:ACVT_OPT];
            _opt = [[NSMutableArray alloc]
                   initWithCapacity:[optarray count]];
            
            id tmp = [dic objectForKey:ACVT_QST_isSupperLocalPhoto];
            if (tmp && ![tmp isKindOfClass:[NSNull class]]) {
                _isSupperLocalPhoto = [tmp intValue];
            }else {
                _isSupperLocalPhoto = 0;
            }
            
            tmp = [dic objectForKey:ACVT_QST_maxPhoto];
            if (tmp && ![tmp isKindOfClass:[NSNull class]]) {
                _maxPhoto = [tmp intValue];
            }else {
                _maxPhoto = 0;
            }
            
            _isHidden = [NSString stringWithValue:[dic objectForKey:ACVT_QST_ISHIDDEN]];
            
            _mc = [NSString stringWithValue: [dic objectForKey:ACVT_MC]];
            _range = [NSString stringWithValue: [dic objectForKey:ACVT_RANGE]];
            _func = [NSString stringWithValue: [dic objectForKey:ACVT_FUNC]];
            _dds = [NSString stringWithValue: [dic objectForKey:ACVT_DDS]];
            
            _range2 = [NSString stringWithValue: [dic objectForKey:ACVT_RANGE2]];
            _func2 = [NSString stringWithValue: [dic objectForKey:ACVT_FUNC2]];
            _dds2 = [NSString stringWithValue: [dic objectForKey:ACVT_DDS2]];
            
            _filter = [NSString stringWithValue: [dic objectForKey:ACVT_FILTER]];
            _checkType = [dic getStringValueWithKeyName:ACVT_CHECKTYPE];
            _readonly = [NSString stringWithValue:[dic objectForKey:ACVT_READONLY]];
            _groupName = [NSString stringWithValue:[dic objectForKey:ACVT_GROUPNAME]];
            _parent = [NSString stringWithValue:[dic objectForKey:ACVT_PARENT]];
            
            _alertTitle =[NSString stringWithValue: [dic objectForKey:ACVT_QST_AlertTitle]];
            _memo = [NSString stringWithValue:[dic objectForKey:ACVT_QST_MEMO]];
            _memo1 = [NSString stringWithValue:[dic objectForKey:ACVT_QST_MEMO1]];
            _memo2 = [NSString stringWithValue:[dic objectForKey:ACVT_QST_MEMO2]];
            _memo3 = [NSString stringWithValue:[dic objectForKey:ACVT_QST_MEMO3]];
            _memo4 = [NSString stringWithValue:[dic objectForKey:ACVT_QST_MEMO4]];
            
            _charNum = [NSString stringNotNilWithValue:[dic objectForKey:ACVT_QST_CHARNUM]];
            
            _is_not_water_mark = [NSString stringNotNilWithValue:[dic objectForKey:ACVT_QST_IS_NOT_WATER_MARK]];
            
            tmp = [dic objectForKey:ACVT_PARENT_QST_ID];
            if (tmp && ![tmp isKindOfClass:[NSNull class]]) {
                _parentQstId = [NSString stringWithValue:tmp];
            }else {
                _parentQstId = nil;
            }
            
            _defaultValue = [NSString stringWithValue:[dic objectForKey:QST_DEFAULTVALUE]];
            
            _ds = [NSString stringWithValue:[dic objectForKey:ACVT_ACVTDS]];
            
            if ([dic objectForKey:IS_ACVT_NAME] && ![[dic objectForKey:IS_ACVT_NAME] isKindOfClass:[NSNull class]]) {
                _isAcvtName = [NSString stringWithValue:[dic objectForKey:IS_ACVT_NAME]];
            }else {
                _isAcvtName = @"0";
            }
            
            _acvtNestedId = [NSString stringWithValue:[dic objectForKey:ACVT_ACVTNESTEDID]];
            _color = [NSString stringWithValue:[dic objectForKey:ACVT_COLOR]];
            _bgColor = [NSString stringWithValue:[dic objectForKey:ACVT_BGCOLOR]];
            
            for (int i = 0; i < [optarray count]; i++) {
                WSAcvtBean_qst_opt *subopt = [[WSAcvtBean_qst_opt alloc]
                                   initWithObject:[optarray objectAtIndex:i]];
                
                [_opt insertObject:subopt atIndex:i];
            }
            _script = [NSString stringWithValue:[dic objectForKey:ACVT_QST_SCRIPT]];
            if ([self hasObject:dic Key:ACVT_QST_JS]) {
                _script = [NSString stringWithValue:[dic objectForKey:ACVT_QST_JS]];
            }
            _orientation = [NSString stringWithValue:[dic objectForKey:ACVT_QST_ORIENTATION]];
            _hint = [NSString stringWithValue:[dic objectForKey:ACVT_QST_HINT]];
            _qstIconUrl = [NSString stringWithValue:[dic objectForKey:ACVT_QST_ICONURL]];
            _countrule = [NSString stringWithValue:[dic objectForKey:ACVT_QST_COUNTRULE]];
            _tab = [NSString stringWithValue:[dic objectForKey:ACVT_QST_TAB]];
            _hideQstName = [NSString stringWithValue:[dic objectForKey:ACVT_QST_HIDEQSTNAME]];
            _hideQstOptName = [NSString stringWithValue:[dic objectForKey:ACVT_QST_HIDEQSTOPTNAME]];
            _reg = [NSString stringWithValue:[dic objectForKey:ACVT_QST_REG]];
            _displayMode = [NSString stringWithValue:[dic objectForKey:ACVT_QST_DISPLAYMODE]];
            _hiddenBottomline = [NSString stringWithValue:[dic objectForKey:ACVT_QST_HIDE_BOTTOM_LINE]];
            _widthPercent = [NSString stringWithValue:[dic objectForKey:ACVT_QST_WIDTH_PERCENT]];
            _isCoverNewId = [NSString stringWithValue:[dic objectForKey:ACVT_QST_IS_COVER_NEW_ID]];
            
            _locationType = [NSString stringWithValue:[dic objectForKey:ACVT_QST_LOCATION_TYPE]];
            _colKey = [NSString stringWithValue:[dic objectForKey:ACVT_QST_colKey]];
            _verticalGroupName = [NSString stringWithValue:[dic objectForKey:ACVT_QST_VERTICAL_GROUP_NAME]];
            _layout_gravity = [NSString stringWithValue:[dic objectForKey:ACVT_QST_LAYOUT_GRAVITY]];
            _titleReadColor = [NSString stringWithValue:[dic objectForKey:ACVT_QST_TITLE_READ_COLOR]];
            _valueReadColor = [NSString stringWithValue:[dic objectForKey:ACVT_QST_VALUE_READ_COLOR]];
            _valueColor = [NSString stringWithValue:[dic objectForKey:ACVT_QST_VALUE_COLOR]];
            _titleSize = [NSString stringWithValue:[dic objectForKey:ACVT_QST_TITLE_SIZE]];
            _valueSize = [NSString stringWithValue:[dic objectForKey:ACVT_QST_VALUE_SIZE]];
            _dependon = [NSString stringWithValue:[dic objectForKey:ACVT_QST_DEPENDON]];

        };
        return self;
    }
    
    return nil;
}

- (id)initAcvtQstWithFuncsParam:(WSFuncsBean_Param *)funcsBeanParam withAcvtId:(NSString *)acvtId{

    self = [super init];
    if (self) {
        _qstId = funcsBeanParam.col;
        _qstName = funcsBeanParam.name;
        _qstType = funcsBeanParam.tpy;
        _orientation = @"1";
        if ([_qstType isEqualToString:COL_TYPDT]) {
            _qstType = QST_TYPE_DV;
        }
        if ([_qstType isEqualToString:COL_TYPCHT] || [_qstType isEqualToString:COL_TYPCHTS]) {
            _qstType = QST_TYPE_T;
        }
        _orientation = @"1";
        _readonly =  [NSString stringWithFormat:@"%ld",funcsBeanParam.readonly];
        _is_req = funcsBeanParam.isReq;
        _mnum = funcsBeanParam.max;
        _snum = funcsBeanParam.min;
        _mlen = funcsBeanParam.max;
        _dlen = funcsBeanParam.pcs;
        _defaultValue = funcsBeanParam.idefault;
        _charNum = funcsBeanParam.charNum;
        _answerColor = funcsBeanParam.answerColor;
        _valueSize = funcsBeanParam.valueSize;
        _dependon = funcsBeanParam.iDependon;

        _filter = funcsBeanParam.filter;
        _acvtQstId = funcsBeanParam.col;
        _qstCod = [NSString stringWithFormat:@"%@",funcsBeanParam.col];
//        NSLog(@"qstName = %@ ---- qstCode = %@ --- isHidden = %@ -- qstType = %@",funcsBeanParam.name,funcsBeanParam.col,_isHidden,_qstType);
        _ds = funcsBeanParam.ids;
        _hint = funcsBeanParam.hints;
        _script = funcsBeanParam.value;
        _groupName = funcsBeanParam.groupName;
        _hideQstName = funcsBeanParam.hideQstName;
        _widthPercent = funcsBeanParam.widthPercent;
        if (![funcsBeanParam.gone isEqualToString:@"0"] && funcsBeanParam.gone.length > 0) {
            _isHidden = @"1";
        }else{
            _isHidden = @"0";
        }
        //_isHidden = [NSString stringWithFormat:@"%d", funcsBeanParam.gone];
        // MSTD-6627 跟安卓一致，为蒙牛项目定制，没有配置只要是数字类型且没有小数点则是加减号模式
        if ([_qstType isEqualToString:COL_TYPNUM]) {
            _displayMode = kDisplayModeAddSub;
        }
        return self;
    }
    return nil;
}

-(BOOL)hasObject:(id)dic Key:(NSString*)key
{
    if([dic objectForKey:key]!= nil&&
       ![[dic objectForKey:key] isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    return NO;
}

- (NSMutableArray *)opt {
    if (_opt == nil) {
        _opt = [[NSMutableArray alloc]init];
    }
    return _opt;
}

#pragma mark -
#pragma mark I_W_BuildInfo method

-(NSString *)getWidgetId{
    
    return self.qstType;
    
}

-(void)setLayOutInfo:(CGRect)rect{
    
    self.posAndFrame = rect;
}

-(CGRect)getLayOutInfo{
    
    return self.posAndFrame;
}

-(NSString *)getQuestName{
    
    return self.qstName;
    
}

-(NSString *)getISRequire{
    
    return self.is_req;
}

-(NSString *)getAcvtQstId{
    
    return self.acvtQstId;
    
}

- (NSString*)getAcvtQstType {
    return self.qstType;
}

- (NSString *)getQstId {
    return self.qstId;
}


-(NSString *)getReadOnly{
    
    return self.readonly;
}

-(NSString *)getTextColor{
    
    return self.color;
    
}

-(NSString *)getAnswerColor{
    
    return self.answerColor;
}

- (NSString *)getBgColor {
    return self.bgColor;
}

-(NSString *)getDataSource{
    
    return self.ds;
}

-(NSString *)getFilterCondition{
    
    return self.filter;
}

- (void)setFilterCondition:(NSString *)filter {
    self.filter = filter;
}

-(NSMutableArray *)getAnswerOpt{
    
    return self.opt;
}

-(NSString *)getDefaultValue{
    
    return self.defaultValue;
    
}

- (void)setDefaultValue:(NSString *)defaultValue {
    _defaultValue = defaultValue;
}

-(NSString *)getSnumx{
    
    return self.snum;
}

- (void)setSnumx:(NSString *)snumx {
    
    self.snum = snumx;
}

-(NSString *)getMumx{
    
    return self.mnum;
}

- (void)setMumx:(NSString *)mumx {
    
    self.mnum = mumx;
}

-(NSString *)getMlen{
    
    return self.mlen;
}

-(NSString *)getDlen{
    
    return self.dlen;
}

- (NSArray *)getOptArray
{
    return self.opt;
}

- (NSString *)getLuaScript
{
    return self.script;
}

- (NSString *)getMenuCode
{
    return self.mc;
}
//- (void)setLuaScript:(NSString *)script
//{
//    self.script = script;
//}
-(NSString *)getOrientation
{
    return self.orientation;
}

-(void)setIsRequire:(NSString *)isquire{
    
    self.is_req = isquire;
    
}

- (NSInteger)isSupperLocalPhotoForXB
{

    return self.isSupperLocalPhoto;
}

- (NSInteger) getMaxPhoto
{

    return self.maxPhoto;
}

-(NSString *)getAcvtNestId{
    
    return self.acvtNestedId;
    
}

-(NSString *)getQuestPos{
    
    return self.isAcvtName;
}


- (NSString *)getAcvtMemo {
    return  self.memo;
}

- (NSString *)getAcvtMemo1 {
    return self.memo1;
}

- (NSString *)getAcvtMemo2 {
    return self.memo2;
}

- (NSString *)getAcvtMemo3 {
    return self.memo3;
}

- (NSString *)getAcvtMemo4 {
    return self.memo4;
}



-(NSObject<IAttachment> *)getMediaInfo{
    
    
    return  attachment;
}

-(void)setI_Media_Info:(NSObject<IAttachment> *)attachmentin{
    
    attachment = attachmentin;
    
}

- (void)setIsReadOnly:(NSString *)readonly
{
    self.readonly = readonly;
}

- (NSString *)getIsHidden
{
    return _isHidden;
}

- (void)setIsHidden:(NSString *)hidden
{
    _isHidden = hidden;
}

- (NSString *)getNeedUploadData
{
    return _needUploadData;
}

- (void)needUploadData:(NSString *)needUploadData
{
    _needUploadData = needUploadData;
}

- (void)setLuaScript:(NSString *)luaScript
{
    _script = luaScript;
}

- (NSString *)getQstDescription
{
    return self.qstDesc;
}

- (NSString *)getQstHint
{
    return self.hint;
}
- (void)setCheckType:(NSString*)checkType{
    
    _checkType = checkType;
}

- (NSString *)getCheckType {
    
    return self.checkType;
}

- (NSString *)getQuestIconURL
{
    return self.qstIconUrl;
}

- (NSString *)getCharNum {
    return self.charNum;
}

- (NSString *)getGroupName{
    return self.groupName;
}
- (NSString *)getQstCode{
    return self.qstCod;
}

- (NSString *)getQstAlign {
    return self.align;
}

- (NSString *)getTabGroupName {
    return self.tab;
}

- (NSString *)getIsHideQstName {
    return self.hideQstName;
}

- (NSString *)getIsHideQstOptName {
    return self.hideQstOptName;
}

- (NSString *)getRegularExpression {
    return self.reg;
}

- (NSString *)getParentQuestionId {
    return self.parentQstId;
}

- (NSString *)getDisplayMode {
    return self.displayMode;
}

- (NSString *)getHideBottomLine {
    return self.hiddenBottomline;
}

- (NSString *)getWidthPercent {
    return self.widthPercent;
}

- (NSString *)getPhotoIsCoverNewId {
    return self.isCoverNewId;
}

- (NSString *)getLocationType {
    return self.locationType;
}

- (NSString *)getColKey
{
    return self.colKey;
}

- (void)setLocationType:(NSString *)locationType {
    _locationType = locationType;
}

- (NSString *)getLayout_gravity{
    return self.layout_gravity;
}
- (NSString *)getTitleReadColor{
    return self.titleReadColor;
}
- (NSString *)getValueReadColor{
    return self.valueReadColor;
}
- (NSString *)getValueColor{
    return self.valueColor;
}
- (NSString *)getTitleSize{
    return self.titleSize;
}
- (NSString *)getValueSize{
    return self.valueSize;
}
- (NSString *)getDependon{
    return self.dependon;
}
- (NSString *)getIs_not_water_mark{
    return self.is_not_water_mark;
}

- (void)setIsNoInset:(BOOL)isNoInset {
    _isNoInset = isNoInset;
}


- (BOOL)isNoInset {
    return _isNoInset;
}

#pragma mark -
#pragma mark Iprintable method

-(void)printObjectInfo{

}


- (id)copyWithZone:(NSZone *)zone{
    
    WSAcvtBean_qst  *copyobj = [[[self class] allocWithZone:zone] init];
    
    copyobj->_is_req = [self.is_req copy];
    copyobj->_dlen = self.dlen;
    copyobj->_mlen = self.mlen;
    copyobj->_mnum = self.mnum;
    copyobj->_qstDesc = self.qstDesc;
    copyobj->_qstId = self.qstId;
    copyobj->_acvtQstId = self.acvtQstId;
    copyobj->_qstCod = self.qstCod;
    copyobj->_qstName = self.qstName;
    copyobj->_qstType = self.qstType;
    copyobj->_snum = self.snum;
    copyobj->_opt = self.opt;
    copyobj->_isSupperLocalPhoto = self.isSupperLocalPhoto;
    copyobj->_maxPhoto = self.maxPhoto;
    copyobj->_isHidden = self.isHidden;
    copyobj->_mc = self.mc;
    copyobj->_range = self.range;
    copyobj->_func = self.func;
    copyobj->_dds = self.dds;
    copyobj->_range2 = self.range2;
    copyobj->_func2 = self.func2;
    copyobj->_dds2 = self.dds2;
    copyobj->_filter = self.filter;
    copyobj->_checkType = self.checkType;
    copyobj->_readonly = self.readonly;
    copyobj->_groupName = self.groupName;
    copyobj->_parent = self.parent;
    copyobj->_alertTitle = self.alertTitle;
    copyobj->_parentQstId = self.parentQstId;
    copyobj->_defaultValue = self.defaultValue;
    copyobj->_ds = self.ds;
    copyobj->_isAcvtName = self.isAcvtName;
    copyobj->_acvtNestedId = self.acvtNestedId;
    copyobj->_color = self.color;
    copyobj->_bgColor = self.bgColor;
    copyobj->_answerColor = self.answerColor;
    copyobj->_script = self.script;
    copyobj->_orientation = self.orientation;
    copyobj->posAndFrame = self.posAndFrame;
    copyobj->attachment = self.attachment;
    copyobj->_hint = [self.hint copy];
    copyobj->_qstDesc = [self.qstDesc copy];
    copyobj->_memo = [self.memo copy];
    copyobj->_memo1 = [self.memo1 copy];
    copyobj->_memo2 = [self.memo2 copy];
    copyobj->_memo3 = [self.memo3 copy];
    copyobj->_memo4 = [self.memo4 copy];
    copyobj->_qstIconUrl = [self.qstIconUrl copy];
    copyobj->_countrule = [self.countrule copy];
    copyobj->_align = [self.align copy];
    copyobj->_tab = [self.tab copy];
    copyobj->_hideQstName = [self.hideQstName copy];
    copyobj->_hideQstOptName = [self.hideQstOptName copy];    
    copyobj->_reg = [self.reg copy];
    copyobj->_displayMode = [self.displayMode copy];
    copyobj->_hiddenBottomline = [self.hiddenBottomline copy];
    copyobj->_widthPercent = [self.widthPercent copy];
    copyobj->_isCoverNewId = [self.isCoverNewId copy];
    copyobj->_locationType = [self.locationType copy];
    copyobj->_colKey = [self.colKey copy];
    copyobj->_verticalGroupName = self.verticalGroupName;
    copyobj->_layout_gravity = [self.layout_gravity copy];
    copyobj->_titleReadColor = [self.titleReadColor copy];
    copyobj->_valueReadColor = [self.valueReadColor copy];
    copyobj->_valueColor = [self.valueColor copy];
    copyobj->_titleSize = [self.titleSize copy];
    copyobj->_valueSize = [self.valueSize copy];
    copyobj->_acvtId = [self.acvtId copy];
    copyobj->_is_not_water_mark = [self.is_not_water_mark copy];
    copyobj->_dependon = [self.dependon copy];

    return copyobj;
}
@end
