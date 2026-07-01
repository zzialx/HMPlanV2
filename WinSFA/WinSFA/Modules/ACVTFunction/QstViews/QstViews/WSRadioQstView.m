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


@property (nonatomic, strong) NSMutableArray    *optButtonArray;        //存放选项按钮
@property (nonatomic, strong) NSMutableArray    *optNameArray;


@end



@implementation WSRadioQstView
@synthesize redisplayContentStr;
@synthesize sourceArray;
-(instancetype)initWithFrame:(CGRect)frame acvtQstObject:(WSAcvtBean_qst*)qst souceArray:(NSArray*)dataArray redisplayContent:(NSString*)redisplayStr
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
        CGSize size = [title ws_sizeWithFont:font constrainedToWidth:frame.size.width lineBreakMode:NSLineBreakByWordWrapping];
        
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, size.height)];
        label.text = title;
        [label setTextColorWithHexStr:qst.color];
        [label setFont:font];
        label.numberOfLines=0;
        label.lineBreakMode=NSLineBreakByWordWrapping;
        [self addSubview:label];
        
        self.height+=size.height;
        self.sourceArray = dataArray;
        self.redisplayContentStr = redisplayStr ?:qst.defaultValue;
        

    }
    
    return self;
}

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
        CGSize size = [title ws_sizeWithFont:font constrainedToWidth:frame.size.width lineBreakMode:NSLineBreakByWordWrapping];
        
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, size.height)];
        label.text = title;
        [label setTextColorWithHexStr:qst.color];
        [label setFont:font];
        label.numberOfLines=0;
        label.lineBreakMode=NSLineBreakByWordWrapping;
        [self addSubview:label];
        
        self.height+=size.height;
        
    }
    
    return self;
}




- (void)initializationOptionView
{

    if ([self.sourceArray count] > 0) {
        [self.sourceArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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

    //创建选择项
    for (int i=0;i<self.optNameArray.count;i++) {
        NSString *name= [self.optNameArray objectAtIndex:i];
        
        WSRadioOptView* radioOptView=[[WSRadioOptView alloc] initWithFrame:CGRectMake(0, self.height, self.width, 40) optName:name tag:RADIOTAG+i];
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
    
    CGRect rect=self.frame;
    rect.size.height=self.height;
    self.frame=rect;
    
}


- (void)radioButonclicked:(UIButton*)optionBtn
{
    self.isValueChange = YES;
    NSInteger ab_qst_index = (optionBtn.tag-RADIOTAG);
    self.curSelectIndex = ab_qst_index;
}


#pragma mark - private method
-(NSInteger) calcRedisplaySelectIndex
{
    __block NSInteger selectIndex = -1;
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
    
    
            _curSelectIndex = curSelectIndexTmp;
            
            if (self.optButtonArray.count == 1 && _curSelectIndex != -1) {
                
                WSRadioOptView *btnTmp = [self.optButtonArray firstObject];
                
                BOOL selected = btnTmp.button.isSelected ;
                
                [btnTmp.button setSelected:!selected];

            }
            else{
                [self.optButtonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    WSRadioOptView *btnTmp = (WSRadioOptView*)obj;
                    if (btnTmp.button.tag == (RADIOTAG + _curSelectIndex)) {
                        [btnTmp.button setSelected:YES];
                    }else {
                        [btnTmp.button setSelected:NO];
                    }
                }];
                
            }

            if (-1 != _curSelectIndex) {
                [self.delegate didSelectIndex:_curSelectIndex qst:self.qst sourceArray:self.sourceArray];
            }
    
    
    
}


@end
