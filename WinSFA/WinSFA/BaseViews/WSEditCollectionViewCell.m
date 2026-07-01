//
//  WSEditCollectionViewCell.m
//  WinSFA
//
//  Created by zhangmin on 2018/11/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSEditCollectionViewCell.h"
#import "WSWidget.h"
#import "WSWidgetFactory.h"
#import "YYModel.h"
#import "WSEditCellBaseView.h"

@interface WSEditCollectionViewCell ()
{
    WSEditCellBaseView *_cellView;
}

@end

@implementation WSEditCollectionViewCell

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
    self.backgroundColor = [UIColor clearColor];
}

- (void)setModel:(WSDataGridPartModel *)model
{
    _model = model;
    
    WSAcvtBean_qst *acvtQst = _model.acvtQst;
    acvtQst.widgetType = @"dataGridWidgetType";
    
    [acvtQst setLayOutInfo:CGRectMake(0, 1, model.width * 2, model.height)];
    
    if (model.width != 0){
        if (!_cellView) {
            _cellView = [[WSEditCellBaseView alloc] initWithFrame:CGRectMake(0, 0, model.width, model.height ) andDataGridModel:model];
        }else{
            [_cellView removeFromSuperview];
        }

        [self.contentView addSubview:_cellView];

    }
    
}

- (void)layoutSubviews
{
//    if (_cellView && _model) {
//        [_cellView setFrame:CGRectMake(0, 15, _model.width, _model.height-15)];
//    }
}

- (void)setTextFieldBecomeFirstResonder {
    [_cellView setTextFieldBecomeFirstResonder];
}


@end
