//
//  WSRadioQstView.m
//  WinSFA
//
//  Created by zhangke on 15/2/4.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSRadioQstView.h"
#import "WSRadioOptView.h"


#define RADIOTAG 200

typedef enum
{
    ESourceType_opt,
    ESourceType_ds
}ESourceType;

@interface WSRadioQstView ()

@property (nonatomic, assign) ESourceType  sourceType;
@property (nonatomic, assign) NSInteger         curSelectIndex;         //当前选中的index
@property (nonatomic, strong) NSString          *redisplayContentStr;   //回显内容/Id

@property (nonatomic, strong) NSMutableArray    *optButtonArray;        //存放选项按钮
@property (nonatomic, strong) NSMutableArray    *optNameArray;

@property (nonatomic, strong) NSArray           *sourceArray;           //下拉列表数据源 WSStoreBean or WSDictBean

@end



@implementation WSRadioQstView

-(instancetype)initWithFrame:(CGRect)frame acvtQstObject:(WSAcvtBean_qst*)qst
{
    self=[super initWithFrame:frame];
    if(self){
        self.qst=qst;
        self.curSelectIndex = -1;
        self.optButtonArray=[NSMutableArray array];
        self.optNameArray=[NSMutableArray array];

        NSString *title = nil;
        if ([qst.is_req isKindOfClass:[NSString class]] && [qst.is_req isEqualToString:@"1"]) {
            title = [NSString stringWithFormat:@"%@*",qst.qstName];
        }else{
            title = qst.qstName;
        }
        
        //创建名字Label
        UIFont *font = [UIFont systemFontOfSize:UI_Font];
        CGSize size = [title sizeWithFont:font constrainedToSize:CGSizeMake(frame.size.width, MAXFLOAT)  lineBreakMode:NSLineBreakByWordWrapping];
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, size.height)];
        label.text = title;
        [label setTextColorWithHexStr:qst.color];
        [label setFont:font];
        label.numberOfLines=0;
        label.lineBreakMode=NSLineBreakByWordWrapping;
        [self addSubview:label];
        
        self.height+=size.height;
        
        
        NSMutableArray* dataArray=nil;
        
        if([self.qst.qstType isEqualToString:QST_TYPE_RD]){
            
            NSMutableArray *nameList = [[NSMutableArray alloc] init];
            NSArray *filterArray = [NSArray array];
            if (self.qst.ds && [self.qst.ds isEqualToString:DICTS]) {
                WSDictBeanArray *dbArray = [WSAppData getObjectbyKey:DICTS];
                filterArray = [dbArray getDictsWithFilter:self.qst.filter];
                
                if (filterArray) {
                    [nameList addObjectsFromArray:filterArray];
                }
            } else if ([self.qst.ds isEqualToString:STORE]) {
                
                WSInPlanStoreBean *inPlanStoreArray = [WSAppData getObjectbyKey:INPLANSTORE];
                WSOutPlanStoreBean* outPlanStoreArray = [WSAppData getObjectbyKey:OUTPLANSTORE];
                NSMutableArray *allStore = [NSMutableArray array];
                [allStore addObjectsFromArray:inPlanStoreArray.storesArray];
                [allStore addObjectsFromArray:outPlanStoreArray.storesArray];
                
                if (allStore && self.qst.filter) {
                    [dataArray addObjectsFromArray:allStore];
                }
            }
        }
        
        //查找是否有值要回显
        NSString *defaultSelectName = [self findValueWithDataArray:dataArray];
        //加载界面
        [self initializationOptionViewWithSouceArray:dataArray withRedisplayContent:defaultSelectName];
        
        
        frame.size.height=self.height;
        self.frame=frame;
    }
    
    return self;
}


- (NSString *)findValueWithDataArray:(NSArray *)dataArray
{
    __block NSString *redisSelectName = nil;
    // 选项只有一个 且别填则选中
    if (self.qst.is_req && [self.qst.is_req isEqualToString:@"R"] && self.qst.opt.count == 1) {
        WSAcvtBean_qst_opt *optTmp = [self.qst.opt objectAtIndex:0];
        redisSelectName = optTmp.optName;
    }else {
        
        if ([self.acvtVC nativeRedis]) {
            //从markDictionary中查询选中项
            [self.qst.opt enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                WSAcvtBean_qst_opt *optTmp = obj;
                NSString* key = [NSString stringWithFormat:@"%@,%@",self.qst.acvtQstId, optTmp.optId];
                if ([self.self.acvtVC.markDictionary objectForKey:key]) {
                    redisSelectName = optTmp.optName;
                    *stop = YES;
                }
            }];
        }
        if(!self.acvtVC.isNewAddAcvt){
            //回显服务器数据
            if (!redisSelectName && [self.acvtVC serverRedis]) {
                NSString *value = [self.acvtVC getAcvtDisValueByAcvtQstId:self.qst.acvtQstId];
                if (value && [value length] > 0) {
                    [self.qst.opt enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        WSAcvtBean_qst_opt *optTmp = obj;
                        if ([value isEqualToString:optTmp.optId]) {
                            redisSelectName = optTmp.optName;
                            *stop = YES;
                        }
                    }];
                }
            }
            
            // 兼容回显新增不拜访的历史数据,（回显的是option_tmp的id）
            if (!redisSelectName) {
                NSString *optId = [self.acvtVC.markDictionary objectForKey:self.qst.acvtQstId];
                if (optId) {
                    [self.qst.opt enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        WSAcvtBean_qst_opt *optTmp = obj;
                        if ([optTmp.optId isEqualToString:optId]) {
                            [self.acvtVC.markDictionary removeObjectForKey:self.qst.acvtQstId];
                            redisSelectName = optTmp.optName;
                            *stop = YES;
                        }
                    }];
                }
            }
        }
        //显示默认值
        if (!redisSelectName && self.qst.defaultValue) {
            [self.qst.opt enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                WSAcvtBean_qst_opt *optTmp = obj;
                if ([self.qst.defaultValue isEqualToString:optTmp.optId]) {
                    redisSelectName = optTmp.optName;
                    *stop = YES;
                }
            }];
        }
    }
    return redisSelectName;
}


- (void)initializationOptionViewWithSouceArray:(NSArray*)array withRedisplayContent:(NSString*)redisplayStr
{
    [self.optButtonArray removeAllObjects];
    [self.optNameArray removeAllObjects];
    
    self.sourceArray = array;
    self.redisplayContentStr = redisplayStr;
    if (array) {
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[WSStoreBean class]]) {
                WSStoreBean *storeBean = (WSStoreBean *)obj;
                [self.optNameArray addObject:storeBean.name];
            } else if ([obj isKindOfClass:[WSDictBean class]]) {
                WSDictBean *dictBean = (WSDictBean *)obj;
                [self.optNameArray addObject:dictBean.name];
            }
        }];
        
        self.sourceType = ESourceType_ds;
    }else {
        [self.qst.opt enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSAcvtBean_qst_opt *option_temp = (WSAcvtBean_qst_opt*) obj;
            [self.optNameArray addObject:option_temp.optName];
        }];
        
        self.sourceType = ESourceType_opt;
    }
    
    BOOL isReadOnly = NO;
    if (self.qst.readonly && [self.qst.readonly isEqualToString:@"1"]) {
        isReadOnly = YES;
    }

    int index = 0;
    //创建选择项
    for (int i=0;i<self.optNameArray.count;i++) {
        NSString *name= [self.optNameArray objectAtIndex:i];
        
        WSRadioOptView* radioOptView=[[WSRadioOptView alloc] initWithFrame:CGRectMake(0, self.height, self.width, 40) optName:name tag:RADIOTAG+index];
        [radioOptView.button addTarget:self action:@selector(radioButonclicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if (isReadOnly) {
            [radioOptView.button setUserInteractionEnabled:NO];
        }
        
        [self addSubview:radioOptView];
        [self.optButtonArray addObject:radioOptView];
        
        self.height+=radioOptView.height;
        
    }

    //初始化默认选中项
    self.curSelectIndex = [self calcRedisplaySelectIndex];
    
}


- (void)radioButonclicked:(UIButton*)optionBtn
{
    NSInteger ab_qst_index = (optionBtn.tag-RADIOTAG);
    self.curSelectIndex = ab_qst_index;
}


#pragma mark - private method
-(int) calcRedisplaySelectIndex
{
    __block int selectIndex = -1;
    if (self.redisplayContentStr) {
        //从名字中查找
        [self.optNameArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([self.redisplayContentStr isEqual:obj]) {
                selectIndex = idx;
                *stop = YES;
            }
        }];
        
        if (-1 == selectIndex) {
            //从id查找
            if (ESourceType_opt == self.sourceType) {
                [self.qst.opt enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    WSAcvtBean_qst_opt *option_temp = (WSAcvtBean_qst_opt*) obj;
                    if ([option_temp.optId isEqualToString:self.redisplayContentStr]) {
                        selectIndex = idx;
                        *stop = YES;
                    }
                }];
            }else {
                [self.sourceArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[WSStoreBean class]]) {
                        WSStoreBean *storeBean = (WSStoreBean *)obj;
                        if ([storeBean.Id isEqualToString:self.redisplayContentStr]) {
                            selectIndex = idx;
                            *stop = YES;
                        }
                    } else if ([obj isKindOfClass:[WSDictBean class]]) {
                        WSDictBean *dictBean = (WSDictBean *)obj;
                        if ([dictBean.Id isEqualToString:self.redisplayContentStr]) {
                            selectIndex = idx;
                            *stop = YES;
                        }
                    }
                }];
            }
        }
    }
    
    return selectIndex;
}

-(void)setCurSelectIndex:(NSInteger)curSelectIndexTmp
{
    if (_curSelectIndex != curSelectIndexTmp) {
        _curSelectIndex = curSelectIndexTmp;
        
        [self.optButtonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSRadioOptView *btnTmp = (WSRadioOptView*)obj;
            if (btnTmp.button.tag == (RADIOTAG + _curSelectIndex)) {
                [btnTmp.button setSelected:YES];
            }else {
                [btnTmp.button setSelected:NO];
            }
        }];
        
        if (self.acvtVC && -1 != _curSelectIndex) {
            [self didSelectIndex:_curSelectIndex];
        }
    }
}


#pragma mark - WSRadioButtonViewDelegate method
- (void)didSelectIndex:(NSInteger)selectIndex
{
    [self.acvtVC setIsValueChange:YES];
    self.acvtVC.isModifyData = YES;
    NSString *selectedContent = nil;
    
    if ([self.qst.qstType isEqualToString:QST_TYPE_RD]) {
        id obj = [self.sourceArray objectAtIndex:selectIndex];
        if (obj) {
            NSString *selectObjId = nil;
            if ([obj isKindOfClass:[WSStoreBean class]]) {
                WSStoreBean *storeBean = (WSStoreBean *)obj;
                selectObjId = storeBean.Id;
                selectedContent = storeBean.name;
            } else if ([obj isKindOfClass:[WSDictBean class]]) {
                WSDictBean *dictBean = (WSDictBean *)obj;
                selectObjId = dictBean.Id;
                selectedContent = dictBean.name;
            }
            [self.acvtVC.markDictionary setObject:[NSString stringNotNilWithValue:selectObjId] forKey:self.qst.acvtQstId];
        }
        else {
            [self.acvtVC.markDictionary setObject:@"" forKey:self.qst.acvtQstId];
        }
    }else {
        NSLog(@"l_qst.acvtQstId----%@",self.qst.acvtQstId);
        WSAcvtBean_qst_opt* ab_qst_opt = [self.qst.opt objectAtIndex:selectIndex];
        NSLog(@"ab_qst_opt = %@" ,ab_qst_opt.optName);
        selectedContent =[ab_qst_opt.optName copy];
        
        if([self.qst.qstType isEqualToString:QST_TYPE_R] && [self.qst.opt count]>1)
        {
            NSArray* keys = [self.acvtVC.markDictionary allKeys];
            for(NSString* key in keys)
            {
                // 将key用@","分离 比较qstId
                NSArray* ids = [key componentsSeparatedByString:@","];
                if([self.qst.acvtQstId isEqualToString:[ids objectAtIndex:0]])
                {
                    [self.acvtVC.markDictionary removeObjectForKey:key];
                }
            }
        }
        
        //Note:历史遗留，不明白为啥要这么存；数据上报时有解析，所以本次重构并未修改。
        NSString* key = [NSString stringWithFormat:@"%@%@%@",self.qst.acvtQstId,@",",ab_qst_opt.optId];
        if([self.acvtVC.markDictionary objectForKey:key] == nil) {
            [self.acvtVC.markDictionary setObject:[NSNumber numberWithInt:UITableViewCellAccessoryCheckmark] forKey:key];
        }else {
            NSNumber* markNumber = [self.acvtVC.markDictionary objectForKey:key];
            if([markNumber intValue] == UITableViewCellAccessoryCheckmark) {
                [self.acvtVC.markDictionary removeObjectForKey:key];
            }else {
                [self.acvtVC.markDictionary setObject:[NSNumber numberWithInt:UITableViewCellAccessoryCheckmark] forKey:key];
            }
        }
    }
    
    if (self.qst.script && [self.qst.script length] > 0) {
        NSString *scriptStr = [self.qst.script copy];
        [self.acvtVC loadScriptStr:scriptStr andSelectedItem:selectedContent];
    }
}



@end
