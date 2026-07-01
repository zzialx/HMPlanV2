//
//  DateView.m
//  ZYCalendar
//
//  Created by winchannel on 16/10/29.
//  Copyright © 2016年 KangKang. All rights reserved.
//

#import "DateView.h"
#import "DateUtil.h"
#import "WSHttpURLHelper.h"
#import "WSVisitStorePlanTable.h"
#import "WCBaseViewController.h"
#import "WSBaseStoreDBService.h"
#import "WSSubempstoreBeanArray.h"
#import "WSRequestHelper.h"
#import "WSCallPlanViewController.h"
#import "WSStorePlanManager.h"





#define RESTLabelWIDTH (INTERFACE_IS_PHONE ? 15 : 18)

@interface DateView () <CAAnimationDelegate>

@end

@implementation DateView

- (void)setDate:(NSDate *)date{
    
    _date = date;
    
    if (_dateFormatter == nil) {
        _dateFormatter = [NSDateFormatter standardDateFormatter];
        _dateFormatter.dateFormat = @"d";
        
    }
    if (self.dateLabel == nil) {
        
        // MMSH-1822 调整UI并显示选择状态和今日日期的拜访数量值
        CGFloat boundsHeight = self.bounds.size.height;
        CGRect dateLabelFrame = self.bounds;
        dateLabelFrame.origin.y = 2.0;

        dateLabelFrame.size.height = boundsHeight*1/2;
        
        self.dateLabel = [[UILabel alloc] initWithFrame:dateLabelFrame];
        [self.dateLabel setBackgroundColor:[UIColor clearColor]];
        [self.dateLabel setTextAlignment:NSTextAlignmentCenter];
        [self.dateLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
    }

    NSString *dateString = [_dateFormatter stringFromDate:_date];
    [self.dateLabel setText:dateString];
    
    [self addSubview:self.dateLabel];
}
- (void)setState:(DateButtonState)state{
    UIColor *mainTintColor = MAIN_TINT_COLOT;
    if (!mainTintColor) {
        mainTintColor = [UIColor colorWithRed:52.0/255.0 green:170.0/255.0  blue:220.0/255.0  alpha:1];
    }
    
    switch (state) {
        case DateButtonStateNormal:{
            
            DateUtil *dateUtil = [[DateUtil alloc]init];
            NSInteger compDay = [dateUtil getWeekDayFromDate:_date];
            if (compDay == 1 || compDay == 7) {
                [self.dateLabel setTextColor:[UIColor grayColor]];
            }else{
                [self.dateLabel setTextColor:[UIColor blackColor]];
            }
            
            CALayer *selectLayer;
            for (CALayer *layer in self.layer.sublayers) {
                if ([layer.name isEqualToString:@"selectIndentiferLayer"]) {
                    selectLayer = layer;
                    break;
                }
            }
            if (selectLayer) {
//                [self.layer replaceSublayer:selectLayer with:nil];
                [selectLayer removeFromSuperlayer];
            }
        }break;
        case DateButtonStateToday:{
            self.dateLabel.textColor=[UIColor whiteColor];
            CALayer *selectLayer;
            for (CALayer *layer in self.layer.sublayers) {
                if ([layer.name isEqualToString:@"selectIndentiferLayer"]) {
                    selectLayer = layer;
                    break;
                }
            }
            
            if (selectLayer == nil) {
                selectLayer = [CAShapeLayer layer];
                selectLayer.name = @"selectIndentiferLayer";
                CGFloat width = INTERFACE_IS_PHONE ? MIN(self.bounds.size.height, self.bounds.size.width) - 12 : self.bounds.size.height/4*3;
                selectLayer.frame = CGRectMake((self.bounds.size.width - width)/2, (self.bounds.size.height - width)/2, width, width);
                UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2, width/2) radius:width/2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
                ((CAShapeLayer *)selectLayer).path = path.CGPath;
                ((CAShapeLayer *)selectLayer).fillColor = [mainTintColor CGColor];
                ((CAShapeLayer *)selectLayer).strokeColor = [mainTintColor CGColor];
                ((CAShapeLayer *)selectLayer).lineWidth = INTERFACE_IS_PHONE ? 1 : 1;
                [self.layer insertSublayer:selectLayer atIndex:0];
            }
            else
            {
                ((CAShapeLayer *)selectLayer).fillColor = [mainTintColor CGColor];;
                ((CAShapeLayer *)selectLayer).strokeColor = [mainTintColor CGColor];
                ((CAShapeLayer *)selectLayer).lineWidth = INTERFACE_IS_PHONE ? 1 : 1;
                selectLayer.frame = CGRectMake((self.bounds.size.width - selectLayer.frame.size.width)/2, (self.bounds.size.height - selectLayer.frame.size.height)/2, selectLayer.frame.size.width, selectLayer.frame.size.height);
            }
            
            
        }break;
        case DateButtonStateSelected:{
            CALayer *selectLayer;
            for (CALayer *layer in self.layer.sublayers) {
                if ([layer.name isEqualToString:@"selectIndentiferLayer"]) {
                    selectLayer = layer;
                    break;
                }
            }
            if (selectLayer == nil) {
                selectLayer = [CAShapeLayer layer];
                selectLayer.name = @"selectIndentiferLayer";
                CGFloat width = INTERFACE_IS_PHONE ? MIN(self.bounds.size.height, self.bounds.size.width) - 12 : self.bounds.size.height/4*3 ;
                selectLayer.frame = CGRectMake((self.bounds.size.width - width)/2, (self.bounds.size.height - width)/2, width, width);
                UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2, width/2) radius:width/2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
                ((CAShapeLayer *)selectLayer).path = path.CGPath;
                ((CAShapeLayer *)selectLayer).fillColor = [[UIColor clearColor] CGColor];
                ((CAShapeLayer *)selectLayer).strokeColor = [mainTintColor CGColor];
                ((CAShapeLayer *)selectLayer).lineWidth = INTERFACE_IS_PHONE ? 1 : 1;
                [self.layer insertSublayer:selectLayer atIndex:0];
            }
            else
            {
                ((CAShapeLayer *)selectLayer).fillColor = [[UIColor clearColor] CGColor];
                ((CAShapeLayer *)selectLayer).strokeColor = [mainTintColor CGColor];
                ((CAShapeLayer *)selectLayer).lineWidth = INTERFACE_IS_PHONE ? 1 : 1;
                selectLayer.frame = CGRectMake((self.bounds.size.width - selectLayer.frame.size.width)/2, (self.bounds.size.height - selectLayer.frame.size.height)/2, selectLayer.frame.size.width, selectLayer.frame.size.height);
            }
            
            CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            bas.duration=0.4f;
            bas.delegate=self;
            bas.fromValue=[NSNumber numberWithInteger:0];
            bas.toValue=[NSNumber numberWithInteger:1];
            [selectLayer addAnimation:bas forKey:@"bas"];
            
        }break;
            
        default:
            break;
    }
    
    if (self.isExchangeMap && state != DateButtonStateToday) {
        
        DateUtil *dateUtil = [[DateUtil alloc]init];
        NSString  *compDay = [dateUtil getWeekDayEnglishFromDate:_date];
        self.dateLabel.textColor = [UIColor colorForKey:[NSString stringWithFormat:@"%@color",compDay]];
    }
    
}

-(void)removeEventArray:(NSArray *)eventArray{
    NSMutableArray *array = [NSMutableArray array];
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.name isEqualToString:@"eventIndentiferLayer"]) {
            [array addObject:layer];
        }
    }
    for (CALayer *layer in array) {
//        [self.layer replaceSublayer:layer with:nil];
        [layer removeFromSuperlayer];
    }
    
//    for (UIView *view in self.subviews ){
//        if (view.tag == 20) {
//            
//            [view removeFromSuperview];
//        }
//        
//    }
    
}

- (void)setEventArray:(NSArray *)eventArray{
    
    
    NSMutableArray *array = [NSMutableArray array];
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.name isEqualToString:@"eventIndentiferLayer"]) {
            [array addObject:layer];
        }
    }
    
    for (CALayer *layer in array) {
//        [self.layer replaceSublayer:layer with:nil];
        [layer removeFromSuperlayer];
    }
    
    for (UIView *view in self.subviews ){
        if (view.tag == 20) {
            
            [view removeFromSuperview];
        }
        
    }
    
    UIColor *mainTintColor = MAIN_TINT_COLOT;
    if (!mainTintColor) {
        mainTintColor = [UIColor colorWithRed:0.0 green:156.0/255.0 blue:229.0/255.0 alpha:1.0];
    }
    NSDateFormatter *dateFormat = [NSDateFormatter standardDateFormatter];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
//    NSArray *storeObjects = [[WSVisitStorePlanTable sharedTable] queryVisitStorePlanByDate:[dateFormat stringFromDate:_date]];
    
    NSInteger visitedStoreCount = [[WSVisitStorePlanTable sharedTable] queryVisitStorePlanCountByDate:[dateFormat stringFromDate:_date] withStoreIds:[self getFilteredStoreIds]];
    
    if([WSStorePlanManager sharedInstance].storePlanArr)
    {
        visitedStoreCount = 0;
        for (NSDictionary *dic in [WSStorePlanManager sharedInstance].storePlanArr) {
            if ([[dic objectForKey:@"doc_date"] isEqualToString:[dateFormat stringFromDate:_date]] && [[self getFilteredStoreIds] rangeOfString:[NSString stringWithFormat:@"%@",[dic objectForKey:@"store_id"]]].location != NSNotFound) {
                visitedStoreCount++;
            }
        }
    }
    
    if ([[dateFormat stringFromDate:self.date]
          isEqualToString:[dateFormat stringFromDate:[NSDate date]]]) {
        mainTintColor = [UIColor whiteColor];
    }
    
   
        CGFloat boundsHeight = self.bounds.size.height;
        UILabel *countLabel = [[UILabel  alloc]initWithFrame:CGRectMake((self.width-RESTLabelWIDTH)/2, /*(self.height-RESTIMAGEWIDTH)*/boundsHeight*1/2, RESTLabelWIDTH, RESTLabelWIDTH)];
        countLabel.tag = 20;
        countLabel.text = @"";
        if (/*![[dateFormat stringFromDate:self.date]
         isEqualToString:[dateFormat stringFromDate:[NSDate date]]] && */visitedStoreCount > 0) {
             countLabel.text = [NSString stringWithFormat:@"%ld",(unsigned long)visitedStoreCount];
         }
        countLabel.textAlignment = NSTextAlignmentCenter;
        countLabel.textColor = mainTintColor;
        [countLabel setFont:[UIFont systemFontOfSize:9]];
        countLabel.layer.cornerRadius = RESTLabelWIDTH/2.0;
        countLabel.layer.borderColor = mainTintColor.CGColor;
        countLabel.layer.borderWidth = 1.0;
        countLabel.backgroundColor = [UIColor clearColor];
        self.labNumber = countLabel;
        [self addSubview:countLabel];
    if (eventArray!=nil) {
        
        if (eventArray && [eventArray count] >0) {
            
            id object = [eventArray firstObject];
            if ([object isKindOfClass:[NSString class]]) {
                NSString *tempObject = (NSString *)object;
                
                if ([tempObject hasPrefix:@"stateUrl"]){
                    
                    UIImageView *imageView = [[UIImageView  alloc]initWithFrame:CGRectMake((self.width/2-RESTIMAGEWIDTH)/2, (self.height/2-RESTIMAGEWIDTH)/2, RESTIMAGEWIDTH, RESTIMAGEWIDTH)];
                    imageView.tag = 20;
                    NSString *imagestr = [tempObject stringByReplacingOccurrencesOfString:@"stateUrl_" withString:@""];
                    imagestr = [WSHttpURLHelper getImageCompleteURL:imagestr];
                    
                    [[WSRequestHelper shareInstance] downloadImageWithUrl:imagestr imageView:imageView];
                    [self addSubview:imageView];
                }
            }
            else{
//                CGFloat width = INTERFACE_IS_PHONE ? 4 : 4;
//                CGFloat widthGap = INTERFACE_IS_PHONE ? 3 : 4;
//                
//                UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2, width/2) radius:width/2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
//                
//                for (int i = 0; i < [eventArray count]; i++) {
//                    
//                    CALayer *layer = [CAShapeLayer layer];
//                    layer.name = @"eventIndentiferLayer";
//                    
//                    float eventPointWidth=eventArray.count*width+(eventArray.count-1)*widthGap;
//                    float firstEventPointX=(self.width-eventPointWidth)/2;
//                    
//                    layer.frame = CGRectMake(firstEventPointX+(width+widthGap)*i , self.bottom - (INTERFACE_IS_PHONE ? 10 : 16), width, width);
//                    ((CAShapeLayer *)layer).path = path.CGPath;
//                    ((CAShapeLayer *)layer).fillColor = [mainTintColor CGColor];
//                    [self.layer addSublayer:layer];
//                }
                
            }
            
        }
        
    }
}

// SFA-11800 加入过滤条件，与列表页拜访数量保持一致


- (NSString *)getFilteredStoreIds
{
    NSString *storeIdsStr = @"";
    
    if ([self.viewController isKindOfClass:[WCBaseViewController class]]) {
        WCBaseViewController *baseVC = (WCBaseViewController *)self.viewController;
        //        SFA-21037
        //        SFA葵花药业--IOS端原生拜访计划中数据保存后，不显示门店数量
        NSArray *keyArray = [baseVC.currentFuncs.ds componentsSeparatedByString:@":"];
        NSString *ds = [keyArray firstObject];

        if([ds isEqualToString:STORE] || [ds isEqualToString:@"stores"]){
            //            WSBaseStoreDBService *baseStoreDBService = [[WSBaseStoreDBService alloc] init];
            NSString *str = @"callPlanstoreBeanIds";
            if ([self.viewController isKindOfClass:[WSCallPlanViewController class]]) {
                WSCallPlanViewController *call = (WSCallPlanViewController*)self.viewController;
                str = [NSString stringWithFormat:@"callPlanstoreBeanIds%@",call.currentFuncs.opt.storeFiletr];
            }
            NSUserDefaults *defaultsManager = [NSUserDefaults standardUserDefaults];
            NSString * callPlanstoreBeanIds = [defaultsManager objectForKey:str];
            if (callPlanstoreBeanIds.length > 0) {
                storeIdsStr =callPlanstoreBeanIds;
            }
        }else{
            
            WSSubempstoreBeanArray* array= [WSAppData getObjectbyKey:SUBEMPSTORES];
            
            for (WSSubempstoreBean *storeBean in array.subempstoreArray) {
                if (storeIdsStr && storeIdsStr.length > 0) {
                    if ([storeIdsStr rangeOfString:storeBean.Id].location == NSNotFound) {
                        storeIdsStr = [NSString stringWithFormat:@"%@,%@", storeIdsStr, storeBean.Id];
                    }
                }else{
                    storeIdsStr = storeBean.Id;
                }
            }
        }
       
    }
    
    return storeIdsStr;
}

- (void)reloadDateViewWithArray:(NSArray *)array{
    
    NSDateFormatter* formatter = [NSDateFormatter standardDateFormatter];
    formatter.dateFormat = @"d";
    
    NSString *weekDay = [formatter stringFromDate:self.date];
    
    if ([array containsObject:self.date]) {
        UIColor *mainTintColor = MAIN_TINT_COLOT;
        if (!mainTintColor) {
            mainTintColor = [UIColor colorWithRed:0.0 green:127.0/255.0 blue:192.0/255.0 alpha:1.0];
        }
        [self.dateLabel setTextColor: mainTintColor];
        
        if ([weekDay integerValue] != 1 && [weekDay integerValue] != 7) {
            UIImageView* imageview=[[UIImageView alloc] initWithFrame:CGRectMake((self.width/2-RESTIMAGEWIDTH)/2, (self.height/2-RESTIMAGEWIDTH)/2, RESTIMAGEWIDTH, RESTIMAGEWIDTH)];
            imageview.image=[UIImage imageForName:@"icon_rest"];
            [self addSubview:imageview];
            imageview.tag=CHILD_MAX;
        }
    }else{
        if ([weekDay integerValue] == 1 && [weekDay integerValue] == 7){
            
            UIImageView* imageview=[[UIImageView alloc] initWithFrame:CGRectMake((self.width/2-RESTIMAGEWIDTH)/2, (self.height/2-RESTIMAGEWIDTH)/2, RESTIMAGEWIDTH, RESTIMAGEWIDTH)];
            imageview.image=[UIImage imageForName:@"icon_work"];
            [self addSubview:imageview];
            imageview.tag=CHILD_MAX;
        }
        
    }
    
}

@end
