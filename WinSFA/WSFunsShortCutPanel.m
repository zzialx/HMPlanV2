//
//  WSFunsShortCutPanel.m
//  WinSFA
//
//  Created by winchannel on 15/9/6.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSFunsShortCutPanel.h"
#import "WSJSONBuilder.h"
#import <SDImageCache.h>
#import "WSServerIPList.h"
#import <UIButton+WebCache.h>
#import <UIImageView+WebCache.h>

#define kBTNHeight (INTERFACE_IS_PHONE ? 40.0f : 40.0f)
#define kBTNViewWidth (INTERFACE_IS_PHONE ? 79.0f : 225.0f)
#define kImageViewGap (INTERFACE_IS_PHONE ? 2.0f : 15.0f)
#define kScrollViewLeftSpace kImageViewGap


@interface WSShortCutButton : UIButton

@property (nonatomic , strong) WSFuncsBean *funcsBean;
@property (nonatomic , strong) WSStoreBean *storeBean;
@property (nonatomic , strong) NSIndexPath *indexpath;


@end

@implementation WSShortCutButton

@end

@implementation WSFunsShortCutPanel

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //self.backgroundColor =[UIColor redColor];
        
//        self.imageIDArray =[NSMutableArray array];
//        
//        self.shortCutBtnArray =[NSMutableArray array];
        
        
    }
    
    return self ;
}


- (void)refreshImagesFromFunsBeanArray:(NSArray *)array withStoreBean:(WSStoreBean *)storeBean{
    
    WSServerIPList *svip = [WSAppData getObjectbyKey:SERVERURL];
    WSServerIPController *serverIP =[svip.serverIPArray firstObject];

    NSString *serverIPStr = [serverIP ServerIPString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            
            if ( obj != nil && [obj isKindOfClass:[WSFuncsBean class]]) {
                
                WSFuncsBean *bean = (WSFuncsBean *)obj ;
                
                [self addShortCutButton:bean withStoreBean:storeBean andServerIp:serverIPStr andIndex:idx];
                
            }
            
        }];
    });
}

- (void)addShortCutButton:(WSFuncsBean *)bean  withStoreBean:(WSStoreBean *)storeBean andServerIp:(NSString *)serverIp andIndex:(NSInteger)index{
    LogTrace();
    
    if (bean.opt.isShortCut == nil) {
        return ;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        WSShortCutButton *shortCutBtn = [[WSShortCutButton alloc]initWithFrame:CGRectMake(index *74 , 0, 64, 30)];
        shortCutBtn.backgroundColor = [UIColor clearColor];

        NSString *stringURL = [NSString stringWithFormat:@"%@%@",serverIp,bean.shortCutURL];
        
        stringURL = [stringURL stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];//字符转换
        // TODO 需要使用 统一的下载方式 WSRequestHelper downloadImage
        [shortCutBtn sd_setImageWithURL:[NSURL URLWithString:stringURL] forState:UIControlStateNormal];
        
        shortCutBtn.funcsBean = bean ;
        
        shortCutBtn.storeBean = storeBean ;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedImage:)];
        
        [shortCutBtn addGestureRecognizer:tapGesture];
        
        //[self.shortCutBtnArray addObject:shortCutBtn];
        
        [self addSubview:shortCutBtn];
    });
    
}

- (void)tappedImage:(UIGestureRecognizer *)gestureRecognizer{
    
    UIView *view = [gestureRecognizer view];
    
    if ([view isKindOfClass:[WSShortCutButton class]]) {
        
        WSShortCutButton *shortCutBtn = (WSShortCutButton *)view;
        
        if ([self.delegate respondsToSelector:@selector(funsShortCutPanel:didSelectBtnFuncsBean:withStoreBean:)]) {
            
            [self.delegate funsShortCutPanel:self didSelectBtnFuncsBean:shortCutBtn.funcsBean withStoreBean:shortCutBtn.storeBean];
                   
        }
    }
}


@end
