//
//  WSDataGridCellBaseView.m
//  WinSFA
//
//  Created by HZH on 2017/7/22.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSDataGridCellBaseView.h"
#import "WSWidgetFactory.h"
#import "WSProdGrideWithExpandableBrandsViewController.h"
#import "WSLabelPanel.h"
#import "WSNumberTextFiledPanel.h"
#import "WSNewAddProdsWithSeriesViewController.h"

@interface WSDataGridCellBaseView ()
{
    WSDataGridPartModel *_dataGridModel;
}

@end

@implementation WSDataGridCellBaseView

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        
        return self;
    }
    
    return nil;
}

-(id)initWithFrame:(CGRect)frame andDataGridModel:(WSDataGridPartModel *)model{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _dataGridModel = model;
        
        [self setupViews];
        
        return self;
    }
    
    return nil;
}

- (void)setupViews {

    if (!_widget) {
        self.widget = [[WSWidgetFactory shareInstance] createWidgetByWidgetInfo:_dataGridModel.acvtQst];
    }else{
        [self.widget removeFromSuperview];
    }
    
    self.widget.delegate = self;
//    [widget.xbuildInfo setLayOutInfo:widgetFrame];
    
    if ([_dataGridModel.widgetType isEqualToString:@"dataHeadWidget"]) {
        _widget.backgroundColor = [UIColor colorWithHexString:@"0xf1f1f1"];
    }
    
    if (_dataGridModel.valueStr && _dataGridModel.valueStr.length > 0 && ![_dataGridModel.valueStr isEqualToString:@"null"]) {
//        [widget setDefaultValue:_dataGridModel.valueStr];
        [_widget setCurrentValueWithPresentation:_dataGridModel.valueStr];

    }
    
//    widget.layer.borderWidth = 1.0;
//    widget.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    
    [self addSubview:_widget];
}

-(void)buildDisplayContent{
    
    
    
}

- (void)layoutSubviews
{
    if (_widget) {
        
        CGRect widgetFrame = _widget.frame;
        widgetFrame.origin.y = 0.0;
        widgetFrame.size.height = self.frame.size.height + 1;
        widgetFrame.size.width = self.frame.size.width;
        _widget.frame = widgetFrame;
        
        // YIHAIKERRY-579 按UI修改单元格内容距离
        if ([_widget isKindOfClass:[WSLabelPanel class]]) {
            WSLabelPanel *labelPanel = (WSLabelPanel *)_widget;
            CGRect titleLabelFrame = labelPanel.titleLabel.frame;
            titleLabelFrame.origin.x = 5.0;
            titleLabelFrame.origin.y = 10.0;
            
            titleLabelFrame.size.width = self.frame.size.width - 20.0;
            titleLabelFrame.size.height = self.frame.size.height - 20.0;
            
            [labelPanel setTitleLabelFrame:titleLabelFrame];
            [labelPanel setTitleLabelFont:FONT_SIZE_PINGFANG_MEDIUM(13.0)];
            [labelPanel setTitleLabelColor:[UIColor colorWithHexString:@"0x585858"]];
        }
        
        if ([_widget isKindOfClass:[WSNumberTextFiledPanel class]]) {
            WSNumberTextFiledPanel *numberTextFiledPanel = (WSNumberTextFiledPanel *)_widget;
            numberTextFiledPanel.isNeedResetTitleTextFieldFrame = NO;
            //  SFA-20601
            //  预售新增订单，选择产品后数量输入值后手机端字段显示不全
            numberTextFiledPanel.titleLabel.frame = CGRectZero;
            if (numberTextFiledPanel.textField.frame.size.height <= numberTextFiledPanel.frame.size.height) {
//                CGRect textFieldFrame = numberTextFiledPanel.textField.frame;
                CGRect textFieldFrame = numberTextFiledPanel.frame;
                textFieldFrame.origin.x = 2.5;
                textFieldFrame.origin.y = 0.0;
                textFieldFrame.size.width = numberTextFiledPanel.frame.size.width - 5.0;
                textFieldFrame.size.height = numberTextFiledPanel.frame.size.height;

                numberTextFiledPanel.textField.frame = textFieldFrame;
            }
            
            [numberTextFiledPanel.textField setFont:FONT_SIZE_PINGFANG_MEDIUM(13.0)];
            [numberTextFiledPanel.textField setTextColor:[UIColor colorWithHexString:@"0x585858"]];
           
        }
        
        CGPoint widgetCenterPoint = _widget.center;
        widgetCenterPoint.y = self.center.y;
        _widget.center = widgetCenterPoint;
    }
    
}

- (void)widget:(WSWidget *)widget valueChanged:(BOOL)isValueChangedCompareWithOrigin
{
    NSLog(@"----------------widget:(WSWidget *)widget valueChanged:(BOOL)isValueChangedCompareWithOrigin");
    
    if ([self.viewController isKindOfClass:[WSProdGrideWithExpandableBrandsViewController class]]) {
        WSProdGrideWithExpandableBrandsViewController *vc = (WSProdGrideWithExpandableBrandsViewController *)self.viewController;
        
        [vc gridWidgetValueChangeWithWidget:widget andDataGridModel:_dataGridModel];
    }else if ([self.viewController isKindOfClass:[WSNewAddProdsWithSeriesViewController class]]) {
        WSNewAddProdsWithSeriesViewController *vc = (WSNewAddProdsWithSeriesViewController *)self.viewController;
        
        [vc gridWidgetValueChangeWithWidget:widget andDataGridModel:_dataGridModel];
    }
}

- (void)setTextFieldBecomeFirstResonder {
    if ([_widget isKindOfClass:[WSNumberTextFiledPanel class]]) {
        WSNumberTextFiledPanel *numberTextFiledPanel = (WSNumberTextFiledPanel *)_widget;
        [numberTextFiledPanel.textField becomeFirstResponder];
    }
}



@end
