//
//  BaseViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WSStoreBean.h"
#import "WSOffLineUploadTable.h"
// modity by yanguoshuai at 2012-02-27
#import "MoreProductViewController.h"
//#import "QuadCurveMenu.h"
//#import "QuadCurveMenuItem.h"

#import "WSLocationManager.h"
#import "WSPhotoTypeView.h"
#import "WSPhotoBrowseView.h"
#import "WSPhotoBrowserViewController.h"
#import "WSCustomTimeTable.h"
#import "WCBaseViewController.h"

#import "WSMapView.h"

#define MEMOTAG                 500

#define ALERT_CAMERA_TAG        2002
#define ALERT_QST_TAG        2003       //调查问卷中的问题提供的确认对话框的TAG

#define k_LabelXOffset  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10.0f : 20.0f)
#define k_LabelXWidth  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 185.0f : 185.0f)

typedef NSString*  VisitStoreStatus;

#define VisitStoreNotStart @"0"
#define VisitStoreDone @"1"
#define VisitStoreWorking @"2"

typedef enum {
    OTHER_TEXTFIELD_TAG = 1000,
    OTHER_BUTTON_TAG = 2000,
    OTHER_SWITCH_TAG = 3000,
    OTHER_TABLEVIEW_TAG = 4000
} otherViewTag;

@class  WSFuncsBean;
@class  WSAcvtViewController;
@class  WSBaseModel;

@interface BaseViewController : WCBaseViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate,
UIActionSheetDelegate,WSPhotoTypeViewDelegate,UIAlertViewDelegate,WSPhotoBrowseViewDelegate,UIScrollViewDelegate,WSMapViewDelegate>{
    
    
}
@property (nonatomic,strong) NSString *relate_sub_menu_code;
@property (nonatomic, strong) WSFuncsBean               *currentFuncs;
@property (nonatomic, strong) UIImagePickerController   *mImagePicker;
@property (nonatomic, strong) NSMutableString           *memoData;
@property (nonatomic, strong) WSPhotoBrowseView         *photoBrowseView;
@property (nonatomic, assign) int                       y_point;
@property (nonatomic, strong) NSMutableArray            *titles;
@property (nonatomic, strong) NSMutableArray            *colWidth;
@property (nonatomic, strong) NSMutableArray            *datas;
@property (nonatomic, strong) WSStoreBean               *currentStore;
@property (nonatomic, strong) WSSubempstoreBean         *currentSubEmpStore;
@property (nonatomic, strong) WSStoreBean               *acvtNewStore;
@property (nonatomic, strong) UIAlertView               *alert;
@property (nonatomic, strong) NSData                    *photo;
//@property (retain) CLLocationManager                    *locationManager;
@property (nonatomic, strong) CLLocation                *location;
@property (nonatomic, copy) NSString                    *md5;
@property (nonatomic, strong)  UIView           *upKeyBoardView;
@property (nonatomic, weak) id                          m_CurrentInputView;
// WSMapView
//@property (nonatomic, strong) WSMapView                 *mapView;
@property (nonatomic, retain) WSLocationDescribe *locationDescribe;
@property (nonatomic, strong) UITextView                *m_GPSView;
@property (nonatomic, weak)   UIViewController          *m_ParentViewController;
@property (nonatomic, assign) float                     m_viewHeight;

@property (nonatomic, assign) NSInteger                 requireTag;

@property (nonatomic,strong) NSMutableDictionary         *photoDataDic; //用于存储异常原因的照片
//toolBar上传按钮
@property (nonatomic, strong) UIBarButtonItem           *uploadButton;

@property (nonatomic, strong) UIBarButtonItem           *photoButton;

// photoTypeArray 用于存照片类型，如果照片不需要分类，则 photoTypeArray 为空
@property (nonatomic, strong) NSMutableArray            *photoTypeArray;

@property (nonatomic, assign) BOOL isGpsReady; //Latitude and Longitude is ready

@property (nonatomic, strong) UIPopoverController *popController;

@property (nonatomic, assign) BOOL isModifyData;//判断用户上传或返回前是否输入或修改textfield/textview数据

@property (nonatomic, assign) BOOL isValueChange;

@property (nonatomic, strong) NSNumber *originalViewYPosition;

@property (nonatomic, strong) UIScrollView *contentScrollView;

@property (nonatomic, assign) CGRect originFrame;

@property (nonatomic, strong) UIViewController *originParentViewController;

@property (nonatomic, strong) UIView *originParentView;

@property (nonatomic, strong) UIButton *exitFullScreenButton;

@property (nonatomic, strong) UIView *tempBgView;

@property (nonatomic, assign) BOOL isFullScreenMode;


//公式字典类 键是公式，值为UI控件
@property (nonatomic, strong) NSMutableDictionary *expressionDictionary;

@property (nonatomic, assign) BOOL isClickedBackAction;

@property (nonatomic, strong)  NSMutableArray *radioViewArray;

@property (nonatomic, strong) NSMutableDictionary   *selectedDataDic;       //待上传的数据or回显的数据
//TB层的module_fc传下去主要为了区分不同模块（同九宫格）下的门店拜访（方便从门店向上回溯遍历本模块fc树）。
@property (nonatomic, copy)NSString *moduleFC;

@property (nonatomic, strong) WSBaseModel         *model;
//地图视图的Y轴位置。
@property (nonatomic, assign) float optMapViewY;
//地图View是否已初始化过。
@property (nonatomic, assign) BOOL  isInitMapView;

// 是否需要越级返回（如：离店上传数据需直接返回门店列表）
@property (nonatomic, assign) BOOL  isBackAccrossParent;

@property (nonatomic, assign) BOOL isExchangeAcvtModel;

@property (nonatomic, assign) BOOL isBackClick; //是否back按键点击

@property (nonatomic, weak) UIViewController  *ownParentViewController;

@property (nonatomic, copy) NSString  *bizDate;

@property(nonatomic,copy) NSString *kqArrange;///<考勤安排

- (void)createModel;


- (id)initWithFuncs:(WSFuncsBean *)funcs;
- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store;

-(id)initWithFuncs:(WSFuncsBean *)funcs subEmpStore:(WSSubempstoreBean*)store;

-(id)initWithFuncs:(WSFuncsBean*)funcs Store:(WSStoreBean*)store subEmpStore:(WSSubempstoreBean *)subEmpStore;

- (instancetype)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean*)store acvtNewStore:(WSStoreBean *)acvtNewStore;

- (BOOL)insertUploadData:(NSString *)aPostDate
        URL             :(NSString *)aUrl
        MD5             :(NSString *)aMd5
        IsPhoto         :(BOOL) aIsPhoto
        NotifyName      :(NSString *)aNotifyName;

// 用于保存照片
-(BOOL) insertUploadMedia:(NSString *)aPostDate
                     Type:(NSString *)type
                      URL:(NSString *)aUrl
                      MD5:(NSString *)aMd5
                  IsPhoto:(BOOL)aIsPhoto
               NotifyName:(NSString *)aNotifyName
            photoFileName:(NSString *)photoFileName;

//根据上传操作更新当前页面在列表中是否已处理的标记
- (BOOL)uploadVisitAction;

-(NSString*)getMD5Time;
-(BOOL)backToParent;
-(void)addGpsView;

/**
 *  必须定位功能，并且当前没有开启定位权限，则提示用户去设置打开定位功能。
 *
 *  @return YES，显示alert。NO，定位以及开启。
 */
-(BOOL) showGPSOpenAlertIfNeed;

/**
 *  检测上传数据是否必须GPS，如果没有展现GPS则返回NO。
 *
 *  @return NO,标识当前没有GPS信息，不允许提交信息。
 */
-(BOOL)checkMustUploadGPS;




- (BOOL)validateMemo;


- (BOOL)textFielLimtedKindOfNumber:(UITextField *)textField shouldChangeCharactersInRange:(NSRange) range replacementString:(NSString *)string;
- (BOOL)limitedInputLength:(UITextField *)textField shouldChangeCharactersInRange:(NSRange) range replacementString:(NSString *)string;

/**
 *  增加图片选择界面
 *
 *  @param isSupperLocalPicture 是否支持选择本地照片
 *  @param maxPhoto             最大可选择or可拍的照片数量
 */
-(void)addPictureWithSupperLocalPicture:(BOOL)isSupperLocalPicture
                    withMaxPhotoNnumber:(NSInteger)maxPhoto;
-(void)addToolBar;

- (void)locationMe;
-(void) addCancellOKButton:(id)aView;

- (NSArray *)getImagePathFromDataBase;

- (void)checkNetWorkStateAndAlert;

- (void)makeKeybordDown;

- (void)addFullScreenButton;
- (void)exitFullScreen;

/**
 *  是否支持选择本地照片功能
 *
 *  @return YES可以从本地相册选照片
 */
- (BOOL) isSupperChangedLocalPhoto;

- (void)addOptView;
- (void)addFuncsOtherBeanView;
-(void)createMD5With:(NSDictionary*)param;
- (void) resetMd5WithCustomDataStr:(NSString*) dataStr;
- (NSDictionary*)md5Param;

/**
 *  是否准备显示opt视图
 *
 *  @return YES or NO
 */
-(BOOL)isPrepareShowOptView;

-(void)initializationBackItemAction;

/**
 *  清除地图数据，释放内存。
 */
- (void)clearMapData;

- (void)addPhotoButtonWhenDistanceIsInvalid;

- (void)showDBErrorTipAndHidAllHud;

- (NSMutableDictionary *)getNetWorkStatus;

- (void)generateMd5;

- (BOOL)getVariableWithClass:(Class) myClass varName:(NSString *)name;

- (void)loadStoreNameLabel;

- (BOOL)readonlyAfterUpload;

//- (void)insertStoreVisitStatusToDb;
//
//- (void)updateStoreVisitStaus;

- (void)updateStoreVisitStaus:(NSString *)status;


@end
