//
//  WSDataGridCollectionViewCell.m
//  WinSFA
//
//  Created by HZH on 2017/7/17.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSDataGridCollectionViewCell.h"
#import "WSWidget.h"
#import "WSWidgetFactory.h"
#import "YYModel.h"
#import "WSDataGridCellBaseView.h"

@interface WSDataGridCollectionViewCell ()
{
    WSDataGridCellBaseView *_cellView;
}

@end

@implementation WSDataGridCollectionViewCell
- (WSWidget *)getWidget
{
    return _cellView.widget;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    
//    self.backgroundColor = [UIColor colorWithHexString:@"0xf1f1f1"];
//    self.layer.cornerRadius = 5.0;
//    self.layer.masksToBounds = YES;
    
//    NSString *jsonStr = @"{\"is_req\":0,\"acvtId\":\"FORMACVT@10\",\"qstId\":\"@2648@30197@memo10@5655@10\",\"qstCod\":\"memo10\",\"qstName\":\"学生购买的客单价大约是多少\",\"readonly\":0,\"sort\":20,\"qstType\":\"L\",\"orientation\":1,\"acvtQstId\":\"@2648@30197@memo10@5655@10\"}";
//    
//    WSAcvtBean_qst *acvtQst = [WSAcvtBean_qst yy_modelWithJSON:jsonStr];
    
    
//    [_model.acvtQst setLayOutInfo:CGRectMake(0, 0, 100, 44)];
//    
//    WSWidget  *widget = [[WSWidgetFactory shareInstance] createWidgetByWidgetInfo:_model.acvtQst];
//    [widget.xbuildInfo setLayOutInfo:widget.frame];
//
//    
//    [self.contentView addSubview:widget];
}

- (void)setModel:(WSDataGridPartModel *)model
{
    _model = model;
    
    WSAcvtBean_qst *acvtQst = _model.acvtQst;
    acvtQst.widgetType = @"dataGridWidgetType";
    
    [acvtQst setLayOutInfo:CGRectMake(0, 0, model.width, model.height)];
//
    
//    WSWidget  *widget = [[WSWidgetFactory shareInstance] createWidgetByWidgetInfo:acvtQst];
//    widget.delegate = self.contentView;
////    [widget.xbuildInfo setLayOutInfo:widget.frame];
//    
//    
//    if ([_model.widgetType isEqualToString:@"dataHeadWidget"]) {
//        widget.backgroundColor = [UIColor colorWithHexString:@"0xf1f1f1"];
//    }
//    
//    widget.layer.borderWidth = 1.0;
//    widget.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    if (model.width != 0){
        if (!_cellView) {
//            _cellView = [[WSDataGridCellBaseView alloc] initWithFrame:CGRectMake(0, 1, model.width, model.height - 1) andDataGridModel:model];
            _cellView = [[WSDataGridCellBaseView alloc] initWithFrame:CGRectMake(0, 1, model.width, model.height - 1) andDataGridModel:model];
        }else{
            [_cellView removeFromSuperview];
        }
        
        UIColor *headerBorderColor = [UIColor colorForKey:@"GridHeaderBorderColor"];
        if (!headerBorderColor) {
            headerBorderColor = [UIColor colorWithHexString:@"0xd9d9d9"];
        }
        UIView *topLine=[[UIView alloc] initWithFrame:CGRectMake(0, 0, _cellView.frame.size.width, 1)];
        topLine.backgroundColor = headerBorderColor;
        
        UIView *leftLine=[[UIView alloc] initWithFrame:CGRectMake(0, 11, 1, model.height -  21)];
        leftLine.backgroundColor = headerBorderColor;
        
        
        [self.contentView addSubview:_cellView];
        
        if (!_model.hideTopLine) {
            [self.contentView addSubview:topLine];
        }
        if (!_model.hideLeftLine) {
            [self.contentView addSubview:leftLine];
        }
    }
    
}

- (void)layoutSubviews
{
    if (_cellView && _model) {
        [_cellView setFrame:CGRectMake(0, 1, _model.width, _model.height)];
    }
}

- (void)setTextFieldBecomeFirstResonder {
    [_cellView setTextFieldBecomeFirstResonder];
}


@end
