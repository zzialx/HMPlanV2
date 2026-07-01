//
//  WSScanListViewController.h
//  WinSFA
//
//  Created by winchannel on 16/1/13.
//  Copyright © 2016年 WinChannel. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "WCBaseViewController.h"
#import "ZBarSDK.h"
#import <AVFoundation/AVFoundation.h>


@class WSWidget,WSQRTypeView;


typedef void(^UPLoadProductListBlock)(NSArray* aQRlist);

@interface WSScanListViewController : WCBaseViewController<AVCaptureMetadataOutputObjectsDelegate>{
    
    int num;
    BOOL upOrdown;
    NSTimer * timer;
   
    
}

@property(nonatomic, copy) UPLoadProductListBlock  productListBlock;

@property (nonatomic, strong)UIToolbar *toolBar;
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (nonatomic, strong) UINavigationItem *myNavigationItem;



@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
@property (nonatomic, retain) UIImageView * line;

@property (nonatomic, weak) WSWidget *dependentWidget;

@property (nonatomic, weak) WSQRTypeView *qRTypeView;

@property (nonatomic, assign) BOOL isShowModifyButton;

@property (nonatomic, assign) BOOL isScanQRCode; // 是否可以扫描 二维码
@property (nonatomic, assign) NSInteger maxCount; // 允许扫码个数

//@property (nonatomic, strong) NSString *pType;

@property (nonatomic, weak) UIViewController *backController;

@property (nonatomic ,strong) NSMutableArray *barcodeList;

- (id)initWithScanQrCode:(BOOL)isScanQRCode withDescStr:(NSString *)aDescStr;
/**
 *   进入扫描页面
 *
 *  @param parentViewController
 *  @param listBlock
 */
-(void) showQRViewControllerToViewController:(UIViewController*)parentViewController
                                   WithBlock:(UPLoadProductListBlock)listBlock;


/**
 *   设置条码数据源
 *
 *  @param vDataSource 已显示在表格里的数据源
 *  @param aDataSource 所有条码数据源
 */
- (void)setVisibleProducts:(NSArray*)vDataSource andAllProducts:(NSArray*)aDataSource;

- (void)getReturnDataFromLua:(NSString *)returnData;
- (void)getReturnDataFromLuaTip:(NSString *)returnData; //SFA-24449 处理lua脚本tip提示方法

@end
