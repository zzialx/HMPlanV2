//
//  WSTopBannerCycleScrollView.m
//  WinSFA
//
//  Created by HZH on 17/1/9.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSTopBannerCycleScrollView.h"
#import "WSBaseMsgTable.h"
#import "WSMsgsBean_msg.h"
#import "SDCycleScrollView.h"
#import "WSDetalViewController.h"
#import "WSBaseMsgTypeTable.h"
#import "WSMsgsBean.h"

@interface WSTopBannerCycleScrollView () <SDCycleScrollViewDelegate>

@property (nonatomic, strong) NSArray *topMsgBeanArray;
@property (nonatomic, assign) BOOL isUseTitle;


@end

@implementation WSTopBannerCycleScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame withUseTitle:(BOOL)useTitle {
    NSArray *msgObjArray = [[WSBaseMsgTable sharedTable] queryMsgByHeadRail:@"2"];
//    SFA-17388
//    sfa家乐氏（ios）：登录APP，进入首页，后台没有配置置顶的情况下 实际结果：ios顶部banner显示占位图
    BOOL isShowBannerView = [self isShowTopBannnerViewWithMsgObjArray:msgObjArray];
    if (!isShowBannerView) {
        return nil;
    }
    self = [super initWithFrame:frame];
    if (self) {
         _isUseTitle = useTitle;
        [self setupAllViewsWithMsgObjArray:msgObjArray];
    }
    return self;
    
}
- (BOOL)isShowTopBannnerViewWithMsgObjArray:(NSArray *)msgObjArray
{
    if (!msgObjArray || [msgObjArray count] == 0) {
        return NO;
    } else {
        for (WSBaseMsgObject *obj in msgObjArray) {
            WSMsgsBean_msg * subMsgBean = [[WSMsgsBean_msg alloc]initWithObject:obj];
            if ([subMsgBean.url length] > 0) {
                return  YES;
            }
        }
    }
    return NO;
}
- (void)setupAllViewsWithMsgObjArray:(NSArray *)msgObjArray
{
    
    //添加置顶消息
    if ([msgObjArray count] > 0) {
        
        NSMutableArray *msgArray = [NSMutableArray array];
        
        NSMutableArray *imagesURLStrings = [NSMutableArray array];
        NSMutableArray *titleArray = [NSMutableArray array];
        NSMutableArray *titleFrontImageNameArray = [NSMutableArray array];
        
        for (WSBaseMsgObject *obj in msgObjArray) {
            WSMsgsBean_msg * subMsgBean = [[WSMsgsBean_msg alloc]initWithObject:obj];
            subMsgBean.componentMsgs =  [subMsgBean generateComponentMsgsWith:subMsgBean fileUrl:subMsgBean.fileUrl];

            if ([subMsgBean.url length] > 0) {
                
                NSArray *urls = [subMsgBean.url componentsSeparatedByString:@","];
                // SFA 项目 SFA-7756 每条消息 如果有图片只显示第一张图片。与安卓逻辑一致。
//                for (NSString *urlStr in urls) {
                    [imagesURLStrings addObject:[WSHttpURLHelper getImageCompleteURL:[urls firstObject]]];
                    [titleArray addObject:subMsgBean.title];
                    [msgArray addObject:subMsgBean];
//                }
                
                LogInfo(@"首页置顶图url：%@,消息url:%@", [WSHttpURLHelper getImageCompleteURL:[urls firstObject]], subMsgBean.url);
            }else {
                LogInfo(@"首页置顶图消息无url，%@", subMsgBean.title);
            }
        }
        
        for (int i = 0; i < msgArray.count ; i++) {
            
            for (int j=i+1; j<msgArray.count; j++) {
                WSMsgsBean_msg * subMsgBeanI = msgArray[i];
                WSMsgsBean_msg * subMsgBeanJ = msgArray[j];

                if ([subMsgBeanI.Id integerValue] < [subMsgBeanJ.Id integerValue]) {
                    
                    [msgArray exchangeObjectAtIndex:i withObjectAtIndex:j];
                    [imagesURLStrings exchangeObjectAtIndex:i withObjectAtIndex:j];
                    [titleArray exchangeObjectAtIndex:i withObjectAtIndex:j];

                    
                }
                
            }
            
        }
        self.topMsgBeanArray = msgArray;
        //MSTD-4494
        //winSFA标准产品——手机端（ios）首页：去掉banner上的提示语。
        SDCycleScrollViewPageContolAliment  pageContolAliment = SDCycleScrollViewPageContolAlimentCenter;

        if (self.isUseTitle == YES) {
            for (int i = 0; i < [msgArray count]; i ++) {
                [titleFrontImageNameArray addObject:@"icon_loudspeaker"];
            }
            pageContolAliment = SDCycleScrollViewPageContolAlimentRight;
        }
        if ([imagesURLStrings count] > 0) {
            CGFloat titleHeight = 25;
            SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) delegate:self placeholderImage:[UIImage imageForName:@"picture_loading"]];
            cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleCustom;
            cycleScrollView.currentPageDotColor = [UIColor whiteColor]; // 自定义分页控件小圆标颜色
            cycleScrollView.pageDotColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
            cycleScrollView.imageURLStringsGroup = imagesURLStrings;
            cycleScrollView.titlesGroup = self.isUseTitle ? titleArray : nil;
            cycleScrollView.pageControlBottomOffset = -2; // (titleHeight - pageControlHeight) / 2 - 10
            cycleScrollView.autoScrollTimeInterval = 3.0f;
            cycleScrollView.infiniteLoop = YES;
            cycleScrollView.titleLabelHeight = titleHeight;
            cycleScrollView.titleLabelTextFont = [UIFont systemFontOfSize:13];
            cycleScrollView.isShowLine = NO;
            cycleScrollView.pageControlAliment = pageContolAliment;
            cycleScrollView.pageControlDotSize = CGSizeMake(5.0, 5.0);
            
            cycleScrollView.titleLabelBackgroundColor = self.isUseTitle ? ([UIColor colorForKey:@"TopBannerTitleLabelBackgroundColor"] ?  [UIColor colorForKey:@"TopBannerTitleLabelBackgroundColor"] : [[UIColor blackColor] colorWithAlphaComponent:0.7]) :[UIColor clearColor];
            cycleScrollView.titleLabelTextColor =[UIColor colorForKey:@"TopBannerTitleLabelTextColor"] ?  [UIColor colorForKey:@"TopBannerTitleLabelTextColor"] : [UIColor colorWithWhite:1.0 alpha:1.0];
            cycleScrollView.frontImageNameGroup = titleFrontImageNameArray;
            cycleScrollView.titleLabelAndFrontImageLineViewColor =self.isUseTitle ? ([UIColor colorForKey:@"TopBannerTitleLabelSplitLineColor"] ?  [UIColor colorForKey:@"TopBannerTitleLabelSplitLineColor"] : [UIColor colorWithWhite:1.0 alpha:0.9]) : [UIColor clearColor];
            [self addSubview:cycleScrollView];
        }
    }

}

- (UINavigationController*)imy_navigationController
{
    
    UINavigationController* nav = nil;
    
    UIViewController *controller = [self viewController];
    if ([controller isKindOfClass:[WCBaseViewController class]]) {
        WCBaseViewController *baseController = (WCBaseViewController *)controller;
        if (baseController.ownParentViewController) {
            nav = baseController.ownParentViewController.navigationController;
        } else {
            nav = baseController.navigationController;
        }
    }
    
    return nav;
    
}

- (void)topMsgViewTappedWithIndex:(NSInteger)index
{
    WSMsgsBean_msg *msgBean = self.topMsgBeanArray[index];

    WSDetalViewController * detalCtrl = [[WSDetalViewController alloc] init];
    detalCtrl.model = msgBean;
    
    WSBaseMsgTypeObject *typeObj = [[WSBaseMsgTypeTable sharedTable] queryBaseMsgTypeById:msgBean.pid];
    WSMsgsBean *msgTypeBean = [[WSMsgsBean alloc] initWithObject:typeObj];
    if (msgTypeBean) {
        detalCtrl.msgBean = [NSMutableArray arrayWithObject:msgTypeBean];
    }
    
    detalCtrl.hidesBottomBarWhenPushed = YES;
    detalCtrl.isTopBanner = YES;
    [[self imy_navigationController] pushViewController:detalCtrl animated:YES];
}

#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index
{
    
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    if (INTERFACE_IS_PHONE) {
        [self topMsgViewTappedWithIndex:index];
    }else{
        [self.delegate topBannerCycleScrollView:self didSlectItem:self.topMsgBeanArray[index]];
    }
    
}


@end
