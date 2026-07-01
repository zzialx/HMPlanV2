//
//  WSMapView.h
//  WinSFA
//
//  Created by heju on 14/12/12.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "WSBaseAnnotation.h"
#import "WSLocationManager.h"
#import "WSStoreAnnotation.h"

@protocol WSMapViewDelegate;

typedef NS_ENUM(NSInteger, UIRoutingPlanType) {
    
    UIRoutingPlanTypeInPlan,    //计划内路线
    UIRoutingPlanTypeActually,  //实际路线
    UIRoutingPlanTypeAll,       //两种类型都有
    UIRoutingPlanTypeNone,      //两种类型都没有
    UIRoutingPlanTypeNew        //新的逻辑
};
typedef NS_ENUM(NSInteger, PopViewType) {
    
    PopViewTypeEmplist,   // 人员的popview
    PopViewTypeRolelist   // 人员角色的popview
};

@interface WSMapView : UIView <MKMapViewDelegate>

//@property (nonatomic, weak) id<WSMapViewDelegate> delegate;
//
//@property (nonatomic, assign) BOOL isShowStoreDetailMsg;
//
//@property (nonatomic, strong) NSMutableArray *allStores;
//
//@property (nonatomic, strong) NSMutableArray *callPlanDict;
//
//@property (nonatomic, assign) BOOL isOrder; ///<区分 实际路线 和计划路线
//
//@property (nonatomic, strong) UIColor *lineColor;
//
//@property (nonatomic, assign) BOOL  mapIsHidden;///<SFA-13924 地图有可能是隐藏的，不需要已放大至最大提示
//
//@property (nonatomic, strong) NSArray *empArray;    ///<人员数组
//
//@property (nonatomic, strong) NSArray * roleArray; ///<角色列表
//
//@property (nonatomic, strong) UIButton *refreshButton;///<YIHAIKERRY-3194
//
///**
// 拜访轨迹的地图
//
// @param mapViewRect 初始化
// @param stores 拜访商店
// @param isOrder
// @return
// */
//-(id)initWithFrame:(CGRect)mapViewRect routePlanStores:(NSArray *)stores isOrder:(BOOL)isOrder;
//
///**
// 地图模式下初始化方法
//
// @param mapViewRect 初始化
// @param funcs
// @param allStores
// @return
// */
//- (id)initWithFrame:(CGRect)mapViewRect funcs:(WSFuncsBean *)funcs stores:(NSArray *)allStores;
//
//- (id)initWithFrame:(CGRect)mapViewRect funcs:(WSFuncsBean *)funcs stores:(NSArray *)allStores empArray:(NSArray *)empArray isSubEmpTrail:(BOOL)isSubEmpTrail;
//
//- (id)initWithFrame:(CGRect)mapViewRect storeCoordinate:(CLLocationCoordinate2D )coordinate storeId:(NSString *)storeId storeName:(NSString *)storeName isFullScreen:(BOOL)isFullScreen;
//
///**
// 进离店 及acvt页面地图初始化方法
//
// @param mapViewRect 初始化
// @param coordinate 坐标点
// @param storeId 商店id
// @param storeName 商店名字
// @param isCenterForStore
// @param isShowAddress
// @return
// */
//- (id)initWithFrame:(CGRect)mapViewRect storeCoordinate:(CLLocationCoordinate2D )coordinate storeId:(NSString *)storeId storeName:(NSString *)storeName isCenterForStoreLocation:(BOOL)isCenterForStore isShowAddress:(BOOL)isShowAddress;
//
//- (id)initWithFrame:(CGRect)mapViewRect storeCoordinate:(CLLocationCoordinate2D )coordinate storeId:(NSString *)storeId storeName:(NSString *)storeName isCenterForStoreLocation:(BOOL)isCenterForStore isShowAddress:(BOOL)isShowAddress locationType:(NSString *)locationType;
//
//- (id)initWithFrame:(CGRect)mapViewRect storeCoordinate:(CLLocationCoordinate2D )coordinate storeId:(NSString *)storeId storeName:(NSString *)storeName isCenterForStoreLocation:(BOOL)isCenterForStore isShowAddress:(BOOL)isShowAddress locationType:(NSString *)locationType isDropFullScreen:(BOOL)isDropFullScreen;
//- (void)loadStoreAnnotationsWith:(NSArray *)allStores;
//
//- (void)loadStoreAnnotationsWith:(NSArray *)allStores isAddLine:(BOOL)isAddLine;
//
//- (void)loadStoreAnnotationsWithCallPlanDict:(NSDictionary *)callPlanDict withDateWeekStr:(NSString *)dateWeekStr withIsFitMap:(BOOL)isFitMap;
//
//- (void)loadStoreAnnotationsWith:(NSArray *)planStores andActureStores:(NSArray *)actureStores;
//
///**
// 根据路线类型进行画线
//
// @param type 计划内外
// @param planArray
// @param actuallyArray
// */
//- (void)loadRoutingPlanWithType:(UIRoutingPlanType)type withPlanArray:(NSArray *)planArray andActuallyArray:(NSArray *)actuallyArray;
//
///**
// 立白: 门店拜访-门店地图页面不具体显示拜访轨迹(给已拜访的门店连线)
//
// @param visitedStores
// */
//-(void)loadVisitedStoreRoutingWith:(NSArray *)visitedStores;
//
///**
// winSFA MSTD-4000  SFA 项目 SFA-4773  根据安卓实现 地图路线
//
// @param allStores 所有门店
// @param todayVisitArray 今日拜访
// */
//-(void)loadStoresRoutingWith:(NSArray *)allStores todayVisitArray:(NSArray*)todayVisitArray actualVisitArray:(NSArray*)actualVisitArray;
//
///**
// 当前位置
// */
//- (void) locateCurrentLocation;
//
///**
// 带加载框的
//
// @param isLoading 是否显示加载中的弹框
// */
//- (void)locateCurrentLocationWithLoading:(BOOL)isLoading;
//
//- (void)locateCurrentLocationNoCache;
//
//- (void)setAddress:(NSString *)address;
//
//- (void)reloadPolyIineWithDateofWeekStr:(NSString *)dateWeekStr;
//
//- (void)setLocationType:(NSString *)locationType;
//
//- (void)showDetailViewWith:(WSStoreBean *)store;
//
///**
// 移除所有的划线
// */
//- (void)removeAllLine;
//
//- (void)reloadStoreLoactionWithstoreCoordinate:(CLLocationCoordinate2D )storecCoordinate withLoactionCoordinate:(CLLocationCoordinate2D)locationCoordinate withStoreBean:(WSStoreBean *)aStore withDistanceRange:(NSString *)distanceRange;
//
//- (void)addStoreAnotationWithstoreCoordinate:(CLLocationCoordinate2D )storecCoordinate withStoreBean:(WSStoreBean *)aStore;
//
//- (void)setRegion:(CLLocationCoordinate2D)coordinate2D;
//
///**
// 如果实时点名第一次进入 只选择时间时，请求的的pid应该是从下级人员地图中选中的那个人员id
//
// @param empId
// */
//-(void)setEmpIdForPid:(NSString *)empId;
//
///**
// 加载选择人员按钮
// */
//-(void)loadSelectEmpButton;
//
///**
// 加载选择角色按钮
// */
//-(void)loadSelectRoleButton;
//
//- (void)loadSubEmpResponsibleAreaOverlay:(NSArray *)overlayStores;
//
//- (void)removeStorea;

@end



@interface WSUserAnnotation : WSBaseAnnotation

@end

@interface WSDirectUserAnnotation : WSBaseAnnotation

@end



@protocol WSMapViewDelegate <NSObject>

//@optional
//- (void)mapView:(WSMapView *)mapView locationDescribe:(WSLocationDescribe *)locationDescribe;
//
////- (void)mapView:(MKMapView *)mapView annotationStore:(WSStoreBean *)store;
////
////- (void)mapView:(MKMapView *)mapView dropFullScreen:(BOOL)isDrop;
//
//- (void)mapView:(BMKMapView *)mapView annotationStore:(WSStoreBean *)store;
//
//- (void)mapView:(BMKMapView *)mapView dropFullScreen:(BOOL)isDrop;
//
///**
// 如果是走acvt加载出来的地图,需要上传改动的位置坐标
//
// @param mapView
// @param coordinate 坐标
// */
////- (void)mapView:(MKMapView *)mapView locationCoordinate:(CLLocationCoordinate2D )coordinate;
//- (void)mapView:(BMKMapView *)mapView locationCoordinate:(CLLocationCoordinate2D )coordinate;
//
//- (void)mapViewIsClickLocationButton:(WSStoreBean *)store;
//
///**
// 如果点击了重新定位的按钮，则认为需要上传定位的位置，而不是门店回显的位置
// */
//- (void)mapViewIsClickLocationButton;
//
///**
// 请求并刷新下级人员的门店
//
// @param biz_date
// @param empid
// */
//-(void)requestSubEmpStoreAndReloadMapviewWith:(NSString *)biz_date andEmpId:(NSString *)empid;
//
//-(void)refreshTitle:(NSString * )tittle;

@end

