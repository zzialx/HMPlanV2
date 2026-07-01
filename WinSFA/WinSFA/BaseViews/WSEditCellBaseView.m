//
//  WSEditCellBaseView.m
//  WinSFA
//
//  Created by zhangmin on 2018/11/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSEditCellBaseView.h"
#import "WSWidgetFactory.h"
#import "WSProdGrideWithExpandableBrandsViewController.h"
#import "WSLabelPanel.h"
#import "WSNumberTextFiledPanel.h"
#import "WSNewAddProdsWithSeriesViewController.h"
#import "WSTextViewWithRangePanel.h"
#import "WSValidateTextView.h"



@interface WSEditCellBaseView ()
{
    WSDataGridPartModel *_dataGridModel;
}

@end

@implementation WSEditCellBaseView



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
    _widget.backgroundColor =  [UIColor clearColor];

    self.widget.delegate = self;
    
    if (_dataGridModel.valueStr && _dataGridModel.valueStr.length > 0 && ![_dataGridModel.valueStr isEqualToString:@"null"]) {
        [_widget setCurrentValueWithPresentation:_dataGridModel.valueStr];
    }
    
    [self addSubview:_widget];
    
    ///////8888
    [self resetFrame];
}

- (void)resetFrame {
   
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
            titleLabelFrame.origin.x = 0.0;
            titleLabelFrame.origin.y = 0.0;
            
            titleLabelFrame.size.width = self.frame.size.width ;
            titleLabelFrame.size.height = self.frame.size.height ;
            
            
            [labelPanel setTitleLabelFrame:titleLabelFrame];
            [labelPanel setTitleLabelFont:FONT_SIZE_PINGFANG_MEDIUM(13.0)];
            [labelPanel setTitleLabelColor:[UIColor colorWithHexString:@"0x666666"]];
            labelPanel.titleLabel.hidden = NO;
            labelPanel.titleLabel.textAlignment = NSTextAlignmentCenter;
            
        }
        
        if ([_widget isKindOfClass:[WSNumberTextFiledPanel class]]) {
            WSNumberTextFiledPanel *numberTextFiledPanel = (WSNumberTextFiledPanel *)_widget;
            
            numberTextFiledPanel.isfillAll = YES;
            
            numberTextFiledPanel.isNeedResetTitleTextFieldFrame = NO;
  
            CGRect textFieldFrame = numberTextFiledPanel.frame;
            textFieldFrame.origin.x = 0;
            textFieldFrame.origin.y = 0.0;
            textFieldFrame.size.width = numberTextFiledPanel.frame.size.width ;
            textFieldFrame.size.height = numberTextFiledPanel.frame.size.height - 20;
            
            numberTextFiledPanel.textField.frame = textFieldFrame;
        
            
            [numberTextFiledPanel.textField setFont:FONT_SIZE_PINGFANG_MEDIUM(13.0)];
            [numberTextFiledPanel.textField setTextColor:[UIColor colorWithHexString:@"0x585858"]];

        }
        
        
        if ([_widget isKindOfClass:[WSTextViewWithRangePanel class]]) {
            WSTextViewWithRangePanel *textViewWithRangePanel = (WSTextViewWithRangePanel *)_widget;
            CGRect titleLabelFrame =textViewWithRangePanel.textView.frame ;

            titleLabelFrame.origin.x = 0.0;
            titleLabelFrame.origin.y = 5.0;
            titleLabelFrame.size.width = self.frame.size.width ;
            titleLabelFrame.size.height = self.frame.size.height - 5 ;

            [textViewWithRangePanel.textView setFrame:titleLabelFrame];
            textViewWithRangePanel.textView.font = FONT_SIZE_PINGFANG_MEDIUM(13.0);
            
            }
            
        
            
        }
    
    CGPoint widgetCenterPoint = _widget.center;
    widgetCenterPoint.y = self.center.y;
    _widget.center = widgetCenterPoint;
   
    
}
- (void)layoutSubviews
{

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

