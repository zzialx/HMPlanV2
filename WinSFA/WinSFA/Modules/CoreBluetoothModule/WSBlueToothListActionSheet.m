//
//  WSBlueToothListActionSheet.m
//  WinSFA
//
//  Created by sunhongfu on 2017/12/13.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSBlueToothListActionSheet.h"

static NSString *identifier = @"blutToothCell";
//===================================================================================================================================================================

@interface WSBlueToothListActionSheet () {
    UITableView *blueToothTableView;//蓝牙列表
    NSString *_printParam;          //打印数据
}

@property (nonatomic, strong) NSArray *deviceArray;                         //蓝牙设备个数
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;   //等待框动画
@property (nonatomic, weak) SEPrinterManager *manager;                      //蓝牙打印manager
@property (nonatomic, weak) UIViewController *baseViewController;           //记录父VC

- (void)handleSingleTapFrom:(UITapGestureRecognizer *)tap; //手势点击响应方法

@end
//===================================================================================================================================================================

@interface WSBlueToothListActionSheet (Tools)

- (void)resetSubviewStatus:(CBPeripheral *)peripheral;  //打印成功和失败都要消失等待动画和断开蓝牙

@end
//===================================================================================================================================================================

@interface WSBlueToothListActionSheet (tableViewDelegateAndDataSource) <UITableViewDelegate, UITableViewDataSource>

@end
//===================================================================================================================================================================

@interface WSBlueToothListActionSheet (gestureRecognizerDelegate) <UIGestureRecognizerDelegate>

@end
//===================================================================================================================================================================

@implementation WSBlueToothListActionSheet

#pragma mark - 初始化方法
- (id)initWithFrame:(CGRect)frame WithBaseController:(UIViewController *)baseController withSEPrinterManager:(SEPrinterManager *)manager withPrintParam:(NSString *)printParam {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.5];
        
        UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
        singleRecognizer.delegate = self;
        singleRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:singleRecognizer];
        
        _manager = manager;
        _printParam = printParam;
        _baseViewController = baseController;
        
        _deviceArray = [NSMutableArray array];
        
        blueToothTableView = [[UITableView alloc]initWithFrame:CGRectMake(10, SCREEN_HEIGHT, baseController.view.width -20,
                                                                          baseController.view.height-100) style:UITableViewStylePlain];
        blueToothTableView.delegate = self;
        blueToothTableView.dataSource = self;
        blueToothTableView.backgroundColor = RGB_COLOR(@"#ffffff");
        blueToothTableView.layer.masksToBounds = YES;
        blueToothTableView.layer.cornerRadius = 2.0;
        [self addSubview:blueToothTableView];
        
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        _activityIndicator.frame= CGRectMake(100, 100, 100, 100);
        _activityIndicator.color = [UIColor grayColor];
        _activityIndicator.backgroundColor = [UIColor clearColor];
        _activityIndicator.hidesWhenStopped = NO;
        _activityIndicator.center = blueToothTableView.center;
    }
    return self;
}

#pragma mark - 手势点击响应方法
- (void)handleSingleTapFrom:(UITapGestureRecognizer *)tap {
    
    [self dismissSelf];
}

#pragma mark - 重载打印参数方法
- (void)reloadPrintParam:(NSString *)printParam {
    
    _printParam = ((printParam.length > 0) ? printParam : @"");
}

#pragma mark - 释放方法
- (void)dismissSelf {
    
    [UIView animateWithDuration:0.25 animations:^{
        blueToothTableView.frame = CGRectMake(10, SCREEN_HEIGHT, self.baseViewController.view.width - 20, self.baseViewController.view.height - 100);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - 展示方法
- (void)show {
    
    [self.baseViewController.view addSubview:self];
    [UIView animateWithDuration:0.25 animations:^{
        blueToothTableView.frame = CGRectMake(10, (self.baseViewController.view.height - (self.baseViewController.view.height - 100)) / 2,
                                              self.baseViewController.view.width - 20, self.baseViewController.view.height - 100);
    }];
    
    __weak __typeof(self) weakSelf = self;
    [self.manager startScanPerpheralTimeout:0 Success:^(NSArray<CBPeripheral *> *perpherals,BOOL isTimeout) {
        
        weakSelf.deviceArray = perpherals;
        [blueToothTableView reloadData];
        
        [weakSelf.activityIndicator stopAnimating];
        [weakSelf.activityIndicator removeFromSuperview];
        
        if (isTimeout || weakSelf.deviceArray.count <= 0) {
            if (self.manager.isStatePoweredOn) {
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"未发现可用的蓝牙设备" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
            }
            [weakSelf dismissSelf];
        }
    }failure:^(SEScanError error) {
        
        [weakSelf.activityIndicator stopAnimating];
        [weakSelf.activityIndicator removeFromSuperview];
        
        if (self.manager.isStatePoweredOn) {
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"未发现可用的蓝牙设备" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        }
        [self dismissSelf];
    }];
}

@end
//===================================================================================================================================================================

@implementation WSBlueToothListActionSheet (Tools)

#pragma mark - 打印成功和失败都要消失等待动画和断开蓝牙
- (void)resetSubviewStatus:(CBPeripheral *)peripheral {
    
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    [self.manager cancelPeripheral:peripheral];
}

@end
//===================================================================================================================================================================

@implementation WSBlueToothListActionSheet (tableViewDelegateAndDataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    CBPeripheral *peripheral = [self.deviceArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"名称:%@",peripheral.name];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBPeripheral *peripheral = [self.deviceArray objectAtIndex:indexPath.row];
    
    [self.baseViewController.view addSubview:self.activityIndicator];
    self.activityIndicator.center = self.baseViewController.view.center;
    [self.activityIndicator startAnimating];
    
    __weak WSBlueToothListActionSheet *weakSelf = self;
    
    [self.manager fullOptionPeripheral:peripheral completion:^(SEOptionStage stage, CBPeripheral *perpheral, NSError *error) {
        
        if (error) {
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"连接失败,请重新尝试" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            [weakSelf resetSubviewStatus:peripheral];
            [weakSelf dismissSelf];
            return;
        }
        
        if (stage != SEOptionStageSeekCharacteristics) {
            return;
        }
        
        HLPrinter *printer = [[HLPrinter alloc] init];
        NSArray *paramsArray = [_printParam componentsSeparatedByString:@"@printSpit@"]; //@printSpit@分割 最后一个元素为图片 其它元素是文本
        for (int i = 0; i < paramsArray.count; i++) {
            
            if ((paramsArray.count == 1) || ((paramsArray.count > 1) && (i < paramsArray.count - 1))) {
                
                NSString *text = paramsArray[i];
                NSArray *textParamsArray = [text componentsSeparatedByString:@"@pageSpit@"]; //页码分隔符号
                
                for(int ii = 0; ii < textParamsArray.count; ++ii) {
                    
                    NSString *text2 = textParamsArray[ii];
                    NSArray *textParamsArray2 = [text2 componentsSeparatedByString:@"@titleSpit@"]; //@titleSpit@分割 第一个元素剧中 其它元素居左
                    
                    if(textParamsArray2.count > 1){
                        
                        for (int iii = 0; iii < textParamsArray2.count; iii++){
                            
                            NSString *str = textParamsArray2[iii];
                            if(iii == 0)
                                [printer appendText:((str.length > 0) ? str : @"") alignment:HLTextAlignmentCenter];
                            else
                                [printer appendText:((str.length > 0) ? str : @"") alignment:HLTextAlignmentLeft];
                        }
                    }
                    else{
                        [printer appendText:((text2.length > 0) ? text2 : @"") alignment:HLTextAlignmentLeft];
                    }
                }
            }
            else {
                UIImage *printerImg = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:paramsArray[i]];
                if (printerImg == nil) {
                    NSData *imgData = [NSData dataWithContentsOfFile:paramsArray[i]];
                    printerImg = [UIImage imageWithData:imgData];
                }
                [printer appendImage:printerImg alignment:HLTextAlignmentCenter maxWidth:300];
            }
        }
        
        [printer appendText:@" " alignment:HLTextAlignmentCenter];
        [printer appendText:@" " alignment:HLTextAlignmentCenter];
        [printer appendText:@" " alignment:HLTextAlignmentCenter];
        
        NSData *mainData = [printer getFinalData];
        [weakSelf.manager sendPrintData:mainData completion:^(CBPeripheral *connectPerpheral, BOOL completion, NSString *error) {
            
            if (!completion) {
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:error tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            }
            [weakSelf resetSubviewStatus:perpheral];
            [weakSelf dismissSelf];
        }];
    }];
}

@end
//===================================================================================================================================================================

@implementation WSBlueToothListActionSheet (gestureRecognizerDelegate)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == self) {
        return YES;
    } else {
        return NO;
    }
}

@end
//===================================================================================================================================================================

