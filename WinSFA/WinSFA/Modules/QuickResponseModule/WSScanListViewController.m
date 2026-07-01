//
//  WSScanListViewController.m
//  WinSFA
//
//  Created by winchannel on 16/1/13.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSScanListViewController.h"
#import "QRCodeGenerator.h"
#import "WSInterAction.h"
#import "WidgetConstant.h"
#import "WSEnvrionment.h"

#import "WSWidget.h"
#import "I_W_BuildInfo.h"
#import "PureLayout.h"
#import "WSDropListCell.h"
#import "WSBaseProductDBService.h"
#import "WSScanSelectView.h"
#import "WSCameraAuthHelper.h"
#import "WSRequestHelper.h"
#import "WSQRTypeView.h"
#define SCANVALIDATE_NOTIFY @"scanValidate_notify"
#define LANGUAGE    @"language"
#define SCANQUERY    @"scanQuery"
#define SCANCodeDetail_NOTIFY @"scanCodeDetail_notify"

#define IsIphone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define PreViewYOffset (IsIphone4 ? 128 : 148)
#define PreViewWidthRatio   0.73
#define kTableViewBgColor   [UIColor colorWithWhite:.0 alpha:0.6]
#define kPadPreviewWidth    400

static const CGFloat kDescFontSize = 13.0;

@interface WSScanListViewController ()<UITableViewDataSource, UITableViewDelegate, WSScanSelectDelegate>

//@property (nonatomic ,strong) UIButton *confirmButton;
//@property (nonatomic ,strong) UIButton *cancelButton;
@property (nonatomic ,strong) UIButton *editButton;
@property (nonatomic ,strong) UIButton *backButton;
@property (nonatomic, strong) UIImageView *scanFrameImageView;
@property (nonatomic, strong) CALayer *topLayer;
@property (nonatomic, strong) CALayer *leftLayer;
@property (nonatomic, strong) CALayer *rightLayer;
@property (nonatomic, strong) CALayer *bottomLayer;
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray *qrList;
@property (nonatomic, strong) NSArray *visiableProducts;
@property (nonatomic, strong) NSArray *allProducts;
@property (nonatomic, assign) BOOL isProductExist;
@property (nonatomic, strong) NSString *descStr;
@property (nonatomic, strong) WSScanSelectView *selectView;

- (void)validateScanResult:(NSString *)scanResult; //验证扫描结果方法

@end

@implementation WSScanListViewController


- (id)initWithScanQrCode:(BOOL)isScanQRCode withDescStr:(NSString *)aDescStr{
    self = [self init];
    if (self) {
        self.isScanQRCode = isScanQRCode;
        self.descStr = aDescStr;
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        self.visiableProducts =[[NSArray alloc]init];
        self.allProducts = [[NSArray alloc]init];
        self.isShowModifyButton = YES;
        self.isScanQRCode = YES;
    }
    return self;
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    

    if ([[self.executeParam execute_class_param] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)[self.executeParam execute_class_param];
        self.visiableProducts = [dic objectForKey:PARAM_KEY_VISIBLE_PRODUCTS];
        self.allProducts = [dic objectForKey:PARAM_KEY_ALL_PRODUCTS];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 64)];
    UIColor *navBarColor = [UIColor colorForKey:@"NavigationBarBackgroundColor"]; //获取导航的颜色
    if (navBarColor) {
        [navView setBackgroundColor:navBarColor];
    }
    [self.view addSubview:navView];
    
    UILabel *titleLabel = [UILabel newAutoLayoutView];
    [titleLabel setText:NSLocalizedString(@"scan", nil)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
//    [titleLabel sizeToFit];
    UIColor *navBarTitleColor = [UIColor colorForKey:@"NavigationBarTitleColor"]; //获取导航的颜色
    if (navBarTitleColor) {
        [titleLabel setTextColor:navBarTitleColor];
    }
    [navView addSubview:titleLabel];
    [titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
    [titleLabel autoSetDimension:ALDimensionHeight toSize:44];
    [titleLabel autoSetDimension:ALDimensionWidth toSize:180];

    [titleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, MAIN_BUTTON_WH, 44)];
    [_backButton setBackgroundColor:[UIColor clearColor]];
    [_backButton setImage:[UIImage scaledImageForName:@"icon_back" ofType:@"png"] forState:UIControlStateNormal];
    //[_backButton setTitle: NSLocalizedString(@"cancel_label",nil) forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backParentController) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:_backButton];
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 112, 20, 100, 44)];
    [doneButton.titleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
    [doneButton setTitle: NSLocalizedString(@"complete",nil) forState:UIControlStateNormal];
    [doneButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    UIColor *navBarButtonColor = [UIColor colorForKey:@"NavigationBarButtonTitleColor"];
    if (navBarButtonColor) {
        [doneButton setTitleColor:navBarButtonColor forState:UIControlStateNormal];
    }
    [doneButton addTarget:self action:@selector(confirmCompletion:) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:doneButton];
    
    if (self.isShowModifyButton) {
        
        _editButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 54, 20, 60, 44)];
        [_editButton setTitle: NSLocalizedString(@"edit",nil) forState:UIControlStateNormal];
        //UIImage *image =[UIImage imageNamed:@"edit_button.png"];
        //[_editButton setImage:image forState:UIControlStateNormal];
        [_editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [_editButton addTarget:self action:@selector(confirmCompletion:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_editButton];
    }
    
    

    
    _qrList = [NSMutableArray arrayWithCapacity:5];
    //_barcodeList = [NSMutableArray array];
    if(!self.allProducts)
        _barcodeList = [[NSMutableArray alloc] initWithArray:self.visiableProducts];
    else
        _barcodeList = [NSMutableArray array];
    
    
//    WSCameraAuthHelper *cameraHelper = [[WSCameraAuthHelper alloc] init];
//    [cameraHelper authCameraWithBlock:^(BOOL isOK) {
//        if (isOK) {
     [self setupCamera];
//        }
//    }];

    CGRect rect = [self getScanRect];
    CGFloat tablePaddingY = CGRectGetMaxY(rect) + MAIN_PADDING;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,  tablePaddingY, self.view.bounds.size.width, self.view.bounds.size.height - tablePaddingY)];
    _tableView.backgroundColor = kTableViewBgColor;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_tableView];

    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
//    _confirmButton = [UIButton newAutoLayoutView];
//    [_confirmButton setTitle: NSLocalizedString(@"confirm_label",nil) forState:UIControlStateNormal];
//    [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [_confirmButton addTarget:self action:@selector(confirmCompletion:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_confirmButton];
//    [_confirmButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
//    [_confirmButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:MAIN_PADDING];
    
//    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 31 - 104, self.view.bounds.size.height - 10 - 34- 64, 104, 34)];
//    [_cancelButton setTitle: NSLocalizedString(@"cancel_label",nil) forState:UIControlStateNormal];
//    [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//  
//    [_cancelButton addTarget:self action:@selector(cancelButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_cancelButton];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputPortFormatDescChanged:)
                                                 name:AVCaptureInputPortFormatDescriptionDidChangeNotification
                                               object:nil];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVCaptureInputPortFormatDescriptionDidChangeNotification
                                                  object:nil];
    
    if (self.selectView) {
        self.selectView.delegate = nil;
    }
}

- (void)orientChange:(NSNotification *)noti
{
    
    [self rotateLayer:_preview];
}

- (void)inputPortFormatDescChanged:(NSNotification *)notificaton {
    CGRect rect = [self getScanRect];
    _output.rectOfInterest = [_preview metadataOutputRectOfInterestForRect:rect];
}

- (void)setIsShowModifyButton:(BOOL)isShowModifyButton
{
    if (!isShowModifyButton) {
        self.editButton.hidden = YES;
    }
}

- (void)setupCamera
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    if (IOS8_OR_LATER) {
        _output.metadataObjectTypes =@[AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeQRCode,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeInterleaved2of5Code,AVMetadataObjectTypeITF14Code,AVMetadataObjectTypeDataMatrixCode];
    }else{
        _output.metadataObjectTypes =@[AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeQRCode,AVMetadataObjectTypeAztecCode];
    }
    
    [self setupMask];
    [self setupDescription];
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame = self.view.bounds;
    
  
    
//    CGRect imageFrame = CGRectMake((236 - 236)/2.0, (237 - 237)/2.0, 236, 237);
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageForName:@"scanf_img"];
//    [imageView.layer setMasksToBounds:YES];
//    [imageView.layer setCornerRadius:5.0];//设置矩形四个圆角半径
//    [imageView.layer setBorderWidth:1.0]; //边框宽度
//    [imageView.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.view addSubview:imageView];
    self.scanFrameImageView = imageView;
    
    CGRect rect = [self getScanRect];
    self.scanFrameImageView.frame = rect;
    
    [self.view.layer insertSublayer:self.preview atIndex:0];
    

    [self rotateLayer:_preview];

}

- (AVCaptureVideoOrientation) videoOrientationFromCurrentDeviceOrientation {
    switch (self.interfaceOrientation) {
        case UIInterfaceOrientationPortrait: {
            return AVCaptureVideoOrientationPortrait;
        }
        case UIInterfaceOrientationLandscapeLeft: {
            return AVCaptureVideoOrientationLandscapeLeft;
        }
        case UIInterfaceOrientationLandscapeRight: {
            return AVCaptureVideoOrientationLandscapeRight;
        }
        case UIInterfaceOrientationPortraitUpsideDown: {
            return AVCaptureVideoOrientationPortraitUpsideDown;
        } case UIInterfaceOrientationUnknown: {
            if (INTERFACE_IS_PHONE) {
                return AVCaptureVideoOrientationPortrait;
            } else {
                return AVCaptureVideoOrientationLandscapeRight;
            }
        }
    }
}

- (CGRect)getScanRect {
    CGSize viewSize = self.view.bounds.size;
    CGFloat previewWidth;
    if (INTERFACE_IS_PHONE) {
        previewWidth = SCREEN_WIDTH * PreViewWidthRatio;
    } else {
        previewWidth = kPadPreviewWidth;
    }
    
    return CGRectMake((viewSize.width - previewWidth) / 2.0, PreViewYOffset, previewWidth, previewWidth);
}

- (void)setupMask {
    CALayer *topLayer = [[CALayer alloc] init];
    topLayer.backgroundColor = POP_WINDOW_BG_COLOR.CGColor;
//     topLayer.backgroundColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:topLayer];
    self.topLayer = topLayer;
    
    CALayer *leftLayer = [[CALayer alloc] init];
    leftLayer.backgroundColor = POP_WINDOW_BG_COLOR.CGColor;
//     leftLayer.backgroundColor = [UIColor blueColor].CGColor;
    [self.view.layer addSublayer:leftLayer];
    self.leftLayer = leftLayer;
    
    CALayer *rightLayer = [[CALayer alloc] init];
    rightLayer.backgroundColor = POP_WINDOW_BG_COLOR.CGColor;
//     rightLayer.backgroundColor = [UIColor greenColor].CGColor;
    [self.view.layer addSublayer:rightLayer];
    self.rightLayer = rightLayer;
    
    CALayer *bottomLayer = [[CALayer alloc] init];
    bottomLayer.backgroundColor = POP_WINDOW_BG_COLOR.CGColor;
//       bottomLayer.backgroundColor = [UIColor yellowColor].CGColor;
    [self.view.layer addSublayer:bottomLayer];
    self.bottomLayer = bottomLayer;
    
    
    CGRect rect = [self getScanRect];

    self.topLayer.frame = CGRectMake(0, 64, self.view.width, CGRectGetMinY(rect) - 64);
    self.leftLayer.frame = CGRectMake(0, CGRectGetMinY(rect), CGRectGetMinX(rect), self.view.height - CGRectGetMinY(rect));
    self.rightLayer.frame = CGRectMake(CGRectGetMaxX(rect), CGRectGetMinY(rect), self.view.width - CGRectGetWidth(rect), self.view.height  - CGRectGetMinY(rect));
    self.bottomLayer.frame = CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetWidth(rect), self.view.height  - CGRectGetMaxY(rect));

}

- (void)setupDescription {
    UILabel *descLabel = [UILabel newAutoLayoutView];
    NSString *desc = NSLocalizedString(@"scan_sub_title_lable", nil);
    if (_descStr && _descStr.length > 0) {
        desc = [_descStr copy];
    }
    [descLabel setTextColor:[UIColor whiteColor]];
    [descLabel setTextAlignment:NSTextAlignmentCenter];
    [descLabel setFont:[UIFont systemFontOfSize:kDescFontSize]];
    [descLabel setText:desc];
    descLabel.numberOfLines = 0;
    
    CGRect rect = [self getScanRect];
    CGFloat paddingY = 14;
    CGFloat descWidth = self.view.width - 30;
    CGSize descSize= [desc ws_sizeWithFont:[UIFont systemFontOfSize:kDescFontSize] constrainedToWidth:descWidth lineBreakMode:NSLineBreakByWordWrapping];;
    [self.view addSubview:descLabel];
    [descLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view withOffset:rect.origin.y - paddingY - descSize.height];
    [descLabel autoSetDimension:ALDimensionWidth toSize:self.view.width - 100];
    [descLabel autoAlignAxisToSuperviewMarginAxis:ALAxisVertical];
    
    UIImage *qrImage = [UIImage scaledImageForName:@"scan_desc_qrcode" ofType:@"png"];
    UIImageView *qrImageView = [UIImageView newAutoLayoutView];
    [qrImageView setImage:qrImage];
    [self.view addSubview:qrImageView];
    [qrImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:descLabel withOffset:MAIN_PADDING];
    [qrImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:descLabel];
    
    UIImage *barcodeImage = [UIImage scaledImageForName:@"scan_desc_barcode" ofType:@"png"];
    UIImageView *barcodeImageView = [UIImageView newAutoLayoutView];
    [barcodeImageView setImage:barcodeImage];
    [self.view addSubview:barcodeImageView];
    [barcodeImageView autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:descLabel withOffset:-MAIN_PADDING];
    [barcodeImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:descLabel];
}

// ipad上二维码扫描，摄像头方向调整
- (void)rotateLayer:(CALayer *)layer
{
    AVCaptureConnection *connection = [_output connectionWithMediaType:AVMediaTypeVideo];
    connection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation];
    _preview.connection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (IOS7_OR_LATER) {
        upOrdown = NO;
        num =0;
        
        _line = [[UIImageView alloc] init];
        _line.image = [UIImage imageNamed:@"scan_line.png"];
        [self.view addSubview:_line];

        
        timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(scanAnimation) userInfo:nil repeats:YES];
        // Start

        [_session startRunning];
     
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)confirmCompletion:(id)sender
{
    if([self isHasSeverObjid]) { //SFA-29916 在扫描过程中，有弹出确定按钮，就已经把产品添加到表格中，此处不需要处理了
        [self backParentController];
        return;
    }
    
    NSArray *resultArray = self.qrList;

    if (self.productListBlock) {
        self.productListBlock(resultArray);
    }
    
    if (self.wcBaseViewdelegate && [self.wcBaseViewdelegate respondsToSelector:@selector(callBackWhenFinishTask:)]) {
        self.executeParam.execute_result = resultArray;
        [self.wcBaseViewdelegate callBackWhenFinishTask:self.executeParam];
    }
    
    if ([self.currentFuncs.ds isEqualToString:SCANQUERY]) {
        [self backParentController:YES];
    }else{
        [self backParentController:NO];
    }
    
    
}

//- (void)cancelButtonSelected:(id)sender
//{
//    [self backParentController];
//}

- (void)backParentController {
    [self backParentController:YES];
}

- (void)backParentController:(BOOL)isFromBackAction
{
    if (IOS7_OR_LATER) {
        [_session stopRunning];
        [timer invalidate];
        timer = nil;
    }
    
    if (isFromBackAction && self.backController) {
        [self.backController.navigationController popViewControllerAnimated:NO];
    }
    
    __weak WSScanListViewController *weakController = self;
    [self dismissViewControllerAnimated:YES completion:^{
        
        __strong WSScanListViewController *strongController = weakController;
        [strongController removeFromParentViewController];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self showOrHiddenTableView];
    return [self.qrList count];
}


// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        
    }
    
    if (self.allProducts.count > 0) {
        NSObject<I_W_OptionDataItem> *dataItem = [self.qrList objectAtIndex:indexPath.row];
        cell.textLabel.text = [dataItem getDataItemName];
    } else {
    
    //        int number = self.qrList.count - indexPath.row;
    //        NSString *imei = [self.qrList objectAtIndex:self.qrList.count - indexPath.row -1];
    //        NSString *imeiAndNumber = [NSString stringWithFormat:@"%d. %@",number,imei];
        NSString *imei = [self.qrList objectAtIndex:indexPath.row];
        NSString *imeiAndNumber = [NSString stringWithFormat:@"%ld. %@",(long)indexPath.row + 1,imei];
        
        cell.textLabel.text = imeiAndNumber;
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    return cell;
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //YIHAIKERRY-4409
    id prod = [self.qrList objectAtIndex:indexPath.row];
    if ([prod isKindOfClass:[NSString class]]) {
        [self.barcodeList removeObject:prod];
        [self.qrList removeObjectAtIndex:indexPath.row];
    } else if ([prod isKindOfClass:[WSProdBean class]]) {
        WSProdBean *prodBean = (WSProdBean *)prod;
        [self.barcodeList removeObject:prodBean.barcod];
        [self.qrList removeObjectAtIndex:indexPath.row];
    } else {
        [self.barcodeList removeObject:[self.qrList objectAtIndex:indexPath.row]];
        [self.qrList removeObjectAtIndex:indexPath.row];
    }
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

#pragma mark - SFA-24449 处理lua脚本tip提示方法
- (void)getReturnDataFromLuaTip:(NSString *)returnData {
    [self validateScanResult:returnData];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [_session stopRunning];
    
    NSString *stringValue;

    if ([metadataObjects count] > 0) {
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        //SFA-26675
        //备注：和安卓统一逻辑，支持扫二维码
//        NSArray *array  = [metadataObject.type componentsSeparatedByString:@"."];
//        NSString *type = [array lastObject];
//
//        if (!self.isScanQRCode && [type isEqualToString:@"QRCode"]) {
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [_session startRunning];
//            });
//            [self showToast:[NSString stringWithFormat:@"不支持扫二维码"]];
//            return;
//        }
    }
    
    if ([self isHasSeverObjid] && stringValue.length > 0 ) { //SFA-29916
        [self requestBarcodeDetail:stringValue];
        return;
    }

    //SFA-24449
    if ([self.dependentWidget respondsToSelector:@selector(isScanResultLuaHandleWithScanResult:)]) {
        if ([self.dependentWidget isScanResultLuaHandleWithScanResult:stringValue]) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [_session startRunning];
                
            });
            
            return;
        }
    } else {
        if (self.qRTypeView && [self.qRTypeView respondsToSelector:@selector(runScript:result:)]) {
            if ([self.qRTypeView runScript:self result:stringValue]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [_session startRunning];
                    
                });
                return;
            }
        }
    }

    [self validateScanResult:stringValue];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [_session startRunning];
        
    });
}

#pragma mark - 验证扫描结果方法
- (void)validateScanResult:(NSString *)scanResult {
    
    if (!scanResult || scanResult.length <= 0) {
        return;
    }
    
    for (NSString *result in self.barcodeList) {
        if (result && [result isEqualToString:scanResult]) {
            break;
        }
    }
    
    if (self.maxCount && self.barcodeList.count >= self.maxCount) {
        NSString *info = [NSString stringWithFormat:NSLocalizedString(@"已超过允许扫码的最大个数%d个", nil), self.maxCount];
        [self showToast:info];
        return;
    }
    
    if ([self.currentFuncs.ds isEqualToString:SCANQUERY]) {
        [self checkCodeResultWithRequest:scanResult];
    } else {
        [self checkBarCodeAndAddQRList:scanResult];
    }
}

- (void)checkBarCodeAndAddQRList:(NSString*)barCodeString
{
//     NSString *luaScript = [self.dependentWidget.xbuildInfo getLuaScript];
//    if (self.dependentWidget && luaScript && ![luaScript isEqualToString:@""]) {
//        if ([self.dependentWidget.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
//            self.dependentWidget.resultCheck = barCodeString;
//            [self.dependentWidget.delegate executeLuaScript:self.dependentWidget.xbuildInfo widget:self.dependentWidget];
//        }
//    }else{
    
        [self getReturnDataFromLua:barCodeString];
//    }
    
}

- (void)getReturnDataFromLua:(NSString *)returnData
{
    if ([returnData length] > 0) {
        [self doCheckBarCode:returnData];
    }else {
//        [self showToast:@"条码数据非法！"];
        [_session stopRunning];
        NSString *tipMessageStr = NSLocalizedString(@"illegal_barcode", nil);
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:tipMessageStr];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
            [_session startRunning];
        }];
        [alert show];

    }
}

- (void)doCheckBarCode:(NSString *)barCodeString
{
    NSMutableArray *prodArray = [NSMutableArray array];
    if (self.allProducts.count > 0) {
        for (WSProdBean *prod in self.allProducts) {
            if (prod.barcod.length > 0 && [prod.barcod isEqualToString:barCodeString]) {
                [prodArray addObject:prod];
            }
            //YIHAIKERRY-5111
            if (prod.barcode2.length > 0) {
                NSArray *barcodArray = [prod.barcode2 componentsSeparatedByString:PRODUCT_BARCODE_SEPARATOR];
                if ([barcodArray containsObject:barCodeString]) {
                    [prodArray addObject:prod];
                }
            }
        }
        if ([prodArray count] == 0) {
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"barcode_not_in_prods", nil),barCodeString];
            [self showToast:message];
            return;
        }
        
        
        NSArray *filterArray = [self filterBarcodeAdded:prodArray];
        if (!filterArray) {
            NSString *message;
            if ([prodArray count] == 1) {
                WSProdBean *prodBean = prodArray[0];
                message = [NSString stringWithFormat:NSLocalizedString(@"barcode_added", nil),prodBean.name];
            } else {
                message = [NSString stringWithFormat:NSLocalizedString(@"barcode_prod_added", nil)];
            }
            [self showToast:message];
            return;
        }
        
        if ([filterArray count] > 1) {
            if (!self.selectView) {
                self.selectView = [[WSScanSelectView alloc] initWithFrame:self.view.bounds];
                self.selectView.delegate = self;
            }
            [self.selectView setDataArray:filterArray];
            [self.view addSubview:self.selectView];
        } else {
            // 一个条码只对应一个产品的时候才校验码是否扫过，否则一个码对应多个产品时出错。
            if ([prodArray count] == 1) {
                BOOL isScanned = [self checkBarcodeScanned:barCodeString];
                if (isScanned) {
                    return;
                }
            }
            [self.barcodeList addObject:barCodeString];
            // 添加产品到 qrList
            [self.qrList addObjectsFromArray:filterArray];
        }
    } else {
        BOOL isScanned = [self checkBarcodeScanned:barCodeString];
        if (isScanned) {
            return;
        }
        
        [self.barcodeList addObject:barCodeString];
        
        // 添加条码到 qrList
        [self.qrList addObject:barCodeString];
    }
    
    [_session stopRunning];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    self.isProductExist = NO;
    
    [self.tableView reloadData];
    
    //如果扫描到合格的条码数与最大数相等的话，自动返回  安卓的逻辑 YIHAIKERRY-3136稍加修改 增加self.maxCount为0判断
    if ((self.maxCount > 0) && (self.qrList.count == self.maxCount))
    {
        [self confirmCompletion:nil];
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_session startRunning];
    });
    
    [self showToast:[NSString stringWithFormat:NSLocalizedString(@"scan_success",nil),barCodeString]];
}

- (BOOL)checkBarcodeScanned:(NSString *)barCodeString {
    if (![self.barcodeList containsObject:barCodeString]) {
        return NO;
    }
    
    if (self.isProductExist == NO) {
        [_session stopRunning];
        NSString *tipMessageStr = NSLocalizedString(@"duplicate_barcode", nil);
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:tipMessageStr];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
            [_session startRunning];
            self.isProductExist = NO;
        }];
        [alert show];
        self.isProductExist = YES;
    }
    return YES;
}

// 可能存在相同条码对应多个产品的情况，过滤掉已经添加到表格的产品
- (NSArray *)filterBarcodeAdded:(NSArray *)prodArray {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:prodArray];
    for (WSProdBean *visiableProdBean in self.visiableProducts) {
        for(WSProdBean *prodBean in prodArray) {
            if ([prodBean.Id isEqualToString:visiableProdBean.Id]) {
                [tempArray removeObject:prodBean];
            }
        }
    }
    
    for (WSProdBean *addedProdBean in self.qrList) {
        for(WSProdBean *prodBean in prodArray) {
            if ([prodBean.Id isEqualToString:addedProdBean.Id]) {
                [tempArray removeObject:prodBean];
            }
        }
    }
    
    if ([tempArray count] > 0) {
        return [tempArray copy];
    } else {
        return nil;
    }
}


-(void)scanAnimation
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake((self.view.width - 220)/2.0, PreViewYOffset+ MAIN_PADDING * 2+ 2*num, 220, 2);
        NSInteger bottom;
        if (INTERFACE_IS_PHONE) {
            bottom = 180;
        } else {
            bottom = 300;
        }
        if (2*num == bottom) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake((self.view.width - 220)/2.0, PreViewYOffset+ MAIN_PADDING * 2+2*num, 220, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
}



- (void) showToast:(NSString *)message
{
    
    if (message.length >0) {
         [MBProgressHUD showHUDAddedTo:self.view withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}

- (void) showOrHiddenTableView
{
    if (self.qrList && [self.qrList count] > 0) {
        
        self.tableView.hidden = NO;
    }else{
        
        self.tableView.hidden = YES;
    }
}

#pragma mark - WSScanSelectedDelegate
- (void)selectedData:(NSArray *)selectedArray {
    if ([selectedArray count] > 0) {
        WSProdBean *prodBean = selectedArray[0];
        [self.barcodeList addObject:prodBean.barcod];
        [self.qrList addObjectsFromArray:selectedArray];
        
        [self.tableView reloadData];
    }
}

#pragma mark - public and block

-(void) showQRViewControllerToViewController:(UIViewController*)parentViewController
                                   WithBlock:(UPLoadProductListBlock)listBlock
{
    WSCameraAuthHelper *cameraHelper = [[WSCameraAuthHelper alloc] init];
    [cameraHelper authCameraWithBlock:^(BOOL isOK) {
        if (isOK) {
            self.productListBlock = listBlock;
            self.modalPresentationStyle = UIModalPresentationFullScreen;
            [parentViewController presentViewController:self animated:YES completion:nil];
        } else {
            self.productListBlock = nil;
        }
    }];
}

- (void)setVisibleProducts:(NSArray*)vDataSource andAllProducts:(NSArray*)aDataSource
{
    self.allProducts = aDataSource;
    self.visiableProducts = vDataSource;
}


- (void)checkCodeResultWithRequest:(NSString*)barCodeString {
    
    BOOL isScanned = [self checkBarcodeScanned:barCodeString];
    if (isScanned) {
        return;
    }
    [_session stopRunning];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:SCANVALIDATE_NOTIFY
                                               object:nil];
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    NSMutableDictionary *parmDic = [[uploadMgr getNormalParam] mutableCopy];
    [parmDic setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]] forKey:APPDATA_BIZDATE];
    [parmDic setObject:[UIDevice getPreferredLanguage] forKey:LANGUAGE];
    [parmDic setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] forKey:@"empId"];
    [parmDic setObject:@"1" forKey:@"compress"];
    [parmDic setObject:SCANQUERY forKey:@"objId"];
    [parmDic setObject:self.currentStore.Id forKey:@"store"];
    [parmDic setObject:self.currentStore.Id forKey:@"storeId"];
    [parmDic setObject:barCodeString forKey:@"imeiCode"];
    
    [uploadMgr postRequestData:parmDic notifyName:SCANVALIDATE_NOTIFY];
    
}

- (void)finishRequest:(id)sender {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SCANVALIDATE_NOTIFY
                                                  object:nil];
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSDictionary *dic = [info objectFromJSONString];
    NSDictionary *scanQueryDic = [dic objectForKey:@"scanQuery"];
    NSString *msg = [scanQueryDic objectForKey:@"msg"];
    NSString *validateMessage = [scanQueryDic objectForKey:@"validateMessage"];
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:msg subMessage:validateMessage subColor:[UIColor redColor] alignment:BlockAlertViewAlignmentLeft subMessageAlignment:BlockAlertViewAlignmentCenter ];
    [alert setCancelButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
        [_session startRunning];
    }];
    [alert show];
}

#pragma -mark- 请求物流码对应的产品信息
- (void)requestBarcodeDetail:(NSString *)barCodeString {
   
    [self stopScan];
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"refresh_prompt", nil) tips:nil
                        tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestBarCodeDetailsFinish:)
                                                 name:SCANCodeDetail_NOTIFY
                                               object:nil];
    
    WSLocationDescribe *locationDesrible = [WSLocationManager getInstance].lastLocation;
    NSString *loc_addr = locationDesrible.detailAddress;
    NSString *lat = [NSString stringWithFormat:@"%f",locationDesrible.location.coordinate.latitude];
    NSString *lon = [NSString stringWithFormat:@"%f",locationDesrible.location.coordinate.longitude];
   
    NSString *objId = [self getObjid];
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    NSMutableDictionary *parmDic = [[uploadMgr getNormalParam] mutableCopy];
    [parmDic setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]] forKey:APPDATA_BIZDATE];
    [parmDic setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] forKey:@"empId"];
    [parmDic setObject:@"1" forKey:@"compress"];
    [parmDic setObject:objId forKey:@"objId"];
    [parmDic setObject:barCodeString forKey:@"imeiCode"];
    [parmDic setObject:[NSString stringNotNilWithValue:loc_addr] forKey:@"loc_addr"];
    [parmDic setObject:lat forKey:@"lat"];
    [parmDic setObject:lon forKey:@"lon"];
    
    if (self.currentStore) { //对店
        [parmDic setObject:[NSString stringNotNilWithValue:self.currentStore.Id] forKey:@"storeId"];
        [parmDic setObject:[NSString stringNotNilWithValue:self.currentStore.name] forKey:@"storeName"];
    }else { //对人
        NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kPropertyUserDefaultsKey];
        NSString *inputStorename = [dictionary objectForKey:@"INPUT_STORE_NAME"];
        [parmDic setObject:[NSString stringNotNilWithValue:inputStorename] forKey:@"storeName"];
        [parmDic setObject:@"" forKey:@"storeId"];
    }

    [uploadMgr postRequestData:parmDic notifyName:SCANCodeDetail_NOTIFY];
    
}

#pragma -mark- 请求成功的回调
- (void)requestBarCodeDetailsFinish:(id)sender {
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCANCodeDetail_NOTIFY object:nil];
    
    // 解析数据
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    
    NSString *objId =  [self getObjid];
    
    NSDictionary *dic = [info objectFromJSONString];
    NSDictionary  *results = [dic objectForKey:objId];
    NSString *flag = [NSString stringWithValue:[dic objectForKey:@"flag"]];
    
    if (error)
    {
        NSString *errDescription = [error ws_localizedDescription];
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil)  message:errDescription];
        [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
            [self resetScanStart];
        }];
        [alert show];
        return;
    }
    
    if ([flag isEqualToString:@"0"]) {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil)   message:NSLocalizedString(@"refresh_failure", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
            [self resetScanStart];
        }];
        [alert show];
        return;
        
    }else {
        NSString *msg  =  results[@"msg"];
//      NSString *prodId = results[@"id"];
//      NSString *prodName = results[@"name"];
        NSDictionary *data = results[@"data"];
        
        NSString *tipStrings = nil;
        if (msg && msg.length > 0) {//弹出提示：
            //
            tipStrings = msg;
            BlockAlertView *alert = [BlockAlertView alertWithTitle:@"货源信息" message:tipStrings alignment:BlockAlertViewAlignmentLeft];
            [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
                [self resetScanStart];
            }];
            [alert show];
            
        }else { //弹出提示：
            NSArray *allkeys = [data allKeys];
            NSMutableArray  *arr = [NSMutableArray array];
            for (int i = 0; i < allkeys.count; i ++) {
                NSString *key = allkeys[i];
                NSDictionary *valueDic = data[key];
                NSNumber *sort = valueDic[@"sort"];
                NSString *val =[NSString stringNotNilWithValue:valueDic[@"val"]] ;

                NSString *itemString = [NSString stringWithFormat:@"%@:%@",key,val];
              
                if (sort) {
                    NSDictionary *sortDic = @{@"sort":sort,@"value":itemString};
                    [arr addObject:sortDic];
                }
            }
            
            NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sort" ascending:YES]];
            [arr sortUsingDescriptors:sortDescriptors];   //排序
            
            NSMutableArray *keyValueArray = [NSMutableArray array];
            for (int i = 0; i <arr.count; i ++) {
             NSDictionary *dic = arr[i];
                NSString *itemString =dic[@"value"] ;
                [keyValueArray addObject:itemString];
            }
            
            tipStrings =  [keyValueArray componentsJoinedByString:@"\n"];
            BlockAlertView *alert = [BlockAlertView alertWithTitle:@"货源信息" message:tipStrings alignment:BlockAlertViewAlignmentLeft];
            [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:^{
                [self resetScanStart];
            }];

            [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
                
                if (self.wcBaseViewdelegate && [self.wcBaseViewdelegate respondsToSelector:@selector(callBackWhenFinishTask:)]) {   //将添加到表格中
                    self.executeParam.execute_result = results;
                    [self.wcBaseViewdelegate callBackWhenFinishTask:self.executeParam];
                }
                [self resetScanStart];
            }];
            [alert show];
            
        }
        
    }
    
}
-(NSString *)getObjid {
    
    NSObject<I_W_BuildInfo> *buildInfo = (NSObject<I_W_BuildInfo> *)[self.executeParam inner_param];
    if ([buildInfo conformsToProtocol:@protocol(I_W_BuildInfo) ] ) {
        NSString *objId = [buildInfo getAcvtMemo2];
        return objId ? objId : @"";
    }
    return @"";
    
}
- (BOOL)isHasSeverObjid {
    NSString * serverObjId = [self getObjid];
    if(serverObjId.length > 0) { //SFA-29916 在扫描过程中，有弹出确定按钮，就已经把产品添加到表格中，此处不需要处理了
        return YES;
    }
    return NO;
}
//重新开启扫描 和动画（横线上下动）
- (void)resetScanStart {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startTimer];
        [_session startRunning];
    });
}
//关闭扫描 和动画
- (void)stopScan {
    [self  stopTimer];
    [_session stopRunning];
}
- (void)stopTimer {
    [timer setFireDate:[NSDate distantFuture]];
}
- (void)startTimer {
    [timer setFireDate:[NSDate distantPast]];
}
@end
