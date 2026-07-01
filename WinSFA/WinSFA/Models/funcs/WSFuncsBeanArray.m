//
//  FuncsBeanArray.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#import "WSFuncsBeanArray.h"
#import "WSFuncsBean.h"
#import "WSBaseMsgTypeDBService.h"
#import "WSBaseMsgTable.h"
#define kWorkbenchFV @"FV_WORK"
//默认进入工作重点fv
#define DEFAULT_HOMEPAGE_FV @"TAB_V1001"

@interface WSFuncsBeanArray ()
@property (nonatomic, assign) NSInteger minLevel;
@end

@implementation WSFuncsBeanArray
{
    /**
     * 隐藏的funcsArray，除去应用显示的整个funcs树，剩下的funcs。
     * 这些funcs不在程序中显示，但会用于为其他模块提供数据，例如调查问卷中的表格。
     *（箭牌首发，根据Android的逻辑，原来调查问卷从tb节点获取表格数据，现在tb节点已废弃，改为配置一个不显示的funcs为调查问卷的表格提供数据）
     **/
    NSMutableArray *hideFuncsArray;
    
    NSMutableArray *hideFuncsDicArray;
}

@synthesize funcsArray = _funcsArry;
@synthesize hidefuncsArray=hideFuncsArray;

- (void)initFuncsArrayWithArray:(NSArray *)array{
    
    _funcsArry = [[NSMutableArray alloc] init];
    
    NSMutableArray *workbenchHideArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){ 
            
            for (int i = 0; i < [array count]; i++) {
                WSFuncsBean *funcs = [[WSFuncsBean alloc] initFuncsWithObject:[array objectAtIndex:i]];
                if ([funcs.menuType length] > 0) {
                    [workbenchHideArray addObject:funcs];
                }
                    
                [self.funcsArray addObject:funcs];
            }
        }
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    [self.funcsArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    if ([workbenchHideArray count] > 0) {
        WSFuncsBean *workbenchFB = [self getFuncsBeanWithFV:kWorkbenchFV];
        
        if (!workbenchFB.submenu || [workbenchFB.submenu rangeOfString:workbenchFB.fc].location == NSNotFound) {
            NSMutableArray *workbenchArray = [NSMutableArray array];
            if (workbenchFB.funcsArray) {
                [workbenchArray addObjectsFromArray:workbenchFB.funcsArray];
            }
            NSArray *fcArray = [workbenchArray valueForKey:@"fc"];
            for (WSFuncsBean *funcBean in workbenchHideArray) {
                if (![fcArray containsObject:funcBean.fc]) {
                    [workbenchArray addObject:funcBean];
                }
            }
            workbenchFB.funcsArray = [workbenchArray copy];
            
            [self.funcsArray removeObjectsInArray:workbenchHideArray];
        }
        
    }
    
}

- (void)initHideFuncsArrayWithArray:(NSArray *)array{
    
    hideFuncsArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){
            
            for (int i = 0; i < [array count]; i++) {
                WSFuncsBean *funcs = [[WSFuncsBean alloc] initFuncsWithObject:[array objectAtIndex:i]];
                [hideFuncsArray insertObject:funcs atIndex:i];
            }
        }
    }
    
}


-(id)initWithObject:(id)object
{
    if (nil == object){
        return nil;
    }
    
    self = [super init];
    if(self != nil)
    {
        if ([object isKindOfClass:[NSDictionary class]]){
            NSMutableArray *hiddenArray = [NSMutableArray array];
            NSMutableArray *Array = [object objectForKey:FUNCS2];
            if (Array)
            {
                self.minLevel = NSIntegerMax;
                hideFuncsDicArray = [NSMutableArray arrayWithArray:Array];
                Array = [self funcs:Array];
                //处理隐藏菜单 --SFA-23630
                hiddenArray = [self hiddenfuncs:[hideFuncsDicArray mutableCopy]];

            }
            else
            {
                Array = [object objectForKey:FUNCS];
            }

            [self initFuncsArrayWithArray:Array];
            // [self initHideFuncsArrayWithArray:hideFuncsDicArray];
            //处理隐藏菜单 --SFA-23630
            [self initHideFuncsArrayWithArray:hiddenArray];
        }
        return self;
    }
    return nil;
}



// 最新的主页显示资源和其子funcs关联的获取方法
// 获取主页显示资源的方法
- (NSMutableArray *)funcs:(NSMutableArray *)funs2Array {
    LogTrace();
    if (!funs2Array ) {
        LogInfo(@"funcs2Array--%@",[funs2Array description]);
        return nil;
    }
    
    // MSTD-4900 支持 3 级，之前的逻辑是只支持 2 级，先遍历 2 级，如果最小层级不是 2 级，则设置 minLevel，然后再遍历一次
    NSMutableArray *funcsArray = [self getFuncs:funs2Array withRootLevelCode:2];
    if (self.minLevel > 2) {
        funcsArray = [self getFuncs:funs2Array withRootLevelCode:self.minLevel];
    }
    
    return funcsArray;
}

// MSTD-4900 遍历 levelCode 为 rootLevelCode 的菜单，同时设置 minLevel ，大部分环境都是查找 2 级菜单，避免多次遍历
- (NSMutableArray *)getFuncs:(NSMutableArray *)funcs2Array withRootLevelCode:(NSInteger)rootLevelCode {
    NSMutableArray *funcsArray = [[NSMutableArray alloc]init];
    [funcs2Array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *tempObj;
        if ([obj isKindOfClass:[NSDictionary class]]) {
            tempObj = [NSMutableDictionary dictionaryWithDictionary:obj];
        }
        NSString *fv = [tempObj objectForKey:FUNCS_FV];
        NSInteger levelCode = [[NSString stringWithValue:[tempObj objectForKey:FUNCS_LEVELCODE]] integerValue];
        
        // 若fv 以 FUNCS_FV_HAS_TB 为前缀
        // 则认为 该 obj(FUNCS)是主页显示资源
        
        if ([fv isKindOfClass:[NSString class]] && [fv hasPrefix:FUNCS_FV_HAS_TB]) {
            if (levelCode <= self.minLevel) {
                self.minLevel = levelCode;
            }
            if (levelCode <= rootLevelCode) {
                // 遍历funcs2Array 中FUNCS的 fk 若等于当前 FUNCS(也就是obj)的pk
                // 符合条件的FUNCS 是当前FUNCS(也就是obj)的子 FUNCS.
                NSMutableArray *funcs = [self  nodeFuncsWith:tempObj andArray:funcs2Array];
                [tempObj setObject:funcs forKey:FUNCS];
                
                [funcsArray addObject:tempObj];
                
                [hideFuncsDicArray removeObject:obj];
            }
            
        }
    }];
    return funcsArray;
}
//处理隐藏菜单项的子集 ---SFA-23630
- (NSMutableArray *)hiddenfuncs:(NSMutableArray *)funs2Array {
    LogTrace();
    if (!funs2Array ) {
        LogInfo(@"funcs2Array--%@",[funs2Array description]);
        return nil;
    }
    
    NSMutableArray *hidefuncsArray = [self getHiddenFuncs:funs2Array];
    return hidefuncsArray;
}

- (NSMutableArray *)getHiddenFuncs:(NSMutableArray *)funcs2Array {
    NSMutableArray *funcsArray = [[NSMutableArray alloc]init];
    [funcs2Array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *tempObj;
        if ([obj isKindOfClass:[NSDictionary class]]) {
            tempObj = [NSMutableDictionary dictionaryWithDictionary:obj];
        }
        // 遍历funcs2Array 中FUNCS的 fk 若等于当前 FUNCS(也就是obj)的pk
        // 符合条件的FUNCS 是当前FUNCS(也就是obj)的子 FUNCS.
        NSMutableArray *funcs = [self  nodeFuncsWith:tempObj andArray:funcs2Array];
        [tempObj setObject:funcs forKey:FUNCS];
        
        [funcsArray addObject:tempObj];
        
    }];
    
    return funcsArray;
}

- (NSMutableArray *)nodeFuncsWith:(NSMutableDictionary *)funcDic andArray:(NSMutableArray *)funcs2Array{
    
    if (!funcs2Array || !funcDic) {
        LogInfo(@"funcs2Array--%@ \n @funcDic--%@",[funcs2Array description],[funcDic description]);
        return nil;
    }
    NSString *pk = [NSString stringWithValue:[funcDic objectForKey:FUNCS_PK]];
    
    NSMutableArray *currentNodeFuncs = [[NSMutableArray alloc]init];
    [funcs2Array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *tempObj;
        if ([obj isKindOfClass:[NSDictionary class]]) {
            tempObj = [NSMutableDictionary dictionaryWithDictionary:obj];
        }
        
        NSString *fk = [NSString stringWithValue:[tempObj objectForKey:FUNCS_FK]];
        if ([fk isEqualToString:pk]) {
            NSMutableArray *nodeFuncs = [self  nodeFuncsWith:tempObj andArray:funcs2Array];
            [tempObj setObject:nodeFuncs forKey:FUNCS];
            [currentNodeFuncs addObject:tempObj];
            
            [hideFuncsDicArray removeObject:obj];
        }
    }];
    return currentNodeFuncs;
}


#pragma mark 外部接口

-(WSFuncsBean*)traverseElement:(WSFuncsBean*)funcs SubMenu:(NSArray*)subMenu
{
    for(int j = 0 ; j < [subMenu count]; j++)
    {
        if([funcs.fc isKindOfClass:[NSString class]] && [funcs.fc isEqualToString:[subMenu objectAtIndex:j]])
        {
            //modify by niuzhaowang
            NSInteger index = j + 1; //next submenu item index
            NSInteger count = [subMenu count];
            WSFuncsBean *retFunc = funcs;
            bool hasFoundNextFunction = false;
            while (index < count) {
                hasFoundNextFunction = false;
                for (int m = 0; m < [retFunc.funcsArray count]; m++) {
                    WSFuncsBean* subfb = [retFunc.funcsArray objectAtIndex:m];
                    if([subfb.fc isEqualToString:[subMenu objectAtIndex:index]])
                    {
                        retFunc = subfb;
                        index++;
                        hasFoundNextFunction = true;
                        break;
                    }
                }
                if (!hasFoundNextFunction) {
                    break;
                }
                
            }

            if (hasFoundNextFunction) {
                return retFunc;
            }
            else {
                break;
            }
            
            //                for(int m = 0 ; m < [funcs.funcsArray count]; m++)
            //                {
            //                    FuncsBean* subfb = [funcs.funcsArray objectAtIndex:m];
            //                    NSLog(@"fv is =%@",subfb.fv);
            //                    if([subfb.fc isEqualToString:[subMenu objectAtIndex:j+1]])
            //                        return subfb;
            //                }
        }else //如果第一次就不匹配就不再继续下去
            break;
    }
    
    for(int i = 0 ; i < [funcs.funcsArray count] ; i++)
    {
        WSFuncsBean* resultfb = [self traverseElement:[funcs.funcsArray objectAtIndex:i] SubMenu:subMenu];
        if(resultfb != nil)
        {
            return resultfb;
        }
    }
    
    return nil;
    
}

-(WSFuncsBean*)getFuncsBeanFromSubFC:(NSString*)subMenu
{
    NSArray* subMenuArray = [NSArray arrayWithArray:[subMenu componentsSeparatedByString:@","]];
    
    NSInteger count = [self.funcsArray count];
    WSFuncsBean* resultfb;
    for(int i = 0 ; i < count ; i++)
    {
        WSFuncsBean* fb = [self.funcsArray objectAtIndex:i];
        resultfb = [self traverseElement:fb SubMenu:subMenuArray];
        if(resultfb != nil)
            return resultfb;
    }
    
    //MMSH-8119 如果上方循环拿不到func（循环只取了首页的四个菜单遍历）,就从总菜单组中重新拿一下
    if (!resultfb) {
        WSFuncsBeanArray* funcsArray = [WSAppData getObjectbyKey:FUNCS];
        resultfb = [funcsArray getFuncsBeanWithFC:subMenu];
        if (resultfb != nil) {
            return resultfb;
        }
    }

    return nil;
}
- (WSFuncsBean *)getParentFuncsBeanWithFk:(NSString *)fk{
    NSMutableArray * funcArray = [[NSMutableArray alloc]init];
    [funcArray addObjectsFromArray:self.funcsArray];
    [funcArray addObjectsFromArray:self.hidefuncsArray];
    for (int i = 0; i < funcArray.count; i++) {
        WSFuncsBean* fb = [funcArray objectAtIndex:i];
        if ([fb.pk isEqualToString:fk]) {
            return fb;
        }
    }
    return nil;
}
//由fc取得当前 fb方法
- (WSFuncsBean *)getAllFuncsBeanWithFC:(NSString *)fc
{
    WSFuncsBean * funcsBean = [self getFuncsBeanWithFC:fc];
    if (funcsBean) {
        return funcsBean;
    }
    WSFuncsBean * hideFuncsBean = [self getHideFuncsBeanWithFC:fc];
    if (hideFuncsBean) {
        return hideFuncsBean;
    }
    return nil;
}


//由fc取得当前 fb 递归方法
- (WSFuncsBean *)getFuncsBeanWithFC:(NSString *)fc
{
    for(WSFuncsBean* fb in self.funcsArray)
    {
        if ([fb.fc isEqualToString:fc]) {
            return fb;
        }
        WSFuncsBean* resultfb = [self getSubFB:fb withFC:fc];
        if(resultfb != nil)
            return resultfb;
    }
    return nil;
}

- (WSFuncsBean *)getHideFuncsBeanWithFC:(NSString *)fc
{
    for(WSFuncsBean* fb in hideFuncsArray)
    {
        if ([fb.fc isEqualToString:fc]) {
            return fb;
        }
    }
    return nil;
}

- (WSFuncsBean *)getHideFuncsBeanWithFV:(NSString *)FV{
    for(WSFuncsBean* fb in hideFuncsArray)
    {
        if ([fb.fv isEqualToString:FV]) {
            return fb;
        }
    }
    return nil;
}

-(WSFuncsBean*)getSubFB:(WSFuncsBean*)funcs withFC:(NSString*)fc
{
    WSFuncsBean *retFunc = funcs;
    BOOL hasFoundNextFunction = NO;

    for (WSFuncsBean* subfb in retFunc.funcsArray) {
        if([subfb.fc isEqualToString:fc]){
            retFunc = subfb;
            hasFoundNextFunction = YES;
            break;
        }
    }
    if (hasFoundNextFunction) {
        return retFunc;
    }
    
    for(WSFuncsBean* fb in funcs.funcsArray)
    {
        WSFuncsBean* resultfb = [self getSubFB:fb withFC:fc];
        if(resultfb != nil){
            return resultfb;
        }
    }
    
    return nil;
}


//由fc取得当前 fb 递归方法
- (WSFuncsBean *)getFuncsBeanWithFV:(NSString *)fv
{
    for(WSFuncsBean* fb in self.funcsArray)
    {
        WSFuncsBean* resultfb = [self getSubFB:fb withFV:fv];
        if(resultfb != nil)
            return resultfb;
    }
    return nil;
}

-(WSFuncsBean*)getSubFB:(WSFuncsBean*)funcs withFV:(NSString*)fv
{
    WSFuncsBean *retFunc = funcs;
    BOOL hasFoundNextFunction = NO;
    
    for (WSFuncsBean* subfb in retFunc.funcsArray) {
        if([subfb.fv isEqualToString:fv]){
            retFunc = subfb;
            hasFoundNextFunction = YES;
            break;
        }
    }
    if (hasFoundNextFunction) {
        return retFunc;
    }
    
    for(WSFuncsBean* fb in funcs.funcsArray)
    {
        WSFuncsBean* resultfb = [self getSubFB:fb withFV:fv];
        if(resultfb != nil){
            return resultfb;
        }
    }
    
    return nil;
}

- (NSArray *)getHideSubFuncBeanArrayWithPK:(NSString *)pk {
    
    NSMutableArray *subArray = [NSMutableArray array];
    
    for(WSFuncsBean* fb in hideFuncsArray)
    {
        if ([fb.fk isEqualToString:pk]) {
            [subArray addObject:fb];
        }
        
    }
    
    return subArray;
}

- (WSFuncsBean *)getFuncsBeanFromAllFucsWithFC:(NSString *)FC{
    WSFuncsBean *funcsBean = [self getFuncsBeanWithFC:FC];
    if (!funcsBean) {
        funcsBean = [self getHideFuncsBeanWithFC:FC];
    }
    return funcsBean;
}

-(WSFuncsBean*)getSubFB:(WSFuncsBean*)funcs withFilter:(NSString*)filter
{
    WSFuncsBean *retFunc = funcs;
    BOOL hasFoundNextFunction = NO;
    
    for (WSFuncsBean* subfb in retFunc.funcsArray) {
        if([subfb.filter isEqualToString:filter]){
            retFunc = subfb;
            hasFoundNextFunction = YES;
            break;
        }
    }
    if (hasFoundNextFunction) {
        return retFunc;
    }
    
    for(WSFuncsBean* fb in funcs.funcsArray)
    {
        WSFuncsBean* resultfb = [self getSubFB:fb withFilter:filter];
        if(resultfb != nil){
            return resultfb;
        }
    }
    
    return nil;
}




- (WSFuncsBean *)getFuncsBeanWithFilter:(NSString *)filter {
    for(WSFuncsBean* fb in self.funcsArray)
    {
        if ([fb.filter isEqualToString:filter]) {
            return fb;
        }
        WSFuncsBean* resultfb = [self getSubFB:fb withFilter:filter];
        if(resultfb != nil)
            return resultfb;
    }
    return nil;
}

-(NSDictionary *)getShowFuncsBean{
    
    WSFuncsBean *realSubFuncsBean;

    // 处理 mobilehomepage
    NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
    BOOL isEnterMsgList = [[NSString stringNotNilWithValue:mobileHomeDic[@"fc"]] isEqualToString:@"3"];
    if (!mobileHomeDic || isEnterMsgList) {
        
        /*如果mobileHomeDic无值 则默认进入工作重点*/
        //SFA 箭牌 WRIGLEY-1703
        NSInteger msgCount  =  0 ;
        // 如果一条消息也没有，则进入主页

        msgCount =[[WSBaseMsgTable sharedTable] queryCountWithSql:@"select * from base_msg"];
        
        BOOL show = NO;
        
        WSFuncsBean *subFb = [self getFuncsBeanWithFV:DEFAULT_HOMEPAGE_FV];
        
        if (!subFb) {
            subFb = [self getHideFuncsBeanWithFV:DEFAULT_HOMEPAGE_FV];
        }
        
        if ([subFb.fv isEqualToString:DEFAULT_HOMEPAGE_FV] && msgCount > 0) {
            realSubFuncsBean = subFb;
            // 如果 mobileHomeDic fc配置为3，如果没有工作重点则进入消息列表，fc配置不为3进入主页
            if (isEnterMsgList) {
                show = YES;
            }else{
                NSInteger count = [[[WSBaseMsgTypeDBService alloc]init] queryMsgCountByCod:subFb.filter];
                if (count > 0) {
                    show = YES;
                }
            }
            
        }
        
        if (show) {
            [realSubFuncsBean.iParentFuncsBean setIsHomePageWillShow:YES];
            
            return @{IS_SHOW:@"1",FROM_FUNCS_BEAN:realSubFuncsBean.iParentFuncsBean,SHOW_FUNCS_BEAN:realSubFuncsBean};
        }
        
    }
    
    NSString *homePageValue = [mobileHomeDic objectForKey:MobileHomePageFcKey];
    NSString *readingTime = [NSString stringWithValue:[mobileHomeDic objectForKey:MobileHomePageReadingTimeKey]];
    if (!readingTime) {
        readingTime = @"0";
    }
    
    //兼容以前逻辑BS
    if ([[mobileHomeDic objectForKey:MobileHomePageReadingTimeKey] isEqualToString:@"-1"] || !([homePageValue length] > 0)) {
        
        NSString *homePageValue = [mobileHomeDic objectForKey:MobileHomePageFcKey];
        // 默认过滤fc属性
        NSString *proKey = @"fc";
        if (!homePageValue || [@"" isEqualToString:homePageValue])
        {
            homePageValue = DEFAULT_HOMEPAGE_FV;
            // 未配置MOBILEHOMEPAGE，则过滤fv属性
            proKey = @"fv";
            
        }
        
        //做辉瑞Etrip时新增的逻辑，该逻辑from Android，homePageValue 为2时，显示第一个subFuncsBean的fv为TAB_V1005，且本身的fv为TB_EVAL的节点
        if ([homePageValue isEqualToString:@"2"]) {
            homePageValue = @"TAB_V1005";
            proKey = @"fv";
        }
        WSFuncsBean * hideFuncs = [self getHideFuncsBeanWithFC:homePageValue];
        if (hideFuncs) {
            [hideFuncs setIsHomePageWillShow:YES];
            return @{IS_SHOW:@"1",SHOW_FUNCS_BEAN:hideFuncs,MOBILE_HOME_PAGE_READING_TIME:readingTime};
        }
        // 支持 MobileHomePageFcKey 配置多个，但是只显示一个，为了区分不同角色展示不同的首显页  SFA 项目 SFA-7966
        NSArray * homePageArray = [homePageValue componentsSeparatedByString:@","];
        for (WSFuncsBean *fb in self.funcsArray)
        {
            WSFuncsBean *tempFuncBean = fb;
            BOOL show = YES;
            for (WSFuncsBean *subFb in fb.funcsArray)
            {
                if ([homePageArray containsObject:[subFb valueForKey:proKey]] /*[[subFb valueForKey:proKey] isEqualToString:homePageValue]*/)
                {
                    if ([homePageValue isEqualToString:@"TAB_V1005"] && [proKey isEqualToString:@"fv"] && ![fb.fv isEqualToString:@"TB_EVAL"])
                    {
                        show = NO;
                    }
                    else
                    {
                        realSubFuncsBean = subFb;
                    }
                    
                } else if ([[subFb valueForKey:proKey] isEqualToString:@"TAB_V1002"]) {
                    show = YES;
                    tempFuncBean = subFb;
                }
            }
            if (show && realSubFuncsBean)
            {
                return @{IS_SHOW:@"1",FROM_FUNCS_BEAN:fb,SHOW_FUNCS_BEAN:realSubFuncsBean,MOBILE_HOME_PAGE_READING_TIME:readingTime};
            }
        }
        
    }else {
        
        WSFuncsBean * hideFuncs = [self getHideFuncsBeanWithFC:homePageValue];
        if (hideFuncs) {
            return @{IS_SHOW:@"1",SHOW_FUNCS_BEAN:hideFuncs,MOBILE_HOME_PAGE_READING_TIME:readingTime};
        }
        // 支持 MobileHomePageFcKey 配置多个，但是只显示一个，为了区分不同角色展示不同的首显页   SFA 项目 SFA-7966
        NSArray * homePageArray = [homePageValue componentsSeparatedByString:@","];

        for (WSFuncsBean *fb in self.funcsArray) {
            BOOL show = NO;
            for (WSFuncsBean *subFb in fb.funcsArray) {
                if ([homePageArray containsObject:[subFb valueForKey:MobileHomePageFcKey]] /*[[subFb valueForKey:MobileHomePageFcKey] isEqualToString:homePageValue]*/) {
                    show = YES;
                    realSubFuncsBean = subFb;
                    break;
                }
            }
            
            if (show && realSubFuncsBean) {
                [fb setIsHomePageWillShow:YES];
                return @{IS_SHOW:@"1",FROM_FUNCS_BEAN:fb,SHOW_FUNCS_BEAN:realSubFuncsBean,MOBILE_HOME_PAGE_READING_TIME:readingTime};
                break;
            }
        }
    }
    
    // SFA-9687 添加按fc查找funcs的方法，避免出现如果homePage菜单配置在三级菜单或三级菜单以上找不到跳转菜单页面的情况
    WSFuncsBean * showFuncs = [self getFuncsBeanWithFC:homePageValue];
//    MMSH-4408
//    SFA玛氏中国MWC- 【IOS:信息】账号csissyd1,一登录没有显示列表而是从信息列表一直跳转到信息的内容，并且信息的内容的行距很大
    if (showFuncs) {
        [showFuncs setIsHomePageWillShow:YES];
        return @{IS_SHOW:@"1",SHOW_FUNCS_BEAN:showFuncs,MOBILE_HOME_PAGE_READING_TIME:readingTime};
    }
    
    return @{IS_SHOW:@"0"};
}

@end
