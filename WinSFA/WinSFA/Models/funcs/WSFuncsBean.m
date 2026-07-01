//
//  FuncsBean.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSFuncsBean.h"
#import "WSFuncsBean_Param.h"
#import "WinSFA.h"
#import "WSFuncsBean_other.h"
#import "WSFuncsBean_menu.h"
@implementation WSFuncsBean

@synthesize fc = _fc;
@synthesize name = _name;;
@synthesize fv = _fv;
@synthesize required = _required;
@synthesize opt = _opt;
@synthesize ds = _ds;
@synthesize paramArray = _paramArray;
@synthesize otherArray = _otherArray;
@synthesize filter = _filter;
@synthesize sqlw = _sqlw;
@synthesize submenu = _submenu;
@synthesize styp = _styp;
@synthesize showtyp = _showtyp;
@synthesize dateTyp = _dateTyp;
@synthesize cocall = _cocall;
@synthesize cochk = _cochk;
@synthesize empTyp = _empTyp;
@synthesize typ = _typ;
@synthesize readonly = _readonly;
@synthesize redis = _redis;
@synthesize unredo = _unredo;
@synthesize display = _display;
@synthesize method = _method;
@synthesize sort = _sort;


/**first col width 首列宽*/
@synthesize wfcol = _wfcol;
@synthesize repeatvisit = _repeatvisit;
@synthesize maxRow = _maxRow;
@synthesize lockCol = _lockCol;
@synthesize isAcvtList = _isAcvtList;
@synthesize isStoreInfo = _isStoreInfo;
@synthesize otherInfoDictionary = _otherInfoDictionary;
@synthesize nullvalue = _nullvalue;

/**用来保存子funcs*/
@synthesize funcsArray = _funcsArray;
@synthesize menuArray = _menuArray;
@synthesize is_more = _is_more;
@synthesize iParentFuncsBean = _iParentFuncsBean;
@synthesize noticeNumFc =_noticeNumFc;


#pragma mark -初始化funcsarray
-(void)dosetFuncsArray:(id)object
{
    NSDictionary *dicFuncs = (NSDictionary *)object;
    NSArray *array = [dicFuncs objectForKey:FUNCS_FUNCS];
    if (array != nil)
    {
        _funcsArray = [[NSMutableArray alloc] init];
        for(int i = 0 ; i < [array count]; i++)
        {
            if([[array objectAtIndex:i] isKindOfClass:[NSDictionary class]])
            {
                WSFuncsBean* func = [[WSFuncsBean alloc]initFuncsWithObject:[array objectAtIndex:i]];
                func.iParentFuncsBean = self;
                [_funcsArray addObject:func];
            }
        }
        
        _funcsArray = [NSMutableArray arrayWithArray:[self sortArrayByArray:_funcsArray]];
        
    }else
        _funcsArray = nil;
}

// 按sort字段排序
-(NSArray *)sortArrayByArray:(NSArray *)array{
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
    return  [array sortedArrayUsingDescriptors:sortDescriptors];
}

-(BOOL)hasObject:(id)json Key:(NSString*)key
{    
    if([json objectForKey:key]!= nil&&
       ![[json objectForKey:key] isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    return NO;
}
#pragma mark -初始化param

-(void)dosetParm:(id)object
{
    
}
-(NSString *)removeUnescapedCharacter:(NSString *)inputStr
{
    NSCharacterSet *controlChars = [NSCharacterSet controlCharacterSet];//获取那些特殊字符
//    NSString *tempStr = inputStr;
    inputStr = [inputStr stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    NSRange range = [inputStr rangeOfCharacterFromSet:controlChars];//寻找字符串中有没有这些特殊字符
    if (range.location != NSNotFound)
    {
        NSMutableString *mutable = [NSMutableString stringWithString:inputStr];
        while (range.location != NSNotFound)
        {
            [mutable deleteCharactersInRange:range];//去掉这些特殊字符
            range = [mutable rangeOfCharacterFromSet:controlChars];
        }
        return mutable;
    }
    return inputStr;
}

#pragma mark -初始化spec

-(void)dosetSpec:(id)object
{
//    //NSLog(@"class is %@",[object class]);
    NSDictionary *FuncsDictionary = (NSDictionary *)object;
    NSDictionary* specDictionary;
    if([[FuncsDictionary objectForKey:FUNCS_SPEC] isKindOfClass:[NSDictionary class]]){
        specDictionary = [FuncsDictionary objectForKey:FUNCS_SPEC];
    }else if([[FuncsDictionary objectForKey:FUNCS_SPEC] isKindOfClass:[NSString class]]){
        NSError *jsonError = nil;
//        specDictionary = [[FuncsDictionary objectForKey:FUNCS_SPEC] objectFromJSONStringWithParseOptions:JKParseOptionStrict|JKParseOptionLooseUnicode error:&jsonError];
        // jsonkit 解析有问题 暂时换成原生解析
        NSString * jsonString = [self removeUnescapedCharacter:[FuncsDictionary objectForKey:FUNCS_SPEC]];
        NSData * data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        specDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingMutableContainers
                                                              error:&jsonError];
        if (!specDictionary) {
            DDLogError(@"jsonError = %@", jsonError);
        }
//         NSLog(@" jsonError = %@" ,jsonError);
//         NSAssert(jsonError==nil,@"json协议有BUG");
    }else{
        return;
    }
    
    if(specDictionary != nil && ![specDictionary isKindOfClass:[NSNull class]])
    {
        // repeatvisit
        id repeatvisit = [specDictionary objectForKey:FUNCS_REPEATVISIT];
        if (repeatvisit != nil && [repeatvisit isKindOfClass:[NSString class]]) {
            _repeatvisit = repeatvisit;
        }

        id l_maxRow = [specDictionary objectForKey:FUNCS_MAXROW];
        //NSLog(@"l_maxrow class is %@",[[l_maxRow class]description]);
        if([l_maxRow isKindOfClass:[NSString class]])
        {
            NSString* i_maxRow = (NSString*)l_maxRow;
            _maxRow = [i_maxRow intValue];
        }
        if([l_maxRow isKindOfClass:[NSNumber class]])
        {
            NSNumber* i_maxRow = (NSNumber*)l_maxRow;
            _maxRow = [i_maxRow intValue];
        }
        if (l_maxRow == nil)
        {
            _maxRow = 0;
        }
        
        //nullvalue
        if([self hasObject:specDictionary Key:FUNCS_NULLVALUE])
        {
            _nullvalue = [[NSString stringWithValue:
                           [specDictionary objectForKey:FUNCS_NULLVALUE]] intValue];
        }
        
        // isMore
        if ([self hasObject:specDictionary Key:FUNCS_ISMORE]) {
            _is_more = [NSString stringWithValue: 
                        [specDictionary objectForKey:FUNCS_ISMORE]];
        }else{
            _is_more = @"0"; // default is 0
        }
        
        //required
        if([self hasObject:specDictionary Key:FUNCS_REQUIRED])
        {
            _required = [NSString stringWithValue:
                        [specDictionary objectForKey:FUNCS_REQUIRED]];
        }
        
        //method
        if([self hasObject:specDictionary Key:FUNCS_METHOD])
        {
            _method = [NSString stringWithValue:
                         [specDictionary objectForKey:FUNCS_METHOD]];
        }
        
        //styp
        if([self hasObject:specDictionary Key:FUNCS_STYP])
        {
            _styp = [NSString stringWithValue:
                          [specDictionary objectForKey:FUNCS_STYP]];
        }
        //icon
        if ([self hasObject:specDictionary Key:FUNCS_ICON]) {
            
            _icon = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_ICON]];
        }
        
        //icon
        if ([self hasObject:specDictionary Key:FUNCS_ICONOFDONE]) {
            
            _iconOfDone = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_ICONOFDONE]];
        }
        
        //shortCutUrl
        if ([self hasObject:specDictionary Key:FUNCS_SHORTCUTURL]) {
            _shortCutURL = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_SHORTCUTURL]];
        }
        //opt
        if([self hasObject:specDictionary Key:FUNCS_OPT])
        {
//        #warning need to do
            NSDictionary* optDictionary = [specDictionary objectForKey:FUNCS_OPT];
            _opt = [[WSFuncsBean_opt alloc]initFuncs_optWithObject:optDictionary];
        }
        //ds
        if([self hasObject:specDictionary Key:FUNCS_DS])
        {
            _ds = [NSString stringWithValue:
                  [specDictionary objectForKey:FUNCS_DS]];
        }
        //filter
        if([self hasObject:specDictionary Key:FUNCS_FILTER])
        {
            // SFA-18911  2018-4-23
            NSString * filter ;
            if ([[specDictionary objectForKey:FUNCS_FILTER] isKindOfClass:[NSDictionary class]]) {
                filter = [[specDictionary objectForKey:FUNCS_FILTER] JSONString];
            }else{
                filter = [specDictionary objectForKey:FUNCS_FILTER];
            }
            _filter = [NSString stringWithValue:filter];
        }
        
        // display
        if([self hasObject:specDictionary Key:FUNCS_DISPLAY])
        {
            _display = [NSString stringWithValue:
                        [specDictionary objectForKey:FUNCS_DISPLAY]];
        }
        
        //storeInfo
        if([self hasObject:specDictionary Key:FUNCS_STOREINFO])
        {
            _isStoreInfo = [NSString stringWithValue:
                           [specDictionary objectForKey:FUNCS_STOREINFO]];
        }

        //sqlw
        if([self hasObject:specDictionary Key:FUNCS_SQLW])
        {
            _sqlw = [NSString stringWithValue:
                    [specDictionary objectForKey:FUNCS_SQLW]];
        }
        //submenu
        if([self hasObject:specDictionary Key:FUNCS_SUBMENU])
        {
            _submenu = [NSString stringWithValue:
                    [specDictionary objectForKey:FUNCS_SUBMENU]];
        }
        //wfcol  首列宽  单位：像素
        if([self hasObject:specDictionary Key:FUNCS_WFCOL])
        {
            _wfcol = [[specDictionary objectForKey:FUNCS_WFCOL] intValue];
        }
        else
        {
            _wfcol = 0;
        }
        
        //FcharNum  首列宽  单位：位数   优先级最高
        if([self hasObject:specDictionary Key:FUNCS_fCharNum])
        {
            _fCharNum = [[specDictionary objectForKey:FUNCS_fCharNum] intValue];
        }
        else
        {
            _fCharNum = 0;
        }
        
        
        
        //CharNum  列宽  单位：位数   优先级最高
        if([self hasObject:specDictionary Key:FUNCS_CharNum])
        {
            _charNum = [[specDictionary objectForKey:FUNCS_CharNum] intValue];
        }
        else
        {
            _charNum = 0;
        }
        
        //isAcvtList
        if([self hasObject:specDictionary Key:FUNCS_ISACVTLIST])
        {
            _isAcvtList = [NSString stringWithValue:
                          [specDictionary objectForKey:FUNCS_ISACVTLIST]];
        }
        //paramarry
        if([self hasObject:specDictionary Key:FUNCS_PARAM])
        {
            NSArray* params = [specDictionary objectForKey:FUNCS_PARAM];
            if([params count] != 0)
            {
                _paramArray = [[NSMutableArray alloc]init];
                for(int i = 0 ; i < [params count];i++)
                {
                    WSFuncsBean_Param* param = [[WSFuncsBean_Param alloc]initFuncs_ParamWithObject:[params objectAtIndex:i]];
                    [_paramArray addObject:param];
                }
                
            }
        }
        //other
        if([self hasObject:specDictionary Key:FUNCS_OTHER])
        {
            NSArray* others =  [specDictionary objectForKey:FUNCS_OTHER];
            if([[specDictionary objectForKey:FUNCS_OTHER]isKindOfClass:[NSArray class]])
            {
                _otherArray = [[NSMutableArray alloc]init];
                for(int i = 0 ; i < [others count];i++)
                {
                    WSFuncsBean_other * fb_other = [[WSFuncsBean_other alloc]initFuncsOtherBeanObject:[others objectAtIndex:i]];
                    [_otherArray addObject:fb_other];
                }
            }
        }
        //typ
        if([self hasObject:specDictionary Key:FUNCS_TYP])
        {
            _typ = [NSString stringWithValue:
                          [specDictionary objectForKey:FUNCS_TYP]];
        }
        //cocall
        if([self hasObject:specDictionary Key:FUNCS_COCALL])
        {
            _cocall = [NSString stringWithValue:
                   [specDictionary objectForKey:FUNCS_COCALL]];
        }
        //cochk
        if([self hasObject:specDictionary Key:FUNCS_COCHK])
        {
            _cochk = [NSString stringWithValue:
                   [specDictionary objectForKey:FUNCS_COCHK]];
        }
        //datatpy
        if([self hasObject:specDictionary Key:FUNCS_DATETYP])
        {
            _dateTyp = [NSString stringWithValue:
                   [specDictionary objectForKey:FUNCS_DATETYP]];
        }
        //readonly
        if([self hasObject:specDictionary Key:FUNCS_READONLY])
        {
            _readonly = [[specDictionary objectForKey:FUNCS_READONLY] intValue];
        }
        //redis
        if([self hasObject:specDictionary Key:FUNCS_REDIS])
        {
            _redis = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_REDIS]];
        }
        else {
            _redis = @"0";
        }
        //unredo
        if([self hasObject:specDictionary Key:FUNCS_UNREDO])
        {
            _unredo = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_UNREDO]];
        }
        //lockcol
        if([self hasObject:specDictionary Key:FUNCS_LOCKCOL])
        {
            _lockCol = [[specDictionary objectForKey:FUNCS_LOCKCOL] intValue];
        }
        //locklevel
        if ([self hasObject:specDictionary Key:FUNCS_LOCKLEVEL]) {
            
              _lockLevel = [[specDictionary objectForKey:FUNCS_LOCKLEVEL] intValue];
        }
        //showtyp
        if([self hasObject:specDictionary Key:FUNCS_SHOWTYP])
        {
            _showtyp = [NSString stringWithValue:
                      [specDictionary objectForKey:FUNCS_SHOWTYP]];
        }
        //emptyp
        if([self hasObject:specDictionary Key:FUNCS_EMPTYP])
        {
            _empTyp = [NSString stringWithValue:
                       [specDictionary objectForKey:FUNCS_EMPTYP]];
        }
        //typ
        
        
        //default
        if([self hasObject:specDictionary Key:FUNCS_DEFAULT])
        {
            _defaultString = [NSString stringWithValue:
                       [specDictionary objectForKey:FUNCS_DEFAULT]];
        }
        
        
        //menu
        if ([self hasObject:specDictionary Key:FUNCS_MENU])
        {
            NSArray* menus = [specDictionary objectForKey:FUNCS_MENU];
            if([menus count] != 0)
            {
                _menuArray = [[NSMutableArray alloc]init];
                for(int i = 0 ; i < [menus count];i++)
                {
                    WSFuncsBean_menu* menu = [[WSFuncsBean_menu alloc]initFuncs_MenuWithObject:[menus objectAtIndex:i]];
                    [_menuArray addObject:menu];
                }
                
            }
        }
        
        //value
        if ([self hasObject:specDictionary Key:FUNCS_SPEC_VALUE]) {
            _value = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_SPEC_VALUE]];
        }
        
        if([self hasObject:specDictionary Key:FUNCS_SPEC_BUTTONNAME])
        {
            self.buttonName = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_SPEC_BUTTONNAME]];
        }
        if ([self hasObject:specDictionary Key:FUNCS_SPEC_JUMP_URL]) {
            _jumpUrl = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_SPEC_JUMP_URL]];
        }
        if ([self hasObject:specDictionary Key:FUNCS_SPEC_IOS_OPEN_URL]) {
            _iosOpenUrl = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_SPEC_IOS_OPEN_URL]];
        }
        
        if ([self hasObject:specDictionary Key:FUNCS_SENDREQUEST]) {
            _sendRequest = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_SENDREQUEST]];
        }
        //SFALHLH-100【ios联合利华】增加参数menuLayout控制菜单导航显示 left左侧导航 ,nextSteps为下一步底部导航
        if ([self hasObject:specDictionary Key:FUNCS_MENU_LAYOUT]) {
             _menuLayout = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_MENU_LAYOUT]];
        }
        
        //SFALHLH-112 [联合利华]菜单新增参数storeFilter控制通过门店某个属性筛选门店
        if ([self hasObject:specDictionary Key:FUNCS_STORES_FILTER]) {
            _storesFilter = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_STORES_FILTER]];
        }
        
        if ([self hasObject:specDictionary Key:FUNCS_ALIGNBOTTOM]) {
            _alignBottom = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_ALIGNBOTTOM]];
        }
        
        if ([self hasObject:specDictionary Key:FUNCS_SHOWTHUMBNAIL]) {
            _showThumbnail = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_SHOWTHUMBNAIL]];
        }
        if ([self hasObject:specDictionary Key:FUNCS_HIDDEN_EMPTY]) {
            _hiddenEmpty = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_HIDDEN_EMPTY]];
        }
        
        if ([self hasObject:specDictionary Key:FUNCS_SPEC_TOP_TIP]) {
            _topTip = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_SPEC_TOP_TIP]];
        }
        if ([self hasObject:specDictionary Key:FUNCS_SPEC_PAGE_TAG]) {
            _pageTag = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_SPEC_PAGE_TAG]];
        }
        
        //2018-01-17-MSTD-7535
        if ([self hasObject:specDictionary Key:FUNCS_SPEC_DEFAULT])
            _defaultInfo = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_SPEC_DEFAULT]];
        if ([self hasObject:specDictionary Key:FUNCS_SPEC_DEFAULT_IMAGE_URL])
            _defaultImageUrl = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_SPEC_DEFAULT_IMAGE_URL]];
        
        if ([self hasObject:specDictionary Key:FUNCS_NOTICENUMFC]) {
            _noticeNumFc = [NSString stringWithValue:[specDictionary objectForKey:FUNCS_NOTICENUMFC]];
        }
    }
}
#pragma mark -生命周期

- (id)initFuncsWithObject:(id)object
{
    if (nil == object) {
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        _maxRow = 1;
        _lockCol = NO;
        
        if ([object isKindOfClass:[NSDictionary class]]){
            //初始化
            NSDictionary *dicFuncs = (NSDictionary *)object;
            _fc = [NSString stringWithValue:[dicFuncs objectForKey:FUNCS_FC]];
            _fv = [NSString stringWithValue:[dicFuncs objectForKey:FUNCS_FV]];
            _name = [NSString stringWithValue:[dicFuncs objectForKey:FUNCS_NAME]];
            _script = [NSString stringWithValue:[dicFuncs objectForKey:FUNCS_SCRIPT]];
            _levelCode =[NSString stringWithValue:[dicFuncs objectForKey:FUNCS_LEVELCODE]];
            _menuType =[NSString stringWithValue:[dicFuncs objectForKey:FUNCS_MENUTYPE]];
            _menuStyle = [NSString stringWithValue:[dicFuncs objectForKey:FUNCS_MENUSTYLE]];
            
            id l_colNum = [dicFuncs objectForKey:FUNCS_COLNUM];

            if([l_colNum isKindOfClass:[NSString class]])
            {
                NSString* i_colNum = (NSString*)l_colNum;
                _colNum = [i_colNum intValue];
            }
            if([l_colNum isKindOfClass:[NSNumber class]])
            {
                NSNumber* i_colNum = (NSNumber*)l_colNum;
                _colNum = [i_colNum intValue];
            }
            if (l_colNum == nil)
            {
                _colNum = 4;
            }
            
            _fk =[NSString stringWithValue:[dicFuncs objectForKey:FUNCS_FK]];
            _pk =[NSString stringWithValue:[dicFuncs objectForKey:FUNCS_PK]];
            
            if ([dicFuncs objectForKey:FUNCS_SORT]) {
                _sort = [[dicFuncs objectForKey:FUNCS_SORT] integerValue];
            } else {
                _sort = 0;
            }
            
            //funcsarray
            [self dosetFuncsArray:object];
            //spec
            [self dosetSpec:object];
        }
    }
    return self;
}

- (void)setParamArrayFromOut:(NSArray *)paramArray {
    NSMutableArray *array = [NSMutableArray arrayWithArray:paramArray];
    _paramArray = array;
}


@end
