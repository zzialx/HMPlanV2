//
//  WSAcvtView.m
//  WinSFA
//
//  Created by winchannel on 15/3/5.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSAcvtView.h"
#import "WSWidgetFactory.h"
#import "I_W_BuildInfo.h"
#import "WSWidget.h"
#import "WSJSONBuilder.h"

//panel ----------------------------
#import "WSDVDropListPanel.h"
#import "WSPushInfoPanel.h"
#import "WSPhotoViewPanel.h"
#import "WSScanListPanel.h"
#import "WSMultiSelectDropListPanel.h"

#import "I_Lua_Executor_Delegate.h"

#import "WSLuaExecutorManager.h"

#import "WSAcvtScrollView.h"

#import "WSAcvtBean.h"

#import "WSDataSourceManager.h"

#import "WSAcvtModel.h"

#import "WSTitleTabView.h"

#import "WSAcvtScrollView.h"

#import "WSSignaturepanel.h"

#import "WSMultiSelectAndSearchDropListPanel.h"

#import "WSEmptyView.h"

#import "I_CascadeRelation.h"

#import "WSVerificationCodePanel.h"
#import "WSMobileTextFiledPanel.h"
#import "WSDateDisplayValue.h"
#import "HYPageView.h"
#import "BaseViewController.h"
#import "WSAcvtGroupViewController.h"
#import "WidgetConstant.h"
#import "WSNumberTextFiledPanel.h"
#import "WSTextViewPanel.h"
#import "WSValidateTextView.h"
#import "WSBaseDictsDBService.h"
#import "WSAcvtModel.h"
#import "WSMapPanel.h"
#import "WSHidedMapPanel.h"
#import "WSANNestedAcvtPanel.h"


#define kTitleWidth    240

#define kTitleHeight    25

#define kAdditionalWidth 20

#define SCAN_TEXT_TAG             102

#define VIDEO_PICKER_TAG          103

#define DATA_TEXT_TAG             104

#define TextLengthMax              19


// 为了跨过系统所用的tag
#define UI_BASE_TAG               2000

#define kDescriptionLabelMaxHeight 100

#define kScanButtonBaseTag 10000

#define kAcvtQstDeleteButtonWidth  (INTERFACE_IS_PAD ? 300.0f : 200.0f)

#define kAcvtQstDeleteButtonHeight (INTERFACE_IS_PAD ?  30.0f : 25.0f)


#define WIDGET_DEFAULT_HIGH 10.0

#define ACVT_INIT_LUA_FUNTION_SETVALUE       @"function setValue("
#define ACVT_INIT_LUA_FUNTION_REFRESHSTATE   @"function refreshState()"
#define ACVT_UPLOAD_LUA_FUNTION_ONSUMIT      @"function onSubmit()"
#define ACVT_UPLOAD_LUA_FUNTION_UPLOAD       @"function upload()"
#define ACVT_UPLOAD_LUA_FUNTION_BLOCK        @"function block()"
#define ACVT_UPLOAD_LUA_FUNTION_ALERTCANCLEACTION       @"function alertCancleAction()"
#define ACVT_INIT_LUA_FUNCTION @"function"
#define ACVT_INIT_LUA_FUNTION_SETVALUE_EVERY   @"function setValueEveryTime("



#define HORIZONTAL_GROUP_VIEW_GAP (INTERFACE_IS_PAD ?  20 : 5)

#define kAcvtTabViewHeight 50

@interface WSAcvtView ()<WSTitleTabViewDelegate,HYPageViewDelegate, MBProgressHUDDelegate>

@property (nonatomic, strong) NSArray *qstArray;

@property (nonatomic, strong) NSMutableArray *qstGroupArray;
@property (nonatomic, strong) NSMutableArray *acvtGroupViewArray;
@property (nonatomic, strong) NSArray *acvtGroupNameArray;
@property (nonatomic, strong) WSAcvtScrollView *currentAcvtView;
@property (nonatomic, weak) WSAcvtView *parentAvctView;
@property (nonatomic, assign) BOOL isExecutingInitLuaScript;
@property (nonatomic, strong) WSWidget *lastNonHiddenWidget;
@property (nonatomic, strong) HYPageView *pageView;
@property (nonatomic, strong) WSTitleTabView *tabView;
@property (nonatomic, strong) UIView *acvtTabView;
@property (nonatomic, strong) NSMutableArray    *tabNameArrayInOrder;
@property (nonatomic, assign) BOOL hasGap;   // MN-988 是否有分隔类型的问题
@property (nonatomic, strong) WSWidget *currentRequiredWidget;
@property (nonatomic , strong) NSArray * vcArray;


-(void)findNextResponseder:(NSObject<I_W_BuildInfo> *)buildInfo andWidget:(WSWidget *)widget;


@end

@implementation WSAcvtView

@synthesize widgetArray,widgetDict;

#ifdef DEBUG
- (void)dealloc
{
    LogTrace();
}
#endif

- (id)initWithFrame:(CGRect)frame andAcvtBean:(WSAcvtBean *)acvtBean{
    
    return [self initWithFrame:frame andAcvtBean:acvtBean qstArray:nil];
}

- (id)initWithFrame:(CGRect)frame andAcvtBean:(WSAcvtBean *)acvtBean qstArray:(NSArray *)qstArray{
    self = [super initWithFrame:frame];
    if (self) {
        UIColor *bgColor = [UIColor colorForKey:@"AcvtViewBackgroundColor"];
        if (!bgColor) {
            bgColor = [UIColor whiteColor];
        }
        self.backgroundColor = bgColor;
        
        __acvtfactory =[WSWidgetFactory shareInstance];
        
        widgetArray =[[NSMutableArray alloc] init];
        
        widgetDict = [[NSMutableDictionary alloc] init];
        
        _widgetDictForLua = [[NSMutableDictionary alloc] init];
        
        _widgetDictForLuaByQstCode =[[NSMutableDictionary alloc]init];
        
        _photoBrowseViewArray = [[NSMutableArray alloc] init];
        
        _photoScanListViewArray = [[NSMutableArray alloc]init];
        
        _valueChangedWidgetDic = [[NSMutableDictionary alloc] init];
        
        _acvtBean = acvtBean;
        
        _positionY = 0;
        
        if (qstArray) {
            _qstArray = qstArray;
        }else {
            _qstArray = acvtBean.qsts;
        }
        
        _isExecutingInitLuaScript = NO;
        
        return self;
    }
    return nil;
}

- (void)layoutSubviews
{

    if (self.isInAcvtTabMode) {
        
        //发现拍照时有问题，view height会一直缩小，忘记当初为什么这样写了，现在觉得没必要，tab模式下，外层的acvtview应该是固定frame的，所以先注掉
        
        return;
    }
    
    CGFloat pos_for_y = self.positionY + MAIN_WIDGET_PADDING / 2;
    CGFloat bottomHeight = 0;
    //  MN-102  蒙牛添加 固定顶部控件和底部控件 add by 支庆
    for (WSWidget * widget in widgetArray) {
        if ([[widget.xbuildInfo getLayout_gravity] isEqualToString:@"top"]) {
            if (((UIScrollView *)self.superview).contentOffset.y == 0) {
                widget.top = pos_for_y;
            }
            pos_for_y += widget.height;
        }
        if ([[widget.xbuildInfo getLayout_gravity] isEqualToString:@"bottom"]) {
             bottomHeight = widget.height;
             if (((UIScrollView *)self.superview).contentOffset.y == 0) {
                widget.top = self.superview.height - bottomHeight;

             }else{
                 widget.top = self.superview.height - widget.height + ((UIScrollView *)self.superview).contentOffset.y;
             }
        }
    }
    
    BOOL isInHorizontalGroup = NO;
    NSInteger horizontalGroupTotalNumber = 0;
    NSInteger horizontalGroupCurrentIndex = 0;
    CGFloat horizontalViewWidth = 0;
    CGFloat horizontalViewMaxHeight = -1;
    CGFloat horizontalGroupCurrentTotalWidth = 0;
    
    if (self.lastNonHiddenWidget) {
        [self.lastNonHiddenWidget setBottomLineLeftPadding:SEPERATE_PADDING_Left];
        [self.lastNonHiddenWidget setBottomLineColor:DETAIL_SEPERATE_LINE_COLOR];
    }
    
    
    for (NSInteger i = 0; i < widgetArray.count; i++) {
        WSWidget *widget = widgetArray[i];
        if ([[widget.xbuildInfo getLayout_gravity] isEqualToString:@"bottom"] || [[widget.xbuildInfo getLayout_gravity] isEqualToString:@"top"]) continue;
        widget.realPercent = 0;
        
        NSMutableDictionary *param = [self getResetWidgetFrameParamWithWidgetqstType:widget];
        CGFloat originX = [param[@"originX"] floatValue];
        CGFloat groupSpace = [param[@"groupSpace"] floatValue];
        BOOL isHandleEND = [param[@"isHandleEND"] boolValue];

        //美赞臣项目急，暂时解决办法，后续应该widget初始位置都为0，在每个widget内部去调整偏移
        if ([[widget.xbuildInfo getWidgetId] isEqualToString:@"TB"]) {

            if ([widgetArray indexOfObject:widget] == 0) {
                pos_for_y = 0;
            }
        }
        
        //BN类型的控件(左右需要预留空白区域 2017-10-27-yuanji-MSTD-6638)
//        BOOL isHandleEND = YES;
//        if([[widget.xbuildInfo getWidgetId] isEqualToString:@"BN"])
//        {
//            originX = MAIN_BIG_PADDING;
//            groupSpace = MAIN_HORIZONTAL_GROUP_SPACE;
//            isHandleEND = NO;
//        }

        if ([[widget.xbuildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_START] && !widget.isHidden) {
            isInHorizontalGroup = YES;
            horizontalGroupCurrentIndex = 0;
            horizontalViewMaxHeight = -1;
            horizontalGroupTotalNumber = 1;
            horizontalGroupCurrentTotalWidth = originX;
            
            CGFloat percent = [[widget.xbuildInfo getWidthPercent] floatValue];
            BOOL stop = NO;

            for (NSInteger k = i + 1; k<[_qstArray count]; k++) {
                //NSObject<I_W_BuildInfo>  *qst = _qstArray[k];

                WSWidget * obj_hwidget=widgetArray[k];
                if ([[obj_hwidget.xbuildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_START]) {
                    break;
                }
                
                if ([[obj_hwidget.xbuildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_INNER] && !obj_hwidget.isHidden) {
                    horizontalGroupTotalNumber++;
                    if (!stop) {
                        percent += [[obj_hwidget.xbuildInfo getWidthPercent] floatValue];
                        
                    }
                }
                if ([[obj_hwidget.xbuildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_END]&& !obj_hwidget.isHidden) {
                    horizontalGroupTotalNumber++;
                    if (!stop) {
                        percent += [[obj_hwidget.xbuildInfo getWidthPercent] floatValue];
                    }
                    stop = YES;
                    break;
                }
            }
            BOOL realStop = NO;

            if (percent < 1.0) {
                LogInfo(@"获取的百分比111=====%f",percent);
                widget.realPercent = [[widget.xbuildInfo getWidthPercent] floatValue]/percent;

                for (NSInteger k = i + 1; k<[_qstArray count]; k++) {
                    //NSObject<I_W_BuildInfo>  *qst = _qstArray[k];
                    WSWidget * obj_hwidget=widgetArray[k];
                  
                    
                    if ([[obj_hwidget.xbuildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_INNER] && !obj_hwidget.isHidden) {
                        if (!realStop) {
                            obj_hwidget.realPercent = [[obj_hwidget.xbuildInfo getWidthPercent]floatValue]/percent;

                        }
                    }
                    if ([[obj_hwidget.xbuildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_END]&& !obj_hwidget.isHidden) {
                        if (!realStop) {
                            obj_hwidget.realPercent = [[obj_hwidget.xbuildInfo getWidthPercent]floatValue]/percent;
                            
                        }
                        realStop = YES;
                        break;
                    }
                }

            }
            LogInfo(@"水平宽度=====%ld",horizontalGroupTotalNumber);
            horizontalViewWidth = (self.frame.size.width - originX * 2 - (horizontalGroupTotalNumber - 1) * groupSpace)/horizontalGroupTotalNumber;
        }
        
        // MN-1018 暂时去掉!widget.isHidden的与条件，因为隐藏控件也需要去其groupname进行位置调整
        if(([[widget.xbuildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_START] || [[widget.xbuildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_INNER] || [[widget.xbuildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_END]) /*&& !widget.isHidden*/){
            isInHorizontalGroup=YES;
        }
        if (isInHorizontalGroup) {

            CGFloat groupItemWidth = horizontalViewWidth;
            CGFloat currentOriginX = originX + horizontalGroupCurrentIndex * (groupItemWidth + groupSpace);
            
            if ([[widget.xbuildInfo getWidthPercent] length] > 0) {
                groupItemWidth = (self.frame.size.width - originX * 2 - (horizontalGroupTotalNumber - 1)*groupSpace) * (widget.realPercent > 0 ?widget.realPercent : [[widget.xbuildInfo getWidthPercent] floatValue]);
                currentOriginX = horizontalGroupCurrentTotalWidth;
            }

            // 一组中的最后一个空间 靠右对齐 (2017-10-27-yuanji-MSTD-6638 有修改)
            if ([[widget.xbuildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_END] && isHandleEND) {
                currentOriginX =  self.frame.size.width - originX * 2 - groupItemWidth;
            }
            
            widget.frame = CGRectMake(currentOriginX, pos_for_y, groupItemWidth, widget.height);
            [widget layoutIfNeeded];
            horizontalGroupCurrentTotalWidth += groupItemWidth + groupSpace;
            
            [self resetHorizontalGroupQstWidgetsFrameWithWidget:widget andCurrentIndexOfWidgetArray:i];
            
        }else {
            widget.frame = CGRectMake(originX, pos_for_y, self.frame.size.width - originX * 2, widget.height);
            horizontalGroupCurrentTotalWidth = 0;
        }

        if (horizontalViewMaxHeight < widget.height && !widget.hidden) {
            horizontalViewMaxHeight = widget.height;
        }
        
        if (!widget.isHidden) {
            horizontalGroupCurrentIndex++;
        }
        
        
        if ([[widget.xbuildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_END]) {
            isInHorizontalGroup = NO;
            horizontalGroupTotalNumber = 0;
            horizontalGroupCurrentIndex = 0;
        }
        
        if ((isInHorizontalGroup && [widgetArray indexOfObject:widget] == [widgetArray count] - 1) ||
            (isInHorizontalGroup && horizontalGroupTotalNumber == 1)) {
            isInHorizontalGroup = NO;
        }
        
    
        if (!widget.hidden && !CGRectEqualToRect(widget.frame, CGRectZero)) {
            
            self.lastNonHiddenWidget = widget;
            
            if (![widget superview]) {
                [self addSubview:widget];
            }
            
            if (!isInHorizontalGroup) {
                pos_for_y += ([[widget.xbuildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_END] ? horizontalViewMaxHeight : widget.size.height);
            }
        
        }
        
        if (widget.hidden && [[widget.xbuildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_END] && horizontalViewMaxHeight > 0) {
            pos_for_y += horizontalViewMaxHeight;
        }
        
        if (!isInHorizontalGroup) {
            horizontalViewMaxHeight = -1;
        }
        
       
    }
    
    
    if (self.lastNonHiddenWidget && INTERFACE_IS_PHONE) {
        [self.lastNonHiddenWidget setBottomLineLeftPadding:0];
        [self.lastNonHiddenWidget setBottomLineColor:MAIN_SEPERATE_LINE_COLOR];
         // SFA-15455  如果之前最后一个空间是 BN BQ类型的有可能会隐藏底部的线条，这里给最后一个控件设置显示底线
        [self.lastNonHiddenWidget setBottomLineHidden:NO];
    }
    //绘制完成后 先设置高度，再执行脚本 MN-4953
    [self buildDisplayContentEndFrame:pos_for_y];
    
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.contentSize.height != self.height) {
            CGFloat contentHeight  = self.height;
            if ([scrollView isKindOfClass:[WSAcvtScrollView class]]) {
                WSAcvtScrollView *acvtScrollView = (WSAcvtScrollView *)scrollView;
               // 如果改变的高度小于0 使用acvtview的高度
                if (acvtScrollView.scrollViewChangeHeight > 0) {
                    contentHeight = self.height + acvtScrollView.scrollViewChangeHeight;
                }
            }
            scrollView.contentSize = CGSizeMake(self.width, contentHeight);
            //监听到嵌套问卷的高度变化，刷新问卷的高度
            if([self.superview.superview.superview.superview.superview.superview.superview.superview isKindOfClass:NSClassFromString(@"WSANNestedAcvtPanel")]){
                WSANNestedAcvtPanel * panel = (WSANNestedAcvtPanel*)self.superview.superview.superview.superview.superview.superview.superview.superview;
                [panel updateANNestFrameWithWithSubview:self height:contentHeight];
            }

        }
    }else if ([self.superview isKindOfClass:[UIView class]]) {
        //        UIView *view = (UIView *)self.superview;
        //        if (view.height != self.height + self.origin.y) {
        //            CGFloat height  = self.height + self.origin.y;
        //
        //            CGRect newFrame = view.frame;
        //            newFrame.size.height = height;
        //            view.frame = newFrame;
        //
        //            [view layoutSubviews];
        //            NSLog(@"////////////// view.frame.size.height = %.1f", view.frame.size.height);
        //        }
    }
    
    /*
    if (changeScrollViewContentOffSet) {
        if ([self.superview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *superScrollView = (UIScrollView *)self.superview;
            superScrollView.contentOffset = CGPointMake(superScrollView.contentOffset.x, superScrollView.contentOffset.y +changeOffSet);
            
        }
    }
     */
}
#pragma mark - 创建问题显示结束设置边框方法
- (void)buildDisplayContentEndFrame:(CGFloat)offY {
    
    CGFloat pos_for_y = offY;
    CGFloat fixHeight = [self dealWithFixHeightWidget];
    if (fixHeight > 0) {
        pos_for_y = fixHeight;
    }
    
    CGRect newFrame = self.frame;
    newFrame.size.height = pos_for_y;
    self.frame = newFrame;
    
}

// MN-702 重新调整调查问卷中横向分组的各个控件的frame，使其显示更为协调
- (void)resetHorizontalGroupQstWidgetsFrameWithWidget:(WSWidget *)widget andCurrentIndexOfWidgetArray:(NSInteger)index
{
    
    
    NSMutableDictionary *param = [self getResetWidgetFrameParamWithWidgetqstType:widget];
    CGFloat originX = [param[@"originX"] floatValue];
    CGFloat groupSpace = [param[@"groupSpace"] floatValue];
    BOOL isHandleEND = [param[@"isHandleEND"] boolValue];
    
//    CGFloat originX = MAIN_WIDGET_PADDING;
//    CGFloat groupSpace = HORIZONTAL_GROUP_VIEW_GAP;
//
//    if ([[widget.xbuildInfo getWidgetId] isEqualToString:@"TB"]) {
//        originX = 0;
//    }
//
//    BOOL isHandleEND = YES;
//    if([[widget.xbuildInfo getWidgetId] isEqualToString:@"BN"])
//    {
//        originX = MAIN_BIG_PADDING;
//        isHandleEND = NO;
//        groupSpace = MAIN_HORIZONTAL_GROUP_SPACE;
//
//    }
    
    if ([[widget.xbuildInfo getGroupName] rangeOfString:HORIZONTAL_GROUP_INNER].location != NSNotFound && !widget.isHidden && ![[widget.xbuildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_START] && ![[widget.xbuildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_END]) {
        
        CGRect widgetFrame = widget.frame;

        CGFloat cOriginX = 0.0;
        if (index - 1 > 0) {
            WSWidget * preWidget=widgetArray[index - 1];
            if ([[preWidget.xbuildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_INNER] ||[[preWidget.xbuildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_START]) {
                if (preWidget.isHidden) {
                    cOriginX = MAIN_BIG_PADDING;
                }else
                    cOriginX = preWidget.frame.origin.x + preWidget.frame.size.width + groupSpace;
                widgetFrame.origin.x = cOriginX;

            }
            
        }
        
        if ([widget isKindOfClass:[WSBaseDropListPanel class]] && [widget.xbuildInfo.getReadOnly isEqualToString:@"1"]) {
            WSBaseDropListPanel *baseDropListPanel =(WSBaseDropListPanel *)widget;
            
            CGFloat dropListStrWidth = [baseDropListPanel.dropListView.title ws_sizeWithFont:DROPLIST_CELL_TEXT_FONT constrainedToHeight:CGRectGetHeight(baseDropListPanel.dropListView.frame)].width + MAIN_BIG_PADDING*2;
            widgetFrame.size.width = dropListStrWidth;
        }
        
        widget.frame = widgetFrame;
        
    }
    
    if ([[widget.xbuildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_END] && isHandleEND) {
        CGFloat cOriginX = 0.0;
        if (index - 1 >= 0) {
            WSWidget * preWidget=widgetArray[index - 1];
            cOriginX = preWidget.frame.origin.x + preWidget.frame.size.width;
        }
        
        CGFloat endWidgetWidth =  self.frame.size.width - originX * 2 - cOriginX;
        
        CGRect widgetFrame = widget.frame;
        widgetFrame.origin.x = cOriginX;
        widgetFrame.size.width = endWidgetWidth;
        widget.frame = widgetFrame;
    }
}
//SFA-24524 zhaodanyang
#pragma mark - 获取组布局参数方法
- (NSMutableDictionary *) getResetWidgetFrameParamWithWidgetqstType :(WSWidget *) widget{
    
    NSString *widgetqstType = [widget.xbuildInfo getWidgetId];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    CGFloat originX = MAIN_WIDGET_PADDING;
    CGFloat groupSpace = HORIZONTAL_GROUP_VIEW_GAP;
    
    if ([widgetqstType isEqualToString:@"TB"]) {
        originX = 0;
    }
    
    BOOL isHandleEND = YES;
    //BN类型的控件(左右需要预留空白区域 2017-10-27-yuanji-MSTD-6638)
    if([widgetqstType isEqualToString:@"BN"])
    {
        originX = MAIN_BIG_PADDING;
        isHandleEND = NO;
        groupSpace = MAIN_HORIZONTAL_GROUP_SPACE;
    }
    //如果问题的displayMode为share，间隔为零。为分享样式
    if ([[widget.xbuildInfo getDisplayMode] isEqualToString:@"share"]) {
        groupSpace = 0;
    }
    [param setObject:[NSString stringWithFormat:@"%f",originX] forKey:@"originX"];
    [param setObject:[NSString stringWithFormat:@"%f",groupSpace] forKey:@"groupSpace"];
    [param setObject:[NSNumber numberWithBool:isHandleEND] forKey:@"isHandleEND"];

    return param;
    
}
- (BOOL)isGapWithBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo {
    return [[buildInfo getAcvtQstType] isEqualToString:QST_TYPE_BQ] || [[buildInfo getAcvtQstType] isEqualToString:QST_TYPE_BO];
}

-(void)buildDisplayContent{
    
    [widgetArray removeAllObjects];
    [widgetDict removeAllObjects];
    [_widgetDictForLua removeAllObjects];
    [_widgetDictForLuaByQstCode removeAllObjects];
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[WSWidget class]]) {
            [view removeFromSuperview];
        }
    }
    
   _qstArray = [self orderByqstGroupName];
    /**
     *  acvt 按tab页形式分组
     */
    NSArray *tabNameArray = [_qstArray valueForKeyPath:@"@distinctUnionOfObjects.tab"];
    if ([tabNameArray count] > 1) {
        
        UIColor *color = [UIColor colorForKey:@"AcvtTabViewTitleBackgroundColor"];
        if (color) {
            self.backgroundColor = color;
            self.superview.backgroundColor = color;
        }
        
        _qstGroupArray = [NSMutableArray array];
        _acvtGroupViewArray = [NSMutableArray array];
        NSMutableArray *tabNameArrayInOrder = [NSMutableArray array];
        self.tabNameArrayInOrder = tabNameArrayInOrder;
        for (int i=0; i<[_qstArray count]; i++) {
            NSObject<I_W_BuildInfo> *buildInfo =[_qstArray objectAtIndex:i];
            
            if ([[buildInfo getTabGroupName] length] > 0) {
                NSMutableArray *groupArray;
                if ([tabNameArrayInOrder containsObject:[buildInfo getTabGroupName]]) {
                    NSInteger index = [tabNameArrayInOrder indexOfObject:[buildInfo getTabGroupName]];
                    groupArray = _qstGroupArray[index];
                }else {
                    [tabNameArrayInOrder addObject:[buildInfo getTabGroupName]];
                    groupArray = [NSMutableArray array];
                    [_qstGroupArray addObject:groupArray];
                }
                
                [groupArray addObject:buildInfo];
            }
        }
        
        if (_qstGroupArray && _qstGroupArray.count >1) {
            if ([self.viewController isKindOfClass:[BaseViewController class]]) {
                BaseViewController *tempViewController = (BaseViewController *)self.viewController;
                tempViewController.isExchangeAcvtModel = NO;
            }
        }
       
      
        
        if (INTERFACE_IS_PHONE) {
            BOOL isSetStyle = NO;
      
            WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
            if ([model.currentFuncs.menuStyle length] > 0) {
                WSBaseDictsDBService *dictService = [[WSBaseDictsDBService alloc] init];
                WSDictBean *menuStyleDict = [dictService queryDictWithID:model.currentFuncs.menuStyle];
                isSetStyle = [self setupAcvtTabViewWithMenuStyle:menuStyleDict.name titleArray:self.tabNameArrayInOrder];
                
            }
            
            if (!isSetStyle) {
                [self setAcvtGroupWithOffsetY:kAcvtTabViewHeight];
                
                [self setHYPageViewWithTitleArray:tabNameArrayInOrder];
            
                self.isInAcvtTabMode = YES;
            }
        } else {
            [self setAcvtGroupWithOffsetY:kAcvtTabViewHeight];
            
            CGFloat x = 0;
            WSTitleTabView *tabView = [[WSTitleTabView alloc] initWithFrame:CGRectMake(x, 0, self.width - 2 * x, kAcvtTabViewHeight) titleArray:tabNameArrayInOrder aligment:WSTitleTabViewAlignmentLeft];
            tabView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            tabView.delegate = self;
            self.tabView = tabView;
            [self addSubview:tabView];
            
            self.acvtTabView = tabView;
            
            self.isInAcvtTabMode = YES;
        }
        
        if (self.pageView) {
            [self currentPageChangedFromOldIndex:-1 toNewIndex:0];
            
        } else if (self.tabView) {
            [self.tabView setSelectedIndex:0];
            
        } else if ([self.acvtTabView isKindOfClass:[WSAcvtTabCollectionView class]]) {
            WSAcvtTabCollectionView *acvtTabView = (WSAcvtTabCollectionView *)self.acvtTabView;
            [acvtTabView setSelectedIndex:0];
            
        }
        
        if (self.isInAcvtTabMode) {
            [self executeLuaScriptWhenInitFinish];
            return;
        }
    }

    
    CGFloat pos_for_y = self.positionY + MAIN_WIDGET_PADDING / 2;
    NSMutableArray *needCascadeRelationArray = [[NSMutableArray alloc] init];
    if (_qstArray.count <1) {
         WSEmptyView *empty = [[WSEmptyView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        [self addSubview:empty];
    }
    
    BOOL isInHorizontalGroup = NO;
    NSInteger horizontalGroupTotalNumber = 0;
    NSInteger horizontalGroupCurrentIndex = 0;
    CGFloat horizontalViewWidth = 0;
    CGFloat horizontalViewMaxHeight = -1;
    CGFloat horizontalGroupCurrentTotalWidth = 0;
 
    //  MN-988 按照安卓逻辑如果存在 Gap 类型的问题则需要设置控件不显示内边距
    for (NSObject<I_W_BuildInfo> *buildInfo in _qstArray) {
        BOOL isGap = [self isGapWithBuildInfo:buildInfo];
        if (isGap) {
            self.hasGap = YES;
            break;
        }
    }
    
    /*
     上一个插件是否无法加载，例如包含 NFC 这样的模块
     */
    BOOL isLastWidgetNotLoad = NO;
    
    for (int i=0; i<[_qstArray count]; i++) {
        
        
        NSObject<I_W_BuildInfo>   *buildInfo = [[_qstArray objectAtIndex:i] copy];
        
        if ([buildInfo getQuestName] == nil) {
            continue;
        }
        
        CGFloat originX = MAIN_WIDGET_PADDING;
        //SFA 项目SFA-22323  【SFA泸州老窖】【iOS】新增打假动作时，问卷显示无数据(后显示数据后，表格初始化配置有隐藏字段，实际却没有隐藏)
//        BOOL isTable = NO;
        /*
         美赞臣项目急，暂时解决办法，后续应该widget初始位置都为0，在每个widget内部去调整偏移
         */
        if ([[buildInfo getWidgetId] isEqualToString:@"TB"]) {
//            isTable = YES;
            originX = 0;
        }
        
        if ([[buildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_START] && ![[buildInfo getIsHidden] isEqualToString:@"1"]) {
            isInHorizontalGroup = YES;
            horizontalGroupCurrentIndex = 0;
            horizontalGroupTotalNumber = 1;
            horizontalGroupCurrentTotalWidth = originX;
            
            for (int k = i + 1; k<[_qstArray count]; k++) {
                NSObject<I_W_BuildInfo>  *qst = _qstArray[k];
                
                if ([[qst getGroupName] isEqualToString:HORIZONTAL_GROUP_START]) {
                    break;
                }
                
                if ([qst getGroupName] && [[qst getGroupName] rangeOfString:HORIZONTAL_GROUP_INNER].location != NSNotFound && ![[qst getIsHidden] isEqualToString:@"1"]) {
                    horizontalGroupTotalNumber++;
                }
                if ([[qst getGroupName] isEqualToString:HORIZONTAL_GROUP_END]) {
                    break;
                }
            }
            
            horizontalViewWidth = (self.frame.size.width - originX * 2 - (horizontalGroupTotalNumber - 1)*HORIZONTAL_GROUP_VIEW_GAP)/horizontalGroupTotalNumber;
        }
        
        CGRect  currentwidgetrect;
        
        if (isInHorizontalGroup) {
            CGFloat groupItemWidth = horizontalViewWidth;
            CGFloat currentOriginX = originX + horizontalGroupCurrentIndex * (groupItemWidth + HORIZONTAL_GROUP_VIEW_GAP);
            
            if ([[buildInfo getWidthPercent] length] > 0) {
                groupItemWidth = (self.frame.size.width - originX * 2 - (horizontalGroupTotalNumber - 1)*HORIZONTAL_GROUP_VIEW_GAP) * [[buildInfo getWidthPercent] floatValue];
                currentOriginX = horizontalGroupCurrentTotalWidth;
            }
            
            currentwidgetrect = CGRectMake(currentOriginX, pos_for_y, groupItemWidth, WIDGET_DEFAULT_HIGH);
            
            horizontalGroupCurrentTotalWidth += groupItemWidth + HORIZONTAL_GROUP_VIEW_GAP;
        }else {
            currentwidgetrect = CGRectMake(originX, pos_for_y, self.frame.size.width - originX * 2, WIDGET_DEFAULT_HIGH);
        }
        
        horizontalGroupCurrentIndex++;
        WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
        
        // 如果是新增问卷，即使isBlock 为 2 也不是都设置为只读---
        // SFA-15623 安卓的编辑调查问卷已经去除编辑按钮，相对于设置问卷只读的逻辑也应去除 add by zhiqing
//        BOOL isNewAcvt = (model.isNewAddAcvt && !(model.updateGenId && [model.updateGenId length] > 0));
        if (model.currentStore.inReadonlyMode ||
            model.currentFuncs.readonly == 1 ||
            [model.currentAcvtBean.isReadonly isEqualToString:@"1"] ||
            [model.currentAcvtBean.parentReadonly isEqualToString:@"1"]/* ||
            ([model.currentAcvtBean.isBlock isEqualToString:@"2"] && !isNewAcvt)*/) {
            [buildInfo setIsReadOnly:@"1"];
            
            /*
             locationType，值有三种：
             0：不允许定位，只显示回显的位置，坐标和地址均为回显位置。（无回显时显示空）（定位按钮不可点击）
             1：自动定位 （缺省值），初始化后自动定位一次（与原有方式一致）
             2：手动定位，初始化后只显示回显位置，坐标和地址均为回显位置，只有手动点击“定位”按钮才定位，手动定位后地址显示为当前位置。（无回显时，初始化时自动定位一次）
             
             整个菜单为只读时，应该设置定位问题locationType为0，因为整个菜单都为只读，肯定不需要定位功能。
             */
            if ([[buildInfo getWidgetId] isEqualToString:QST_TYPE_GF]) {
                [buildInfo setLocationType:@"0"];
            }
        }
        [buildInfo setLayOutInfo:currentwidgetrect]; //设置属性信息
        // MN-988 按照安卓逻辑调整，有 Gap 问题的时候文字不需要内边距
        if (self.hasGap) {
            [buildInfo setIsNoInset:YES];
        }
        
        WSWidget  *widget =[__acvtfactory createWidgetByWidgetInfo:buildInfo];
        widget.store = model.currentStore;
        widget.funcsBean = model.currentFuncs;
        widget.tempEmpId = _acvtBean.empId; //MMSH-8362
        [widget.xbuildInfo setLayOutInfo:widget.frame];
        
        if (isInHorizontalGroup && horizontalViewMaxHeight < widget.height) {
            horizontalViewMaxHeight = widget.height;
        }
        
        if ([[buildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_END]) {
            isInHorizontalGroup = NO;
            horizontalGroupTotalNumber = 0;
            horizontalGroupCurrentIndex = 0;
        }
        
        if ((isInHorizontalGroup && i == [_qstArray count] - 1) ||
            (isInHorizontalGroup && horizontalGroupTotalNumber == 1)) {
            isInHorizontalGroup = NO;
        }
        
        if (widget!=nil) {
            if (isLastWidgetNotLoad && [self isGapWithBuildInfo:buildInfo]) {
                isLastWidgetNotLoad = NO;
                continue;
            }
            isLastWidgetNotLoad = NO;
            
            if (self.lastNonHiddenWidget) {
                if ([self isGapWithBuildInfo:buildInfo] || [[buildInfo getAcvtQstType] isEqualToString:QST_TYPE_BN]) {
                     // BQ, luaButton 问题的上一个控件不需要 BottomLine
                    [self.lastNonHiddenWidget setBottomLineHidden:YES];
                } else if ([widget isKindOfClass:[WSVerificationCodePanel class]] && [self.lastNonHiddenWidget isKindOfClass:[WSMobileTextFiledPanel class]]) {
                    // 验证码控件则设置手机号
                    WSVerificationCodePanel *codePanel = (WSVerificationCodePanel *)widget;
                    WSMobileTextFiledPanel *mobilePanel = (WSMobileTextFiledPanel *)self.lastNonHiddenWidget;
                    [codePanel setMobileTextField:mobilePanel.textField];
                }
            }
            self.lastNonHiddenWidget = widget;
            
            widget.delegate = self;
          
            [widgetDict setObject:widget forKey:[buildInfo getAcvtQstId]]; //存储acvtqstId
            
            // MN-1489  2018-3-29  同一个问卷配置多个问题名称一样的问题时以前的逻辑就不对了
            //  [_widgetDictForLua setObject:widget forKey:[buildInfo getQuestName]];

            NSMutableArray * widgetQstNameArray;
            NSString * qstName = [buildInfo getQuestName];
            if ([_widgetDictForLua objectForKey:qstName]) {
                  widgetQstNameArray = [(NSMutableArray *)[_widgetDictForLua objectForKey:qstName] mutableCopy];
            }else{
                widgetQstNameArray = [[NSMutableArray alloc]init];
            }
            [widgetQstNameArray addObject:widget];
            [_widgetDictForLua setObject:widgetQstNameArray forKey:qstName];
            
            [_widgetDictForLuaByQstCode setObject:widget forKey:[buildInfo getQstCode]];
            [self addSubview:widget];
            
            //if ([[buildInfo getIsHidden] isEqualToString:@"1"] && !isTable)
            if ([[buildInfo getIsHidden] isEqualToString:@"1"]) {

                widget.hidden = YES;
//                SFA-18484 董宏
//                widget.frame = CGRectZero;
                
            }else if (!CGRectEqualToRect(widget.frame, CGRectZero) && !isInHorizontalGroup){
                pos_for_y += [[widget.xbuildInfo getGroupName] isEqualToString:HORIZONTAL_GROUP_END] ? horizontalViewMaxHeight : widget.size.height;
            }
            
            [widgetArray addObject:widget];
        } else {
            isLastWidgetNotLoad = YES;
        }
 
        if ([widget isKindOfClass:[WSPushInfoPanel class]]) {
            WSPushInfoPanel *pushinfo = (WSPushInfoPanel *)widget;
            [pushinfo setParentView:self];
        }
        
        if ([widget isKindOfClass:[WSPhotoViewPanel class]]) {
            WSPhotoViewPanel *photoViewPanel = (WSPhotoViewPanel *)widget;
            [self.photoBrowseViewArray addObject:photoViewPanel];

        }
        
        if ([widget isKindOfClass:[WSScanListPanel class]]) {
            WSScanListPanel *scanListPanel =(WSScanListPanel *)widget;
            [self.photoScanListViewArray addObject:scanListPanel];
        }
        
        if ([[buildInfo getParentQuestionId] length] > 0 && [widget conformsToProtocol:@protocol(I_CascadeRelation)]) {
            [needCascadeRelationArray addObject:widget];
        }
    }
    
    CGFloat fixHeight = [self dealWithFixHeightWidget];
    
    
    if (fixHeight > 0) {
        pos_for_y = fixHeight;
    }
    
    CGRect newFrame = self.frame;
    
    newFrame.size.height = pos_for_y ;
    
    self.frame = newFrame;
    
    if ([needCascadeRelationArray count] > 0) {
        [self initCascadeRelationsWithArray:needCascadeRelationArray];
    }
    
    /*
     与Android统一逻辑，等所有widget加载完成后，先执行问题的脚本，再执行问卷的脚本
     */
    if (!self.parentAvctView) {
        [self executeLuaScriptWhenInitFinish];
    }
   
    
    /*
     前面的脚本可能还会改变问题的只读状态，所以放在这里执行，此时初始化的脚本都已执行完毕。
     */
    
    /* YIHAIKERRY-2870 安卓没有该逻辑，配置不能修改，该方式似乎不太合理，联合利华项目已经废弃，所以屏蔽该逻辑
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    // winSFA MSTD-4623  如果是新增问卷则没有编辑按钮---
    // SFA-15623 安卓的编辑调查问卷已经去除编辑按钮，相对于设置问卷只读的逻辑也应去除 add by zhiqing

//    BOOL isNewAcvt = (model.isNewAddAcvt && !(model.updateGenId && [model.updateGenId length] > 0));
    

    if (model.currentStore.inReadonlyMode ||
        model.currentFuncs.readonly == 1 ||
        [model.currentAcvtBean.isReadonly isEqualToString:@"1"] ||
        [model.currentAcvtBean.parentReadonly isEqualToString:@"1"] /* ||
        ([model.currentAcvtBean.isBlock isEqualToString:@"2"] && !isNewAcvt)* /) {
        for (WSWidget *widget in self.widgetArray) {
            [widget setReadonly:@"1"];
        }
    }
    */
    [self.valueChangedWidgetDic removeAllObjects];
    

}

// YIHAIKERRY-1713 点击空白收键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

- (CGFloat)dealWithFixHeightWidget
{
    CGFloat height = -1;
        
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.hidden = NO"];
    NSArray *nonHiddenWidgetArray = [widgetArray filteredArrayUsingPredicate:predicate];
    //是否只有1个显示的问题
    if ([nonHiddenWidgetArray count] == 1) {
        
        WSWidget *widget = (WSWidget *)[nonHiddenWidgetArray firstObject];
        if ((INTERFACE_IS_PAD && [[widget.xbuildInfo getWidgetId] isEqualToString:@"AN"])
            || [[widget.xbuildInfo getWidgetId] isEqualToString:@"UR"]
            || ([[widget.xbuildInfo getWidgetId] isEqualToString:@"DP"] && [[widget.xbuildInfo getDisplayMode] isEqualToString:@"newStyle"])) {
            widget.frame = self.superview.bounds;
            height = widget.height;
            
            widget.fixedHeight = YES;
        }
    }
    
    return height;
}

- (void)viewWillAppear
{
    for (WSWidget *widget in self.widgetArray) {
        [widget widgetWillAppear];
    }
}

- (void)checkAndExecuteAcvtLuaScript
{
    [self checkAndExecuteAcvtLuaScriptFunctionName:ACVT_INIT_LUA_FUNTION_SETVALUE];
}
- (void)checkAndExecuteAcvtLuaScriptFunctionName:(NSString*)functionName
{
    NSString *luaStr = [WSLuaExecutorManager getSubLuaScriptWith:_acvtBean.luaScript ByFuntionName:functionName];
    if(luaStr.length > 0)
    {
        WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
        
        // MSTD-7731 同步安卓适配脚本逻辑
        if ([_acvtBean.luaScript rangeOfString:@"GetGenId"].location != NSNotFound)
            model.luaExecuteParams = [NSString stringWithFormat:@"GetGenId%@", model.md5];
        
        wsLuaExecutor = [WSLuaExecutorManager shareInstance];
        wsLuaExecutor.sourceType = WSLuaExecuteSourceTypeAcvt;
        wsLuaExecutor.delegate = self;
        [wsLuaExecutor setStoreBean:[WSDataSourceManager sharedInstance].currentActiveModel.currentStore];
        wsLuaExecutor.currentoperator = nil;
        self.isExecutingInitLuaScript = YES;
        if (self.kqArrange) {
            model.luaExecuteParams = [NSString stringWithFormat:@"%@", self.kqArrange];
        }
        LogInfo(@"初始化问卷脚本开始执行，acvtID:%@,acvtName:%@", _acvtBean.acvtId, _acvtBean.acvtName);
    
        //SFA-19722 脚本执行新的逻辑顺序
        if ([functionName isEqualToString:ACVT_INIT_LUA_FUNTION_SETVALUE])
        {
            [wsLuaExecutor executeLuaScript:_acvtBean.luaScript functionName:ACVT_INIT_LUA_FUNTION_SETVALUE params:model.luaExecuteParams];
            //[wsLuaExecutor executeLuaScript:luaStr params:model.luaExecuteParams];
        }
        else if([functionName isEqualToString:ACVT_INIT_LUA_FUNTION_SETVALUE_EVERY])
        {
            [wsLuaExecutor executeLuaScript:_acvtBean.luaScript functionName:ACVT_INIT_LUA_FUNTION_SETVALUE_EVERY params:model.luaExecuteParams];
            //luaStr  = _acvtBean.luaScript;
            //[wsLuaExecutor executeLuaScript:luaStr params:model.luaExecuteParams functionNameExecution:@"setValueEveryTime"];
        }
        
        NSString *luaScriptForrefreshState = [WSLuaExecutorManager getSubLuaScriptWith:_acvtBean.luaScript ByFuntionName:ACVT_INIT_LUA_FUNTION_REFRESHSTATE];
        if ([luaScriptForrefreshState length] > 0)
        {
            [wsLuaExecutor executeLuaScript:_acvtBean.luaScript functionName:ACVT_INIT_LUA_FUNTION_REFRESHSTATE params:model.luaExecuteParams];
            //[wsLuaExecutor executeLuaScript:luaScriptForrefreshState params:model.luaExecuteParams];
        }
        
        /*Jira -    create by sunhongfu 2017-11-17 model.luaExecuteParams值不能置空 脚本走两次就会有问题 第二次数据空了  Jira - SFA-3665时候加的 感觉是无用的操作*/
        //      model.luaExecuteParams = nil;
        self.isExecutingInitLuaScript = NO;
        LogInfo(@"初始化问卷脚本结束执行，acvtID:%@,acvtName:%@", _acvtBean.acvtId, _acvtBean.acvtName);
    }
}
- (void)checkAndExecuteAcvtLuaScriptEvery
{
    [self checkAndExecuteAcvtLuaScriptFunctionName:ACVT_INIT_LUA_FUNTION_SETVALUE_EVERY];
}
- (void)executeLuaScriptWhenInitFinish
{
    // 视图加载成功后问题执行对应方法
    for (WSWidget *widget in self.widgetArray) {
        [widget widgetDidLoadFinish];
    }
    //执行问卷脚本
    if([self isAcvtInitFunction:_acvtBean.luaScript])
    {
        [self checkAndExecuteAcvtLuaScript];
    }
    else
    {
        [self checkAndExecuteAcvtLuaScriptEvery];
    }
    
    for (WSWidget *widget in self.widgetArray) {
        [widget widgetDidExecutedAllInitScript];
    }
}


- (BOOL)checkLuaScriptWhenUpload {
    
    WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
    if ([model isKindOfClass:[WSAcvtModel class]]) {
        [self checkLuaScriptWithFuncName:ACVT_UPLOAD_LUA_FUNTION_ONSUMIT isWithParams:NO];
        return (![WSLuaExecutorManager shareInstance].isErrorFromScript);
    } else {
        LogError(@"Not acvt Model func fc: %@, name: %@", model.currentFuncs.fc, model.currentFuncs.name);
        return YES;
    }
}

- (BOOL)checkLuaScriptOnUpload {
    // 上传的时候执行“function onUpload()”脚本
    return [self checkLuaScriptWithFuncName:ACVT_UPLOAD_LUA_FUNTION_UPLOAD isWithParams:NO];
}

// 上传成功后执行脚本
- (BOOL)checkLuaScriptBlock
{
    return [self checkLuaScriptWithFuncName:ACVT_UPLOAD_LUA_FUNTION_BLOCK isWithParams:NO];
}

-(BOOL)checkLuaScriptWithFuncName:(NSString *)funcName isWithParams:(BOOL)isWithParams {
    
    WSAcvtModel *acvtModel = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    [WSLuaExecutorManager shareInstance].isErrorFromScript = NO;
        
    if (_acvtBean.luaScript && [_acvtBean.luaScript rangeOfString:funcName].location != NSNotFound) {
        
        LogInfo(@"问卷脚本开始执行，acvtID:%@,acvtName:%@", _acvtBean.acvtId, _acvtBean.acvtName);
        
        wsLuaExecutor = [WSLuaExecutorManager shareInstance];
        
        wsLuaExecutor.sourceType = WSLuaExecuteSourceTypeAcvt;
        
        wsLuaExecutor.delegate = self;
        
        wsLuaExecutor.currentoperator = nil;
        
        NSString *luaScriptForsetValue = [WSLuaExecutorManager getSubLuaScriptWith:_acvtBean.luaScript ByFuntionName:funcName];
        if ([luaScriptForsetValue length] > 0)
        {
            //SFA-19722 脚本执行新的逻辑顺序
            if (isWithParams)
            {
//                WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
                //[wsLuaExecutor executeLuaScript:luaScriptForsetValue params:model.luaExecuteParams];
                [wsLuaExecutor executeLuaScript:_acvtBean.luaScript functionName:funcName params:acvtModel.luaExecuteParams];
            }
            else
            {
                [wsLuaExecutor executeLuaScript:_acvtBean.luaScript functionName:funcName params:nil];
                //[wsLuaExecutor executeLuaScript:luaScriptForsetValue];
            }
            LogInfo(@"问卷脚本结束执行，acvtID:%@,acvtName:%@", _acvtBean.acvtId, _acvtBean.acvtName);
            return YES;
        }
        else
        {
            return NO;
        }
    }
    return NO;
}

- (BOOL)isAcvtInitFunction:(NSString *)luaScript
{
    if (!luaScript || [luaScript length] == 0) {
        return NO;
    }
    
    if ([_acvtBean.luaScript rangeOfString:ACVT_INIT_LUA_FUNTION_SETVALUE].location != NSNotFound ||
        [_acvtBean.luaScript rangeOfString:ACVT_INIT_LUA_FUNTION_REFRESHSTATE].location != NSNotFound) {
        return YES;
    }
    
    return NO;
}


- (NSString *)setValueLuaScript:(NSString *)luaScript {
    NSRange range = [[_acvtBean luaScript] rangeOfString:ACVT_INIT_LUA_FUNTION_SETVALUE];
    if (range.location != NSNotFound) {
        return  [_acvtBean.luaScript substringFromIndex:range.location];
    }
    return nil;
}


- (NSObject *)getPrepareDeleteAcvtNewStoreSubmitData {
    NSMutableDictionary  *resultdict=[[NSMutableDictionary alloc] init];
    
    for (int i=0; i<[widgetArray count]; i++) {
        
        WSWidget *widget= [widgetArray objectAtIndex:i];
        
        if ([widget xbuildInfo]!=nil) {
            
            NSObject<I_W_BuildInfo>   *buildInfo = [widget xbuildInfo];
            
            NSString *luaScript = [buildInfo getLuaScript];
            
            if ([luaScript length] > 0 && [luaScript rangeOfString:@"deleteStoreAction"].location != NSNotFound) {
                
                NSString *key =[NSString stringWithFormat:@"%@%@",[buildInfo getWidgetId],[buildInfo getAcvtQstId]];
                
                NSObject *value = [widget getResultDirectly];
                
                if (value) {
                    [resultdict setObject:value forKey:key];
                    break;
                }
            }
            
        }
    }
    return resultdict;
}


- (BOOL)widgetsHasValue {
    
    if ([widgetArray count] == 0) {
        return  YES;
    }
    
    BOOL hasValue = NO;
 
    for (int i=0; i<[widgetArray count]; i++) {
        
        WSWidget *widget= [widgetArray objectAtIndex:i];
        
        if ([widget xbuildInfo]!=nil) {
            
            NSObject *value = [widget getResultDirectly];
            if (value == nil) {
                continue;
            }
            if ([value isKindOfClass:[NSString class]]) {
                if (value && [(NSString *)value length] > 0) {
                    hasValue = YES;
                    break;
                }
            }else if ([value isKindOfClass:[NSDictionary class]]) {
                if (value && [[(NSDictionary *)value allValues] count] > 0) {
                    hasValue = YES;
                    break;
                }
            }else if ([value isKindOfClass:[NSArray class]]) {
                if (value && [(NSArray *)value count] > 0) {
                    hasValue = YES;
                    break;
                }
            }
            
            
        }
    }
    
    
    
    return hasValue;
    
}

- (NSArray *)getAllData{
    
//    SFA-21393
//    SFA-立白-ios-经销商拜访-微信分享
    NSMutableArray  *resultArray = [[NSMutableArray alloc] init];
    NSMutableArray  *shareWechatWidgetArray = [[NSMutableArray alloc] init];
    for (WSWidget *widget in widgetArray) {
        NSObject<I_W_BuildInfo>   *buildInfo = [widget xbuildInfo];
        if ([widget xbuildInfo]!=nil && [[buildInfo getAcvtMemo3] isEqualToString:@"shareWechat"]) {
            [shareWechatWidgetArray addObject:widget];
        }
    }
    for (int i=0; i<[shareWechatWidgetArray count]; i++) {
        
        WSWidget *widget= [shareWechatWidgetArray objectAtIndex:i];
        
        if ([widget xbuildInfo]!=nil) {
            
            NSObject<I_W_BuildInfo>   *buildInfo = [widget xbuildInfo];
            
            NSObject *value = [widget getCurrentValuePresentation] ;
            NSString *orientation = [buildInfo getOrientation];
            NSString *object =[NSString stringWithFormat:@"%@%@%@%@%@%@%@",[buildInfo getQuestName],WeChat_SEPARATOR,[buildInfo getWidgetId],WeChat_SEPARATOR,value,WeChat_SEPARATOR,orientation];

            BOOL isShareWidget = [self getDependonResultWithbuildInfo:buildInfo]; //SFA-28324

            if (value && [(NSString *)value length] && [[buildInfo getAcvtMemo3] isEqualToString:@"shareWechat"] && isShareWidget) {
                [resultArray addObject:object];
            }
        }
    }
    return resultArray;
}

//问题的dependon参数 如果关联了一个widget ，那么这个widget有值，问题才分享 //SFA-28324-2019-02-21
- (BOOL)getDependonResultWithbuildInfo:(NSObject<I_W_BuildInfo>  *)buildInfo {
    
    BOOL isShare = YES;
    
    NSString *dependonQstCode =  [buildInfo getDependon];
    if (dependonQstCode) {
        WSWidget *dependOnWidget = _widgetDictForLuaByQstCode[dependonQstCode];
        if (dependOnWidget) {
            NSObject *dependOnValue = [dependOnWidget getCurrentValuePresentation];
            
            if (dependOnValue == nil || [(NSString *)dependOnValue length] == 0 ) {
                isShare = NO;
            }
        }
        
    }
    return isShare;
}

//写这个方法的目的：DP 类型的问题不上传数据但要保存因为回显要用
-(NSObject *)getAllPrepareSaveDataByIsIgnoreNullValue:(BOOL)isIgnoreNullValue  resultdict:(NSMutableDictionary *)resultdict
{
    NSMutableDictionary *saveQstValuesDic = [[NSMutableDictionary alloc] initWithDictionary:resultdict copyItems:YES];
    for (int i=0; i<[widgetArray count]; i++) {
        
        WSWidget *widget= [widgetArray objectAtIndex:i];
        
        if ([widget xbuildInfo]!=nil) {
            
            NSObject<I_W_BuildInfo>   *buildInfo = [widget xbuildInfo];
            
            NSString *key =[NSString stringWithFormat:@"%@%@",[buildInfo getWidgetId],[buildInfo getAcvtQstId]];
            NSObject *value = nil;
            value =[widget getPrepareSaveData];
            if (value) {
                [saveQstValuesDic setObject:value forKey:key];
            }
            
        }
    }
    return saveQstValuesDic;
}

-(NSObject *)getAllDataAboutQstIdAndValue{
    NSMutableDictionary  *resultdict=[[NSMutableDictionary alloc] init];
    
    for (int i=0; i<[widgetArray count]; i++) {
        
        WSWidget *widget= [widgetArray objectAtIndex:i];
        
        if ([widget xbuildInfo]!=nil) {
            
            NSObject<I_W_BuildInfo>   *buildInfo = [widget xbuildInfo];
            
            NSString *key =[NSString stringWithFormat:@"%@",[buildInfo getQstId]];
            
            NSObject *value = [widget getResultDirectly];
            
            if ([[buildInfo getNeedUploadData] isEqualToString:@"0"]) {
                value = nil;
            }
            
            if (value) {
                [resultdict setObject:value forKey:key];
            }else{
                [resultdict setObject:@"" forKey:key];
            }
            
        }
    }
    return resultdict;
}



#pragma mark - 进离店调查问卷获取数据方法
- (NSMutableDictionary *)getAcvtQstMemoValues {
    
    NSMutableDictionary *resultdict = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < [widgetArray count]; ++i) {
        WSWidget *widget = [widgetArray objectAtIndex:i];
        NSObject<I_W_BuildInfo> *buildInfo = [widget xbuildInfo];
        if (buildInfo) {
            
            if ([widget isKindOfClass:[WSMapPanel class]]) {
                NSMutableDictionary *value = (NSMutableDictionary *)[widget getResultDirectly];
                WSMapPanel *mapPanel = (WSMapPanel *)widget;
                if (mapPanel.isGpsReady) {
                    [value enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        [resultdict setObject:obj forKey:key];
                    }];
                }
            } else if ([widget isKindOfClass:[WSHidedMapPanel class]]) {
                NSMutableDictionary *value = (NSMutableDictionary *)[widget getResultDirectly];
                WSHidedMapPanel *mapPanel = (WSHidedMapPanel *)widget;
                if (mapPanel.isGpsReady) {
                    [value enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        [resultdict setObject:obj forKey:key];
                    }];
                }
            } else {
                NSString *key = [NSString stringWithFormat:@"%@", [buildInfo getAcvtMemo]];
                NSObject *value = [widget getResultDirectly];
                if (key && (![key isEqualToString:@"(null)"])) {
                    if ([key isEqualToString:@"bizDate"]) {
                        [resultdict setObject:[NSString stringNotNilWithValue:value] forKey: key];
                    } else if ([key isEqualToString:@"0"]) {
                        [resultdict setObject:[NSString stringNotNilWithValue:value] forKey:[NSString stringNotNilWithValue:@"memo"]];
                    } else {
                        [resultdict setObject:[NSString stringNotNilWithValue:value] forKey:[NSString stringWithFormat:@"memo%@", key]];
                    }
                }
            }
        }
    }
    
    return resultdict;
}

- (void)readyToUpload {
    for (int i = 0; i < [widgetArray count]; ++i) {
        WSWidget *widget = [widgetArray objectAtIndex:i];
        [widget readyToUpload];
    }
    
}

#pragma mark - 执行内部循环验证
- (BOOL)executeValidate
{
    for (int i = 0; i < [widgetArray count]; ++i)
    {
        WSWidget *widget = [widgetArray objectAtIndex:i];
        if ([widget doValidateForWSWidght] == YES)
            continue;
        else
        {
            if (self.isInAcvtTabMode)
            {
                NSInteger index;
                WSAcvtScrollView *nonValidateView = nil;
                for (UIView *subView in self.acvtGroupViewArray)
                {
                    if ([subView isKindOfClass:[WSAcvtScrollView class]])
                    {
                        WSAcvtScrollView *scrollView = (WSAcvtScrollView *)subView;
                        if ([scrollView.acvtView.widgetArray containsObject:widget])
                        {
                            index = [self.acvtGroupViewArray indexOfObject:scrollView];
                            nonValidateView = scrollView;
                            break;
                        }
                    }
                }
                if (nonValidateView && nonValidateView != self.currentAcvtView)
                    [self selectIndex:index];
            }
            // YIHAIKERRY-1703 SFA益海嘉里 调查问卷上传时必填项未填写时，可自动定位到未填写的问题上
            else
            {
                WSAcvtScrollView *needAutoScrollAcvtScrollView = nil;
                if ([self.superview isKindOfClass:[UIScrollView class]])
                {
                    UIScrollView *scrollView = (UIScrollView *)self.superview;
                    
                    if ([scrollView isKindOfClass:[WSAcvtScrollView class]])
                    {
                        WSAcvtScrollView *acvtScrollView = (WSAcvtScrollView *)scrollView;
                        if ([acvtScrollView.acvtView.widgetArray containsObject:widget])
                            needAutoScrollAcvtScrollView = acvtScrollView;
                    }
                }
                
                if (needAutoScrollAcvtScrollView)
                {
                    CGFloat needFilledWidgetPosY = widget.frame.origin.y;
                    
                    //MN-1432 2018-03-27 原逻辑在注释内 新逻辑内未开放widget第一响应(同安卓一致 如后续需要改功能 特别注意:要将animated设置NO 先动画后第一响应 否则会和IQKeyboardManager有冲突)
                    if((needFilledWidgetPosY + needAutoScrollAcvtScrollView.frame.size.height) < needAutoScrollAcvtScrollView.contentSize.height)
                        [needAutoScrollAcvtScrollView setContentOffset:CGPointMake(0, needFilledWidgetPosY) animated:YES];
                    
                    /*
                     if ([self.viewController isKindOfClass:[BaseViewController class]])
                     {
                     BaseViewController *baseVC = (BaseViewController *)self.viewController;
                     needFilledWidgetPosY = needFilledWidgetPosY - (baseVC.storeNameLabel.origin.y + baseVC.storeNameLabel.size.height);
                     }
                     [widget becomeFirstResponseder];
                     [needAutoScrollAcvtScrollView setContentOffset:CGPointMake(0, needFilledWidgetPosY) animated:YES];
                     **/
                }
            }
            return NO;
        }
    }
    return YES;
}


- (void)hudWasHidden:(MBProgressHUD *)hud
{
    
    [_currentRequiredWidget becomeFirstResponseder];
}


- (NSArray *)doExecuteGroupValidate{
    
    NSMutableArray *noValueArray = [[NSMutableArray alloc]init];
    
    for (int i =0 ; i< [widgetArray count]; i++) {
        
        WSWidget  *widget=[widgetArray objectAtIndex:i];
        
        id qstName =[widget doGroupValidateForWSWidght];
        
        if ( qstName && [qstName isKindOfClass:[NSString class]]) {
            
            NSString *Value =(NSString *)qstName;
            
            if (Value != nil && [Value length] >0) {
                
                [noValueArray addObject:Value];
            }
        }
    }
    return noValueArray;
}

- (BOOL)isValueChange
{
    
    if ([self.valueChangedWidgetDic count] > 0) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Tab 分组
- (BOOL)setupAcvtTabViewWithMenuStyle:(NSString *)menuStyle titleArray:(NSArray *)titleArray {
    if ([menuStyle length] == 0 || [titleArray count] == 0) {
        return NO;
    }
    
    WSAcvtTabCollectionView *acvtTabView = nil;
    BOOL isSuccess = YES;
    if ([menuStyle isEqualToString:FUNCS_MENUSTYLE_LIST]) {
        acvtTabView = [self createAcvtTabSideWithTitleArray:titleArray];

    } else if ([menuStyle isEqualToString:FUNCS_MENUSTYLE_GRID]) {
        acvtTabView = [self createAcvtTabButtonWithTitleArray:titleArray];
        
    } else {
        LogError(@"Acvt Tab Style Not Support");
        isSuccess = NO;
    }
    if (!acvtTabView) {
        isSuccess = NO;
    } else {
        self.acvtTabView = acvtTabView;
    }
    
    return isSuccess;
}

- (WSAcvtTabCollectionView *)createAcvtTabSideWithTitleArray:(NSArray *)titleArray {
    CGFloat width = self.width * SIDE_VIEW_WIDTH_RATIO;
    WSAcvtTabCollectionView * acvtTabView = [[WSAcvtTabCollectionView alloc] initWithFrame:CGRectMake(0, 0, width, SCREEN_HEIGHT) titleArray:titleArray style:WSAcvtTabStyleSide];
    
    self.isInAcvtTabMode = NO;
    return acvtTabView;
}

- (WSAcvtTabCollectionView *)createAcvtTabButtonWithTitleArray:(NSArray *)titleArray {
    if ([_qstGroupArray count] == 0) {
        return nil;
    }

    BOOL isSuccess = [self createGroupArray];
    if (!isSuccess) {
        return nil;
    }
    
    WSAcvtGroupViewController *groupController = [[WSAcvtGroupViewController alloc] initWithGroupNameArray:self.acvtGroupNameArray[0] acvtViewArray:self.acvtGroupViewArray[0]];
    if (!groupController) {
        return nil;
    }
    
    if (self.acvtViewDelegate) {
        [self.acvtViewDelegate addChildVC:groupController isResetOffset:NO];
    }
    [groupController.view setFrame:self.bounds];
    [self addSubview:groupController.view];
    
    CGFloat paddingY = 5;
    WSAcvtTabCollectionView *acvtTabView = [[WSAcvtTabCollectionView alloc] initWithFrame:CGRectMake(MAIN_PADDING, paddingY, self.width - 2 * MAIN_PADDING, SCREEN_HEIGHT) titleArray:titleArray style:WSAcvtTabStyleButton];
    
    UIColor *bgColor = [UIColor colorForKey:@"AcvtTabViewTitleBackgroundColor"];
    if (!bgColor) {
        bgColor = [UIColor whiteColor];
    }
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:bgColor];
    [headerView setFrame:CGRectMake(0, 0, self.width, acvtTabView.height + 2 * paddingY)];
    [headerView addSubview:acvtTabView];
    
    [groupController setHeaderView:headerView];
    
    __weak typeof(self) weakSelf = self;
    acvtTabView.selectedAcvtTabBlock = ^(NSInteger index, WSAcvtTabStyle style) {
        if (index < [weakSelf.acvtGroupNameArray count]) {
            [groupController resetGroupNameArray:weakSelf.acvtGroupNameArray[index] acvtViewArray:weakSelf.acvtGroupViewArray[index]];
        }
    };
    
    self.isInAcvtTabMode = YES;
    return acvtTabView;
}

- (BOOL)createGroupArray
{
    NSMutableArray *tempAcvtGroupNameArray = [NSMutableArray array];
    for (NSArray *qstArray in self.qstGroupArray)
    {
        //MN-1728 2018-04-13 修改去重逻辑
        //NSArray *groupNameArray = [qstArray valueForKeyPath:@"@distinctUnionOfObjects.verticalGroupName"];
        NSMutableArray *groupNameArray = [[NSMutableArray alloc] init];
        for(WSAcvtBean_qst *qst in qstArray)
        {
            if([groupNameArray containsObject:qst.verticalGroupName])
                continue;
            [groupNameArray addObject:qst.verticalGroupName];
        }
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        NSMutableArray *tempGroupNameArray = [groupNameArray mutableCopy];
        
        for (NSString *groupName in groupNameArray) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"verticalGroupName = %@", groupName];
            NSArray *filterQstArray = [qstArray filteredArrayUsingPredicate:predicate];
            if ([filterQstArray count] == 0) {
                [tempGroupNameArray removeObject:groupName];
                continue;
            }
            WSAcvtView *acvtView = [[WSAcvtView alloc] initWithFrame:self.bounds andAcvtBean:_acvtBean qstArray:filterQstArray];
            acvtView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            acvtView.parentAvctView = self;
            acvtView.delegate = self.delegate;
            acvtView.acvtViewDelegate = self.acvtViewDelegate;
            [acvtView buildDisplayContent];
            
            [tempArray addObject:acvtView];
            
            [widgetArray addObjectsFromArray:acvtView.widgetArray];
            [_widgetDictForLua addEntriesFromDictionary:acvtView.widgetDictForLua];
            [_widgetDictForLuaByQstCode addEntriesFromDictionary:acvtView.widgetDictForLuaByQstCode];
            [widgetDict addEntriesFromDictionary:acvtView.widgetDict];
            [self.photoBrowseViewArray addObjectsFromArray:acvtView.photoBrowseViewArray];
            
        }
        
        [self.acvtGroupViewArray addObject:tempArray];
        
        [tempAcvtGroupNameArray addObject:groupNameArray];
    }
    
    self.acvtGroupNameArray = [tempAcvtGroupNameArray copy];
    
    if ([self.acvtGroupNameArray count] != [self.acvtGroupViewArray count] || [self.acvtGroupNameArray count] == 0) {
        return NO;
    }
    return YES;
}

- (void)setAcvtGroupWithOffsetY:(CGFloat)offsetY {
    CGFloat x = INTERFACE_IS_PAD ? 15 : 0;
    
    for (NSArray *qstArray in _qstGroupArray) {
        
        WSAcvtScrollView *scrollView = [[WSAcvtScrollView alloc] initWithFrame:CGRectMake(x, offsetY, self.width - 2 * x, self.height - offsetY) andAcvtBean:_acvtBean qstArray:qstArray];
        
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        scrollView.acvtView.parentAvctView = self;
        
        scrollView.acvtView.delegate = self.delegate;
        
        scrollView.acvtView.acvtViewDelegate = self.acvtViewDelegate;
        
        [scrollView.acvtView buildDisplayContent];
        
        if (INTERFACE_IS_PAD) {
            scrollView.acvtView.layer.cornerRadius = 5.0;
            scrollView.acvtView.layer.masksToBounds = YES;
            scrollView.acvtView.clipsToBounds = YES;
            
            scrollView.layer.cornerRadius = 5.0;
            scrollView.layer.masksToBounds = YES;
            scrollView.clipsToBounds = YES;
        }
        
        [_acvtGroupViewArray addObject:scrollView];
        
        [widgetArray addObjectsFromArray:scrollView.acvtView.widgetArray];
        [_widgetDictForLua addEntriesFromDictionary:scrollView.acvtView.widgetDictForLua];
        [_widgetDictForLuaByQstCode addEntriesFromDictionary:scrollView.acvtView.widgetDictForLuaByQstCode];
        [widgetDict addEntriesFromDictionary:scrollView.acvtView.widgetDict];
        [self.photoBrowseViewArray addObjectsFromArray:scrollView.acvtView.photoBrowseViewArray];
    }
}

- (UIView *)getSideSubView {
    return self.acvtTabView;
}

- (CGFloat)getGroupPosYByIndex:(NSInteger)groupIndex {
    if ([self.qstGroupArray count] > groupIndex) {
        NSArray *subArray = self.qstGroupArray[groupIndex];
        if ([subArray count] > 0) {
            NSObject<I_W_BuildInfo> *buildInfo = subArray[0];
        
            WSWidget *widget = [self.widgetDict objectForKey:[buildInfo getAcvtQstId]];
            if (widget) {
                return widget.frame.origin.y;
            }
        }
    }
    
    LogError(@"getGroupPosYByIndex get widget error");
    return 0;
}


#pragma mark -
#pragma mark WSWidgetDelegate method
//执行某类操作
-(void)executeInterAction:(WSInterAction *)interaction{
    
    typeof(delegate) strongDelegate = delegate;
    
    if ([delegate respondsToSelector:@selector(executeAnyOperationWith:)]) {
        
        [delegate executeAnyOperationWith:interaction];
        
    }
    
    strongDelegate = nil;
    
}


//
-(void)reloadWidgetWith:(NSString *)relatedId andCurrentWiget:(WSWidget *)widget{
    
    WSWidget  *relatedWidget =[widgetDict valueForKey:relatedId];
    
    if([relatedWidget respondsToSelector:@selector(reloadDisplayDataWithCertainConditon:)]){
    
        [relatedWidget reloadDisplayDataWithCertainConditon:widget];
    
    }
    
}

- (void)reloadWidgetWithName:(NSString *)relatedWidgetName andValue:(NSObject *)value {
    
//    WSWidget  *relatedWidget =[_widgetDictForLua valueForKey:relatedWidgetName];
    NSArray * wigdetArray = [_widgetDictForLua valueForKey:relatedWidgetName];
    for (WSWidget * relatedWidget in wigdetArray) {
        if([relatedWidget respondsToSelector:@selector(reloadCurrentWidgetWithValue:)]){
            [relatedWidget reloadCurrentWidgetWithValue:value];
        }
    }
}

//控件可能根据需求执行lua脚本
-(void)executeLuaScript:(NSObject<I_W_BuildInfo> *)buildInfo widget:(WSWidget *)widget {
    [self executeLuaScript:buildInfo script:[buildInfo getLuaScript] widget:widget];
}

- (void)executeLuaScript:(NSObject<I_W_BuildInfo> *)buildInfo script:(NSString *)script widget:(WSWidget *)widget {
    return [self executeLuaScript:buildInfo script:script funcName:nil widget:widget];
}

- (void)executeLuaScript:(NSObject<I_W_BuildInfo> *)buildInfo script:(NSString *)script funcName:(NSString *)funcName widget:(WSWidget *)widget {
    
    if (self.parentAvctView) {
        [self.parentAvctView executeLuaScript:buildInfo script:script funcName:funcName widget:widget];
        return;
    }
    //SFA-25434 TO DO 因为这个方法在执行脚本的时候都会走，所以在这里把isErrorFromScript 置为NO
    [WSLuaExecutorManager shareInstance].isErrorFromScript = NO;
    if ((script.length > 0) && ([script rangeOfString:@"function"].location != NSNotFound)) {
        
        LogInfo(@"问题脚本开始执行，acvtQstID:%@,qstName:%@", [buildInfo getAcvtQstId], [buildInfo getQuestName]);
        wsLuaExecutor = [WSLuaExecutorManager shareInstance];
        wsLuaExecutor.delegate = self;
        wsLuaExecutor.sourceType = WSLuaExecuteSourceTypeQst;
        wsLuaExecutor.currentoperator = widget;
        if (funcName && funcName.length > 0) {
            [wsLuaExecutor executeLuaScript:script functionName:funcName params:nil];
        } else {
            [wsLuaExecutor executeLuaScript:script];
        }
        LogInfo(@"问题脚本结束执行，acvtQstID:%@,qstName:%@", [buildInfo getAcvtQstId], [buildInfo getQuestName]);
        
        // YIHAIKERRY-3917 备注: 如果表格上要执行两个问题的脚本的时候估计会有问题
        WSWidget *lastWidget = (WSWidget *)wsLuaExecutor.currentoperator;
        if (lastWidget) {
            wsLuaExecutor.currentoperator = lastWidget;
        }
    }
}

- (BOOL)currentLuaExecuteIsFromAcvt {
    return [WSLuaExecutorManager shareInstance].sourceType == WSLuaExecuteSourceTypeAcvt;
}
- (void)cancleAgreePrivacyPolicyMesage{
    if(self.acvtViewDelegate&&[self.acvtViewDelegate respondsToSelector:@selector(cancleAgreeCollectPrivacyPolicyMesage)]){
        [self.acvtViewDelegate cancleAgreeCollectPrivacyPolicyMesage];
    }
}
- (void)executeGridParamLuaScript:(NSString *)luaScriptStr widget:(WSWidget *)widget {
    if ([luaScriptStr length] > 0) {
        
        wsLuaExecutor = [WSLuaExecutorManager shareInstance];
        wsLuaExecutor.isErrorFromScript = NO;
        wsLuaExecutor.delegate = self;
        wsLuaExecutor.currentoperator = widget;
        [wsLuaExecutor executeLuaScript:luaScriptStr];
    }
}


-(void)executeEditOnEnd:(NSObject<I_W_BuildInfo> *)buildInfo widget:(WSWidget *)widget{
    [self findNextResponseder:buildInfo andWidget:widget];
    
}

- (void)widget:(WSWidget *)widget valueChanged:(BOOL)isValueChangedCompareWithOrigin
{
    if (self.parentAvctView) {
        [self.parentAvctView widget:widget valueChanged:isValueChangedCompareWithOrigin];
        return;
    }
    
    NSString *key = [widget.xbuildInfo getAcvtQstId];
    if (isValueChangedCompareWithOrigin) {
        if (!self.isExecutingInitLuaScript) {
            if (![_valueChangedWidgetDic objectForKey:key]) {
                [_valueChangedWidgetDic setObject:widget forKey:key];
            }
        }
    }else {
        if ([_valueChangedWidgetDic objectForKey:key]) {
            [_valueChangedWidgetDic removeObjectForKey:key];
        }
    }
    if (self.acvtViewDelegate && [self.acvtViewDelegate respondsToSelector:@selector(acvtViewWidget:valueChanged:)]) {
        
        // MN-802 在编辑状态下不执行valueChange，不执行添加产品单元格问卷脚本
//        BOOL isTextEditing = NO;
//
//        if ([widget isKindOfClass:[WSTextFiledPanel class]]) {
//            WSTextFiledPanel *textFiledPanel = (WSTextFiledPanel *)widget;
//            isTextEditing = textFiledPanel.textField.editing;
//        }else if ([widget isKindOfClass:[WSTextViewPanel class]]) {
//            WSTextViewPanel *textViewPanel = (WSTextViewPanel *)widget;
//
//            isTextEditing = textViewPanel.textView.editing;
//        }
//
//        if (!isTextEditing) {
            [self.acvtViewDelegate acvtViewWidget:widget valueChanged:isValueChangedCompareWithOrigin];
//        }
    }

}

#pragma mark - init link depend relationship for DVDropList(多级联动的下拉框单选)

- (void) initCascadeRelationsWithArray:(NSArray*)listArray
{
    if (listArray && [listArray count] > 0) {
        
        //设置连动列表父子节点
        for (id<I_CascadeRelation> cascadeWidget in listArray) {
            
            if ([cascadeWidget getParentQstID]) {
                
                //查找id为parentQstId的对象
                for (WSWidget *widget in self.widgetArray) {
                    
                    if ([widget conformsToProtocol:@protocol(I_CascadeRelation)]) {
                        id<I_CascadeRelation> parent = (id<I_CascadeRelation>)widget;
                        
                        if ([[parent getQstID] isEqualToString:[cascadeWidget getParentQstID]]) {
                            [cascadeWidget setParentWidget:parent];
//                            [parent setSubWidget:cascadeWidget];
                            [parent addSubWidgetObject:cascadeWidget];
                            break;
                        }
                    }
                }
            }
        }
        
        //通过顶部节点初始化连动节点数据及回显数据
        for (WSWidget *widget in self.widgetArray) {
            
            if ([widget conformsToProtocol:@protocol(I_CascadeRelation)]) {
                id<I_CascadeRelation> parent = (id<I_CascadeRelation>)widget;
            
//                if ([parent parentWidget] == nil && [parent subWidget]) {
//
//                    [parent initDataForCascadeRelation:NO];
//
//                }
                
                if ([parent parentWidget] == nil && [parent getAllSubWidget].count) {
                    
                    [parent initDataForCascadeRelation:NO];
                    
                }
            }
            
        }
        

    }
}


- (void)applyData:(WSInterAction *)interAction forExecuteWidget:(NSString *)actv_qust_id
{
    WSWidget  *widget = [widgetDict valueForKey:actv_qust_id];
    
    [widget loadComputeResult:interAction];
    
}


#pragma mark -
#pragma mark  I_Lua_Executor_Delegate

//返回所有name 和 widget的名字映射
-(NSMutableDictionary *)getQstNameAndWidgetMapping{
    return _widgetDictForLua;
}

- (NSMutableDictionary *)getQstCodeAndWidgetMapping{
    
    return _widgetDictForLuaByQstCode;
}

//返回所有 id 和 widget的标示映射
-(NSMutableDictionary *)getQstIdAndWidgetMapping{
    
    return widgetDict;
    
}

//返回所有控件数组
-(NSMutableArray *)getQstWidgetArray{
    
    return widgetArray;
}

- (void)setUploadButtonEnable:(BOOL)isEnable {
    
    if ([self.acvtViewDelegate respondsToSelector:@selector(setUploadButtonEnable:)]) {
        [self.acvtViewDelegate setUploadButtonEnable:isEnable];
    }
}

- (void)setUploadButtonHidden:(BOOL)isHidden {
    
    if ([self.acvtViewDelegate respondsToSelector:@selector(setUploadButtonHidden:)]) {
        [self.acvtViewDelegate setUploadButtonHidden:isHidden];
    }
}


-(void)findNextResponseder:(NSObject<I_W_BuildInfo> *)buildInfo andWidget:(WSWidget *)widget{

    [widget resignFirstResponseder];
    NSInteger  index = [widgetArray indexOfObject:widget];

    NSInteger   nextWidgetIndex = index+1;
    
    while (nextWidgetIndex<= [widgetArray count]-1) {
        
        WSWidget  *widget = [widgetArray objectAtIndex:nextWidgetIndex];
        // YIHAIKERRY-3594
        if ([widget isHidden] || [[widget getReadonly] isEqualToString:@"true"]) {
            nextWidgetIndex++;
            continue;
        }
        
        if ([widget respondsToSelector:@selector(becomeFirstResponseder)]) {
            [widget becomeFirstResponseder];
        }
        break;
        
    }
    
}

- (void)refreshWidgeForType:(NSString *)type {
    for (WSWidget *widget  in  self.widgetArray) {
        if ([[widget.xbuildInfo getAcvtQstType] isEqualToString:type]) {
            [widget reloadCurrentWidgetWithValue:nil];
        }
    }
}



- (NSString *)getAcvtFilledQstsCountByType:(NSString *)qstType {
    
    
    NSInteger filledCount = 0;
    for (WSWidget *widget  in  self.widgetArray) {
        if ([[widget.xbuildInfo getAcvtQstType] isEqualToString:qstType]) {
            
            NSObject *resulet = [widget getResultDirectly];
            if (resulet) {
                filledCount++;
            }
        }
    }
    return [NSString stringWithFormat:@"%ld",(long)filledCount];
}

- (NSString *)getAcvtQstsCountByType:(NSString *)qstType {
    
    NSInteger allCount = 0;
    for (WSWidget *widget  in  self.widgetArray) {
        if ([[widget.xbuildInfo getAcvtQstType] isEqualToString:qstType]) {
            allCount++;
        }
    }
    return [NSString stringWithFormat:@"%ld",(long)allCount];
}

- (void)selectIndex:(NSInteger)index {
    
    if (self.isInAcvtTabMode) {
        if (INTERFACE_IS_PHONE) {
            if ([self.acvtTabView isKindOfClass:[WSAcvtTabCollectionView class]]) {
                WSAcvtTabCollectionView *tabView = (WSAcvtTabCollectionView *)self.acvtTabView;
                [tabView setSelectedIndex:index];
            } else {
                [self.pageView scrollToIndex:index];
            }
        }else {
            [self.tabView setSelectedIndex:index];
        }
    }
}
- (void)hiddenAcvtTab:(NSString *)titleName{
    // MENGNIU-996 非tab模式下不用做任何操作
    if (!self.isInAcvtTabMode) {
        return;
    }
    NSArray * titles = [titleName componentsSeparatedByString:@","];
    for (NSString * title in titles) {
        if ([self.tabNameArrayInOrder containsObject:title]) {
            NSInteger  index = [self.tabNameArrayInOrder indexOfObject:title];
            [self.tabNameArrayInOrder removeObjectAtIndex:index];
            [_acvtGroupViewArray removeObjectAtIndex:index];
        }
    }

    [self setHYPageViewWithTitleArray:self.tabNameArrayInOrder];
    
}
-(void)setHYPageViewWithTitleArray:(NSArray *)titleArray{

    if (self.pageView) {
        [self.pageView removeFromSuperview];
    }
    
    NSMutableArray *vcArray = [NSMutableArray arrayWithCapacity:_acvtGroupViewArray.count];
    for (WSAcvtScrollView *scrollView in _acvtGroupViewArray) {
        WCBaseViewController *con = [[WCBaseViewController alloc] init];
        con.view.frame = self.bounds;
        [con.view addSubview:scrollView];
        scrollView.frame = con.view.bounds;
        ((WCBaseViewController *)con).isPageSegmentView = YES; //MN-1327 2018-03-19
        [vcArray addObject:con];
    }
    self.vcArray = vcArray;
    HYPageView *pageView = [[HYPageView alloc] initWithFrame:self.bounds withTitles:titleArray withViewControllers:vcArray withParameters:nil];
    pageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    pageView.pageDelegate = self;
    pageView.selectedColor = MAIN_TINT_COLOT;
    pageView.unselectedColor = [UIColor blackColor];
    pageView.isScrollViewBounces = NO;
    self.pageView = pageView;
    
    [self addSubview:pageView];

}

- (void)gotoTabWithIndex:(NSInteger)index {
    if (!self.isInAcvtTabMode || index < 0) {
        return;
    }
    [self.pageView scrollToIndex:index];
}


-(NSArray *)orderByqstGroupName{
//    MENGNIU-639  董宏  isNeedUpdata 针对 groupName 里面有@分组的 情况（蒙牛）
    BOOL isNeedUpdata = NO;
    for (WSAcvtBean_qst * qst in _qstArray) {
         NSArray * groupNameArray = [qst.groupName componentsSeparatedByString:@"@"];
        if (groupNameArray.count == 2 ) {
            isNeedUpdata = YES;
            break;
        }
    }
    
    if (!isNeedUpdata) {
        return _qstArray;
    }
    
    NSMutableArray * qstArray = [NSMutableArray arrayWithCapacity:_qstArray.count];
    NSMutableArray * tempArray = [[NSMutableArray alloc]init];
    for (WSAcvtBean_qst * qst in _qstArray) {
        
        if (qst.groupName.length > 0) {
            if ([tempArray containsObject:qst]) {
                continue;
            }else{
               
                if ([qst.groupName hasPrefix:HORIZONTAL_GROUP_START]) {
                    NSArray * groupNameArray = [qst.groupName componentsSeparatedByString:@"@"];
                    NSString * groupNum  = @"";
                    NSString * innerGroupName = HORIZONTAL_GROUP_INNER;
                    NSString * endGroupName = HORIZONTAL_GROUP_END;
                    if (groupNameArray.count == 2) {
                        groupNum = groupNameArray[1];
                        innerGroupName = [NSString stringWithFormat:@"%@@%@",HORIZONTAL_GROUP_INNER,groupNum];
                        endGroupName = [NSString stringWithFormat:@"%@@%@",HORIZONTAL_GROUP_END,groupNum];
                    }
                    
                    [qstArray addObject:qst];
                    for (WSAcvtBean_qst * tempQst in _qstArray) {
                        if ([tempQst.groupName isEqualToString:innerGroupName] || [tempQst.groupName isEqualToString:endGroupName]) {
                            [qstArray addObject:tempQst];
                            [tempArray addObject:tempQst];
                        }
                    }
                }
            }
        }else{
            [qstArray addObject:qst];
        }
        
    }
    
    for (WSAcvtBean_qst  *qst in qstArray) {
        if (qst.groupName && ([qst.groupName rangeOfString:HORIZONTAL_GROUP_START].location != NSNotFound)) {
            qst.groupName = HORIZONTAL_GROUP_START;
        }else if (qst.groupName && ([qst.groupName rangeOfString:HORIZONTAL_GROUP_END].location != NSNotFound)) {
            qst.groupName = HORIZONTAL_GROUP_END;
        }
    }
    
    return qstArray;
}
#pragma mark - WSAcvtTabViewDelegate
- (void)titleTabView:(WSTitleTabView *)acvtTabView didSelectTitleAtIndex:(NSInteger)index
{
    [self.currentAcvtView removeFromSuperview];
    WSAcvtScrollView *view = self.acvtGroupViewArray[index];
    [self addSubview:view];
    self.currentAcvtView = view;
    
    [view.acvtView viewWillAppear];
}

#pragma mark - HYPageViewDelegate

- (void)currentPageChangedFromOldIndex:(NSInteger)oldIndex toNewIndex:(NSInteger)newIndex {
    //  YIHAIKERRY-2418   2018-4-21
    NSLog(@"currentPageChangedFromOldIndex %@",self.viewController);
    WSAcvtScrollView *view = self.acvtGroupViewArray[newIndex];
    self.currentAcvtView = view;
    [view.acvtView viewWillAppear];
    
}
- (NSArray*)getTabNameArrayInOrder
{
    return (NSArray*)self.tabNameArrayInOrder.copy;
}

#pragma mark - 清除问卷数据方法
- (void)celearAcvtData
{
    //MN-2476 2018-05-16 暂时这样设计(先全部重新加载视图 在将I类型数据脚本执行) 后期有优化空间
    [self buildDisplayContent];
    for (int i = 0; i < [widgetArray count]; ++i)
    {
        WSWidget *widget = [widgetArray objectAtIndex:i];
        NSString *widgetType = [widget.xbuildInfo getAcvtQstType];
        if (([widget xbuildInfo] != nil) && [widgetType isEqualToString:@"I"])
            [self executeLuaScript:widget.xbuildInfo script:[widget.xbuildInfo getLuaScript] widget:widget];
    }
}

#pragma mark - 获取问卷视图是否为tab模式方法
- (BOOL)acvtViewIsTabMode
{
    NSArray *tabNameArray = [_qstArray valueForKeyPath:@"@distinctUnionOfObjects.tab"];
    return ((tabNameArray.count > 0) ? YES : NO);
}

- (void)executeLuaScriptCancle
{
    [self executeLuaScriptByFuntionName:ACVT_UPLOAD_LUA_FUNTION_ALERTCANCLEACTION];
}
//要执行的脚本方法
- (void)executeLuaScriptByFuntionName:(NSString *)funtionName {
    
    if (_acvtBean.luaScript && [_acvtBean.luaScript rangeOfString:funtionName].location != NSNotFound) {

        wsLuaExecutor = [WSLuaExecutorManager shareInstance];
        
        wsLuaExecutor.sourceType = WSLuaExecuteSourceTypeAcvt;
        
        wsLuaExecutor.delegate = self;
        
        wsLuaExecutor.currentoperator = nil;

        NSString *luaScriptForsetValue = [WSLuaExecutorManager getSubLuaScriptWith:_acvtBean.luaScript ByFuntionName:funtionName];
        if ([luaScriptForsetValue length] > 0)
        {
            [wsLuaExecutor executeLuaScript:_acvtBean.luaScript functionName:funtionName params:nil];
            return;
        }
    }
}
- (void)uploadImgID
{
    for (WSWidget * widget in widgetArray) {
        
        if ([widget isKindOfClass:[WSPhotoViewPanel class]]) {
            WSPhotoViewPanel *photoViewPanel = (WSPhotoViewPanel *)widget;
            photoViewPanel.randomMD5 = [[WSJSONBuilder gen_uuid] md5];
        }
    }
}

#pragma mark - 非必填项校验提示方法
- (NSMutableDictionary *)notReqCheckTip {
    
    NSMutableDictionary *allDic = [[NSMutableDictionary alloc] init];
    for (WSWidget *widget in self.widgetArray) {
        NSMutableDictionary *widgetDic = [widget getNotReqTipData];
        for (NSString *key in widgetDic.allKeys) {
            NSInteger number = [[allDic objectForKey:key] integerValue];
            number += [[widgetDic objectForKey:key] integerValue];
            [allDic setObject:[NSNumber numberWithInteger:number] forKey:key];
        }
    }
    return allDic;
}

#pragma mark - 获取问卷非必填校验数据方法
- (NSMutableDictionary *)getAcvtNotReqCheckTipData {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    for (WSWidget *widget in widgetArray) {
        
        BOOL showWidget = (widget.isHidden) ? NO : YES;
        NSString *widgetCheckType = [widget.xbuildInfo getCheckType];
        NSObject *resulet = [widget getResultDirectly];
        if (showWidget && widgetCheckType.length > 0 && !resulet) {
            
            NSString *qstType = [widget.xbuildInfo getAcvtQstType];
            NSInteger number = [[dic objectForKey:qstType] integerValue];
            number++;
            [dic setObject:[NSNumber numberWithInteger:number] forKey:qstType];
        }
    }
    return dic;
}










#pragma mark - 获取所有已准备好的数据
- (NSObject *)getAllPrepareSubmitData {
    
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    BOOL isIgnoreNullValue = (model.currentFuncs.nullvalue == 1) ? NO : YES;
    return [self getAllPrepareSubmitDataByIsIgnoreNullValue:isIgnoreNullValue];
}

#pragma mark - 获取全部准备提交数据方法
- (NSObject *)getAllPrepareSubmitDataByIsIgnoreNullValue:(BOOL)isIgnoreNullValue {
    
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    NSMutableDictionary *resultdict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *photonameDict = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < [widgetArray count]; i++) {
        
        WSWidget *widget = [widgetArray objectAtIndex:i];
        if ([widget xbuildInfo] != nil) {
            
            NSObject<I_W_BuildInfo> *buildInfo = [widget xbuildInfo];
            NSString *key =[NSString stringWithFormat:@"%@%@", [buildInfo getWidgetId], [buildInfo getAcvtQstId]];
            
            NSObject *value = [widget getResultDirectly];
            BOOL isEnterLeaveVC = NO;
            if (self.acvtViewDelegate && [self.acvtViewDelegate respondsToSelector:@selector(isEnterLeaveVC)]) {
                isEnterLeaveVC = [self.acvtViewDelegate isEnterLeaveVC];
            }
            if (isEnterLeaveVC && [[buildInfo getAcvtQstType] isEqualToString:@"P"]) {
                value = [NSString stringWithFormat:@"%@_%@_%@", model.currentFuncs.fc, model.currentFuncs.fv, model.md5];
            }
            
            if ((![buildInfo getISRequire] || [[buildInfo getISRequire] isEqualToString:@"0"]) && value == nil) {
                [widget needUploadData:@"0"];
            }
            else {
                [widget needUploadData:@"1"];
            }
            
            if ([[buildInfo getNeedUploadData] isEqualToString:@"0"]) {
                value = nil;
            }
            
            if (value) {
                [resultdict setObject:value forKey:key];
            }
            else if (!isIgnoreNullValue) {
                [resultdict setObject:@"" forKey:key];
            }
            
            if ([[buildInfo getAcvtQstType] isEqualToString:@"P"]) {
                
                WSPhotoViewPanel *panel = (WSPhotoViewPanel *)widget;
                id panelValue = [panel getCurrentValue];
                NSString *panelValueStr = @"";
                
                if ([panelValue isKindOfClass:[NSArray class]]) {
                    NSArray *array = (NSArray *)panelValue;
                    panelValueStr = [array componentsJoinedByString:@","];
                }
                else if ([panelValue isKindOfClass:[NSString class]]) {
                    panelValueStr = [NSString stringWithFormat:@"%@", (NSString *)panelValue];
                }
                
                if (panelValueStr.length > 0) {
                    [photonameDict setObject:panelValueStr forKey:(NSString *)value];
                }
            }
        }
    }
    
    [resultdict setObject:[photonameDict JSONString] forKey:@"photonames"];
    return resultdict;
}

@end
