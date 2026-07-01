//
//  WSQRTypeView.m
//  WinSFA
//
//  Created by mac on 16/12/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSQRTypeView.h"
#import "WSScanListViewController.h"
#import "WSAcvtModel.h"
#import "WSSetResultExecutor.h"
#import "WSDataSourceManager.h"

#define DATAGRID_TITLE_FONTSIZE  (INTERFACE_IS_PHONE ? 15.0 : 17.0)
#define TilteTextFont [UIFont fontWithName:@"Helvetica-Light" size:DATAGRID_TITLE_FONTSIZE]

#define TilteColor [UIColor colorWithHexString:@"#282828"]

@interface WSQRTypeView ()
@property (nonatomic, assign)BOOL isRequired;

@end

@implementation WSQRTypeView

@synthesize m_nRow = _m_nRow;
@synthesize m_nColumn = _m_nColumn;

-(instancetype)init{
    if (self = [super init]) {
        [self addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self setTitleColor:TilteColor forState:UIControlStateNormal];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.font = TilteTextFont;
    }
    
    return self;
}

-(void)buttonClick:(UIButton *)sender{

    NSLog(@"扫码");
    if (self.qrTypeViewClick) {
        if (self.qrTypeViewClick(self)) {
            return;
        }
    }
    [self startScanAction];
}

#pragma mark- 开始扫描
- (void)startScanAction {
    __weak typeof(self) weakself = self;
    NSInteger scanMaxCount = [[WSSetResultExecutor sharedInstance].result integerValue];
    WSScanListViewController * scanlistControl = [[WSScanListViewController alloc]init];
    scanlistControl.isScanQRCode = self.isScanQRCode;
    scanlistControl.qRTypeView = self;
    scanlistControl.barcodeList = [NSMutableArray arrayWithArray: [self.titleLabel.text componentsSeparatedByString:@","]];
    scanlistControl.maxCount = scanMaxCount;
    [scanlistControl showQRViewControllerToViewController:weakself.superview.viewController WithBlock:^(NSArray *aQRlist) {
        //
        NSLog(@"扫描成功");
        if (aQRlist.count > 0) {
            
            [weakself setImage:nil forState:UIControlStateNormal];
            if (aQRlist.count <= scanlistControl.maxCount) {
                NSString *title = nil;
                if (self.titleLabel.text.length > 0) {
                    title = [NSString stringWithFormat:@"%@,%@",self.titleLabel.text ,[aQRlist componentsJoinedByString:@","]];
                } else {
                    title = [NSString stringWithFormat:@"%@",[aQRlist componentsJoinedByString:@","]];
                }
                [weakself setTitle:title forState:UIControlStateNormal];

            } else {
                [weakself setTitle:[aQRlist firstObject] forState:UIControlStateNormal];
            }
            
        }else{
            [weakself setImage:[UIImage imageNamed:@"qr_code"] forState:UIControlStateNormal];
            
        }
    }];
}


- (void)setNotificationPrefix:(NSString *)aNotificationPrefix
                       andRow:(unsigned int)aRow
                    andColumn:(unsigned int)aColumn
                  andDataType:(WSValidateDataDependType)aDataType
{
    //    NSLog(@"%d--%s", __LINE__, __FUNCTION__);
    
    if (aNotificationPrefix == nil) return;
    
    self.iNotificationPrefix = aNotificationPrefix;
    //    self.iRow = aRow;
    //    self.iColumn = aColumn;
    self.m_nRow = aRow;
    self.m_nColumn = aColumn;
    self.iDataType = aDataType;
    
    if (self.iDataType == WSValidateDataDependOtherData){
        NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, aRow, aColumn];
        //        NSLog(@"notifyname = %@", notifyName);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateState:) name:notifyName object:nil];
    }
}

- (void)updateState:(NSNotification *)sender
{
    //    NSLog(@"%d--%s, %@", __LINE__, __FUNCTION__, sender);
    NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.m_nRow, self.m_nColumn];
    if (sender.name != nil && [sender.name isEqualToString:notifyName]) {
        NSNumber *number = (NSNumber *)sender.object;
        self.isRequired = [number boolValue];;
        [self setEnabled:self.isRequired];
    }
}

- (void)startObservingEntity {
    
}

- (BOOL)entityIsEnable
{
    return [self isEnabled];
}

- (BOOL)isValueLegal //SFA-15772 2018-1-3
{
    return (self.titleLabel.text != nil && self.titleLabel.text.length > 0);
}


- (void)dealloc
{
    //    NSLog(@"%d--%s", __LINE__, __FUNCTION__);

    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
@end
