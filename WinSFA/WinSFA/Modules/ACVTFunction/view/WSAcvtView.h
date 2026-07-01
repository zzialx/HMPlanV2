//
//  WSAcvtView.h
//  WinSFA
//
//  Created by winchannel on 15/3/5.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WSBaseView.h"

#import "WSAcvtQstBottomLineView.h"

#import "I_Lua_Executor_Delegate.h"

#import "WSWidget.h"
#import "WSAcvtTabCollectionView.h"

@class WSWidgetFactory;

@class WSWidget;

@class WSInterAction;

@class WSAcvtBean;

@class WSLuaExecutorManager;



@protocol WSAcvtViewDelegate <NSObject> 

@optional
- (void)setUploadButtonEnable:(BOOL)isEnable;
- (void)setUploadButtonHidden:(BOOL)isHidden;
- (void)acvtViewWidget:(WSWidget *)widget valueChanged:(BOOL)isValueChangedCompareWithOrigin;
- (void)addChildVC:(UIViewController *)vc isResetOffset:(BOOL)isResetOffset;
- (void)cancleAgreeCollectPrivacyPolicyMesage;
- (void)acvtViewReloadHeaderTitle:(NSString*)headerTitle;
- (BOOL)isEnterLeaveVC;

@end


@interface WSAcvtView : WSBaseView<WSWidgetDelegate,I_Lua_Executor_Delegate>{
    
    WSAcvtBean *_acvtBean;
    
    WSWidgetFactory  *__acvtfactory; //控件工厂
    
    UIScrollView    *scrollview;
    
    NSMutableArray  *widgetArray;
    
    NSMutableDictionary  *widgetDict;  //所有控件字典  （id对应控件）

    WSLuaExecutorManager  *wsLuaExecutor;
    
}


/**
 *  问题类型P的WSPhotoBrowseView集合，上传时遍历。
 */
@property (nonatomic, strong) NSMutableArray    *photoBrowseViewArray;
@property (nonatomic, strong) NSMutableArray    *photoScanListViewArray;

@property (nonatomic, strong) NSMutableArray    *widgetArray;

@property (nonatomic, strong) NSMutableDictionary *valueChangedWidgetDic;

@property (nonatomic, weak) id<WSAcvtViewDelegate>  acvtViewDelegate;

@property (nonatomic, strong) NSMutableDictionary  *widgetDict;

@property (nonatomic, strong) NSMutableDictionary  *widgetDictForLua;  //所有控件字典，专用于lua (存储方式不太一致，名字对应控件)

@property (nonatomic, strong) NSMutableDictionary  *widgetDictForLuaByQstCode;

@property (nonatomic, assign) CGFloat   positionY;

@property (nonatomic, assign) BOOL isInAcvtTabMode;

@property (nonatomic, copy) NSString  *bizDate;

@property(nonatomic,copy) NSString *kqArrange;///<考勤安排

- (id)initWithFrame:(CGRect)frame andAcvtBean:(WSAcvtBean *)acvtBean;

- (id)initWithFrame:(CGRect)frame andAcvtBean:(WSAcvtBean *)acvtBean qstArray:(NSArray *)qstArray;

-(NSObject *)getAllPrepareSubmitData;

// isIgnoreNullValue 是否忽略空值，箭牌要求删除的项传空值
-(NSObject *)getAllPrepareSubmitDataByIsIgnoreNullValue:(BOOL)isIgnoreNullValue;

-(NSObject *)getAllPrepareSaveDataByIsIgnoreNullValue:(BOOL)isIgnoreNullValue  resultdict:(NSMutableDictionary *)resultdict;

-(void)applyData:(WSInterAction *)interAction forExecuteWidget:(NSString *)actv_qust_id;

-(BOOL)executeValidate;

- (NSMutableDictionary *)getAcvtQstMemoValues;

- (NSMutableDictionary *)getPrepareDeleteAcvtNewStoreSubmitData;

- (NSArray *)doExecuteGroupValidate;
- (NSArray *)getAllData;

/*上传时候执行lua脚本（提示两个问题间值的大小关系是否填写正确，不正确则提示(提示内容由脚本来写)）*/
- (BOOL)checkLuaScriptWhenUpload;

// 上传是执行问卷上的脚本代替当前的上传操作
- (BOOL)checkLuaScriptOnUpload;

// 上传成功后执行脚本
- (BOOL)checkLuaScriptBlock;

/*验证所有的问题是否都是空值，若是则禁止上传*/
- (BOOL)widgetsHasValue;

- (void)viewWillAppear;

- (BOOL)isValueChange;

- (void)refreshWidgeForType:(NSString *)type;


- (NSString *)getAcvtFilledQstsCountByType:(NSString *)qstType;

- (NSString *)getAcvtQstsCountByType:(NSString *)qstType;

- (NSArray *)getTabNameArrayInOrder;

- (void)executeLuaScriptWhenInitFinish;

//表格跳转调查问卷 ---> 表格新的输入方式获取问卷回显的值
-(NSObject *)getAllDataAboutQstIdAndValue;
// 脚本设置隐藏标签页
- (void)hiddenAcvtTab:(NSString *)titleName;
// 脚本设置跳转标签页
- (void)gotoTabWithIndex:(NSInteger)index;

- (void)uploadImgID;

// YIHAIKERRY-1141 获取侧边视图的子视图
- (UIView *)getSideSubView;

// YIHAIKERRY-1141 获取分组问题的Y坐标
- (CGFloat)getGroupPosYByIndex:(NSInteger)groupIndex;
//MN-977  增加每次进入问卷执行的方法
- (void)checkAndExecuteAcvtLuaScriptEvery;

- (void)checkAndExecuteAcvtLuaScript;

- (void)readyToUpload;

#pragma mark - 清除问卷数据方法
- (void)celearAcvtData;

#pragma mark - 获取问卷视图是否为tab模式方法
- (BOOL)acvtViewIsTabMode;
//SFA-22221
- (void)executeLuaScriptCancle;

- (NSMutableDictionary *)notReqCheckTip;            //非必填项校验提示方法
- (NSMutableDictionary *)getAcvtNotReqCheckTipData; //获取问卷非必填校验数据方法

@end
