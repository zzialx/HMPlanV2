//
//  WSCheckBoxView.m
//  WinSFA
//
//  Created by dujinfeng481 on 14/12/22.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSCheckBoxView.h"
#import "UILabel+Additional.h"
#import "WSAcvtBean_qst_opt.h"
#import "WSDictBean.h"

typedef enum
{
    ESourceType_opt,
    ESourceType_ds
}ESourceType;

//#define TITLE_AND_OPTION_SAPCE_HEIGHT   (10)
#define CELL_HEIGHT                     (40)
#define OPTION_LABEL_START_X            (10)

#define UI_BASE_TAG                     (300)

@interface WSCheckBoxView()
@property (nonatomic, assign) id<WSCheckBoxViewDelegate> delegate;
@property (nonatomic, assign) ESourceType       sourceType;
@property (nonatomic, strong) NSMutableArray    *selectedIndexs;         //已经选中的indexs

@property (nonatomic, strong) NSMutableArray    *optButtonArray;        //存放选项按钮
@end

@implementation WSCheckBoxView

- (id)initWithAcvtQstObject:(WSAcvtBean_qst*)qstObj
                      withX:(CGFloat)x
                      withY:(CGFloat)y
                  withWidth:(CGFloat)width
                withReqSign:(BOOL)isSign
     withSelectListDelegate:(id<WSCheckBoxViewDelegate>)delegate
{
    self = [super init];
    if (self) {
        _acvtBeanQstObject = qstObj;
        self.optButtonArray = [NSMutableArray array];
        self.optNameArray = [NSMutableArray array];
        self.selectedIndexs = [NSMutableArray array];
        self.delegate = delegate;
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        if (isSign) {
            NSString *title = nil;
            if ([qstObj.is_req isKindOfClass:[NSString class]] && [qstObj.is_req isEqualToString:@"1"]) {
                title = [NSString stringWithFormat:@"%@*",qstObj.qstName];
            }else{
                title = qstObj.qstName;
            }
            
            //创建名字Label
            UIFont *font = [UIFont systemFontOfSize:UI_Font];
            CGSize size = [title ws_sizeWithFont:font constrainedToWidth:width lineBreakMode:NSLineBreakByWordWrapping];
            
            UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width,  size.height)];
            lable.backgroundColor = kCLEAR_COLOR_value;
            lable.text = title;
            [lable setTextColorWithHexStr:qstObj.color];
            [lable setFont:font];
            [self addSubview:lable];
            
            [self setFrame:CGRectMake(x, y, width, size.height)];
        }else {
            [self setFrame:CGRectMake(x, y, width, 0)];
        }
    }
    
    return self;
}

- (void) initializationOptionViewWithSouceArray:(NSArray*)array
                           withRedisplayContents:(NSArray*)redisplayStrs
{
    [self.optButtonArray removeAllObjects];
    [self.optNameArray removeAllObjects];
    [self.selectedIndexs removeAllObjects];
    _sourceArray = array;
    
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
        
        [self.acvtBeanQstObject.opt enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSAcvtBean_qst_opt *option_temp = (WSAcvtBean_qst_opt*) obj;
            [self.optNameArray addObject:option_temp.optName];
        }];
        
        self.sourceType = ESourceType_opt;
    }
    
    BOOL isReadOnly = NO;
    if (self.acvtBeanQstObject.readonly && [self.acvtBeanQstObject.readonly isEqualToString:@"1"]) {
        isReadOnly = YES;
    }
    
    // 根据qstType设置不同的图片 分为多选和单选
    UIImage *normal_img = [UIImage scaledImageForName:@"icn_nocheck" ofType:@"png"];
    UIImage *selected_img = [UIImage scaledImageForName:@"icn_check" ofType:@"png"];
    
    CGFloat startY = CGRectGetHeight(self.frame);
    UIFont *font = [UIFont systemFontOfSize:UI_Font];
    int index = 0;
    //创建选择项
    for (NSString *name in self.optNameArray) {
        
        CGFloat textHeight = CELL_HEIGHT;
        
        CGSize textSize = [name ws_sizeWithFont:font constrainedToWidth:self.frame.size.width - normal_img.size.width - 2 * OPTION_LABEL_START_X lineBreakMode:NSLineBreakByWordWrapping];
        
        if (textSize.height > textHeight) {
            textHeight = textSize.height;
        }
        
        UILabel *optionNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(OPTION_LABEL_START_X, startY, self.frame.size.width - normal_img.size.width - 2 * OPTION_LABEL_START_X, textHeight)];
        optionNameLabel.font = font;
        optionNameLabel.adjustsFontSizeToFitWidth = YES;
        [optionNameLabel setTextColor:[UIColor blackColor]];
        [optionNameLabel setBackgroundColor:[UIColor clearColor]];
        [optionNameLabel setText:name];
        optionNameLabel.numberOfLines = 0;
        optionNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        //        [optionNameLabel sizeToFit];
        
        
        
        // 选项按钮 ...
        UIButton    *option_btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [option_btn setTag:UI_BASE_TAG+index];
        [option_btn addTarget:self action:@selector(checkBoxlicked:) forControlEvents:UIControlEventTouchUpInside];
        
        option_btn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
        [option_btn setImage:normal_img forState:UIControlStateNormal];
        [option_btn setImage:selected_img forState:UIControlStateSelected];
        
        float y_offset;
//        float buttonLeft=60.0f;
//        if( [[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad){
//            buttonLeft=110.0f;
//        }
        y_offset = 4;
        if( [[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad){
//            self.bounds.size.width - 350.f
            option_btn.frame = CGRectMake(0, startY + (textHeight - normal_img.size.height) / 2, self.bounds.size.width, normal_img.size.height);
        }else{
//            CGRectGetMaxX(optionNameLabel.frame)
             option_btn.frame = CGRectMake(0, startY + (textHeight - normal_img.size.height) / 2, self.bounds.size.width, normal_img.size.height);
        }
        if (isReadOnly) {
            [option_btn setUserInteractionEnabled:NO];
        }
        
        [self addSubview:optionNameLabel];
        [self addSubview:option_btn];
        [self.optButtonArray addObject:option_btn];
        
        startY += textHeight;
        ++index;
    }
    
    CGRect rect = self.frame;
    
    rect.size.height = startY;
    
    [self setFrame:rect];
    
    //初始化默认选中项
    [self calcRedisplaySelectIndex:redisplayStrs];
    
}

#pragma mark - action method
- (void)checkBoxlicked:(UIButton*)optionBtn
{
    _isValueChange = YES;
    
    NSInteger ab_qst_index = (optionBtn.tag-UI_BASE_TAG);
    [optionBtn setSelected: !optionBtn.selected];
    
    if (optionBtn.isSelected) {
        [self.selectedIndexs addObject:[NSNumber numberWithInteger:ab_qst_index]];
    }else {
        [self.selectedIndexs removeObject:[NSNumber numberWithInteger:ab_qst_index]];
    }
    
    if (self.delegate) {
        [self.delegate checkBoxView:self didSelectIndexs:self.selectedIndexs];
    }
}

#pragma mark - private method
-(void) calcRedisplaySelectIndex:(NSArray*)redisplayContentStr
{
    [redisplayContentStr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *redisplay = obj;
        __block BOOL isFind = NO;
        
        //从名字中查找
        [self.optNameArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([redisplay isEqual:obj]) {
                [self.selectedIndexs addObject:[NSNumber numberWithInteger:idx]];
                UIButton *btnTmp = [self.optButtonArray objectAtIndex:idx];
                if (btnTmp) {
                    [btnTmp setSelected:YES];
                }
                isFind = YES;
                *stop = YES;
            }
        }];
        
        if (!isFind) {
            //从id查找
            if (ESourceType_opt == self.sourceType) {
                [self.acvtBeanQstObject.opt enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    WSAcvtBean_qst_opt *option_temp = (WSAcvtBean_qst_opt*) obj;
                    if ([option_temp.optId isEqualToString:redisplay]) {
                        [self.selectedIndexs addObject:[NSNumber numberWithInteger:idx]];
                        UIButton *btnTmp = [self.optButtonArray objectAtIndex:idx];
                        if (btnTmp) {
                            [btnTmp setSelected:YES];
                        }
                        *stop = YES;
                    }
                }];
            }else {
                [self.sourceArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[WSStoreBean class]]) {
                        WSStoreBean *storeBean = (WSStoreBean *)obj;
                        if ([storeBean.Id isEqualToString:redisplay]) {
                            [self.selectedIndexs addObject:[NSNumber numberWithInteger:idx]];
                            UIButton *btnTmp = [self.optButtonArray objectAtIndex:idx];
                            if (btnTmp) {
                                [btnTmp setSelected:YES];
                            }
                            *stop = YES;
                        }
                    } else if ([obj isKindOfClass:[WSDictBean class]]) {
                        WSDictBean *dictBean = (WSDictBean *)obj;
                        if ([dictBean.Id isEqualToString:redisplay]) {
                            [self.selectedIndexs addObject:[NSNumber numberWithInteger:idx]];
                            UIButton *btnTmp = [self.optButtonArray objectAtIndex:idx];
                            if (btnTmp) {
                                [btnTmp setSelected:YES];
                            }
                            *stop = YES;
                        }
                    }
                }];
            }
        }
    }];
    
    if (self.delegate && [self.selectedIndexs count] > 0) {
        [self.delegate checkBoxView:self didSelectIndexs:self.selectedIndexs];
    }
}

@end
