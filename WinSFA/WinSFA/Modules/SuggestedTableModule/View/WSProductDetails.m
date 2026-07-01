//
//  WSProductDetails.m
//  WinSFA
//
//  Created by huzepei on 16/7/11.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSProductDetails.h"
#import "WSSuggestWholesale.h"

@interface WSProductDetails()  
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *profitsLabel;

@property (weak, nonatomic) IBOutlet UILabel *salesLabel;

@property (weak, nonatomic) IBOutlet UILabel *proAttributeLabel;
- (IBAction)removeProductDetails:(id)sender;

@end
@implementation WSProductDetails

+ (instancetype)productDetailView
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}

-(void)setSp:(WSSuggestPro *)sp
{
    _sp = sp;
    _productNameLabel.text = _sp.name;
    _profitsLabel.text = _sp.boxProfits;
    _salesLabel.text = _sp.month_sales;
    _proAttributeLabel.text = _sp.memo4;
}

- (IBAction)removeProductDetails:(id)sender {
    
    if (_callBack) {
        _callBack();
    }
}
@end
