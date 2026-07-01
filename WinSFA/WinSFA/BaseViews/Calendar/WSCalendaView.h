//
//  WSCalendaView.h
//  TimeCalenda
//
//  Created by LIBB on 16/12/2.
//  Copyright © 2016年 huzepei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSPlanCalendarDataModel.h"
#import "WSPlanCalendarManageDataModel.h"

@class WSCalendaView;

@protocol WSCalendaViewDelegate <NSObject>

@required
/**
 *功能：当日历有选中动作后，无论是点击选择还是拖动选择，都回调该方法
 *参数：dateArray 日历的所有选中日期数组
 *参数结构：2016-08-09格式的字符串
 */
-(void)wsCalendaView:(WSCalendaView *)calendarView selDateAarray:(NSArray *)dateArray;
/**
 *功能：月份更换后，日历高度变化回调
 *参数：当前日历SIZE
 */
-(void)wsCalendaView:(WSCalendaView *)calendarView changToSize:(CGSize)size;

/**
 *功能：点击向前向后按钮更换月份后的回调
 *参数：显示日期的月份
 */
-(void)wsCalendaView:(WSCalendaView *)calendarView changeToMonth:(NSInteger)month;



@end



/**
 *类名：WSCalendaView
 *功能：日历控件，用来展示日历
 *
 */
@interface WSCalendaView : UIView{
    
}

//代理
@property (weak,nonatomic) id <WSCalendaViewDelegate> delegate;
//获得当前所有选中日期，格式为字符串数组，2016-08-09
@property (strong,nonatomic,readonly) NSMutableArray * allSelectDate;
//获得今日日期
@property (strong,nonatomic,readonly)NSString * todayDateStr;

@property (strong, nonatomic) NSDate *tempDate;

@property (strong,nonatomic) WSPlanCalendarDataModel *planCalendarDataModel;

@property (strong,nonatomic) WSPlanCalendarManageDataModel *planCalendarMenageDataModel;

/**
 *功能：初始化函数
 *参数：frame 日历控件区域，注意，日历控件只有横坐标有效，纵坐标根据日期行数自己算出来
 *参数：isAllowsMultipSel 是否允许日历多选
 *参数：isAllowsAllSel 是否允许日历选取所有日期 YES为允许选择所有日期 NO 为止允许选择字典内设定的时间段日期
 *参数：dateDic 设定时间段首尾日期，KEY见WSDimensMacros.h文件宏定义
 *参数：isNewPlan 史克日历计划专用

 */
-(id)initWithFrame:(CGRect)frame MultipleSel:(BOOL)isAllowsMultipSel;
-(id)initWithFrame:(CGRect)frame;
-(id)initWithFrame:(CGRect)frame MultipleSel:(BOOL)isAllowsMultipSel allDateSel:(BOOL)isAllowsAllSel dateDic:(NSDictionary*)dateDic;
-(id)initWithFrame:(CGRect)frame MultipleSel:(BOOL)isAllowsMultipSel NewPlan:(BOOL)isNewPlan;

/**
 *功能：设定日历日期图片函数
 *参数：contentDic 日历日期上需要显示的图片下载地址
 */
-(void)resetDateImageContent:(NSDictionary *)contentDic;
/**
 *功能：设定宽度后，取得日历实际需要的size
 *参数：nil
 */
-(CGSize)getControlViewSize;
/**
 *功能：设定选中日期
 *参数：selDate 设置当前选中日期
 */
-(void)resetSelectDate:(NSString *)selDate;

- (void)jumpToMonthContainDate:(NSString *)string;

- (CGFloat)getHight;


@end








