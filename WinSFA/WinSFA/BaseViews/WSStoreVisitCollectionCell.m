//
//  WSStoreVisitCollectionViewCell.m
//  WinSFA
//
//  Created by Alicia on 17/1/19.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSStoreVisitCollectionCell.h"
#import "WSSelectListNewTableviewCell.h"
#import "WSSelectScrollListTableViewCell.h"
static NSString * const kStoreVisitTableCell = @"StoreVisitTableCell";

@interface WSStoreVisitCollectionCell ()

@property (nonatomic, strong) WSSelectListNewTableviewCell *cell;

@end

@implementation WSStoreVisitCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    WSSelectScrollListTableViewCell *cell = [[WSSelectScrollListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kStoreVisitTableCell withFuncStyle:WSSelectListNewTableViewCellStyleScrollList isStoreInfo:NO cellWidth:self.width];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:cell];
    cell.size = self.size;
    cell.isDistance = YES;
    self.cell = cell;
}

- (void)setStoreBean:(WSStoreBean *)storeBean index:(NSInteger)index count:(NSInteger)count {
//    NSString *pageIndexString = [NSString stringWithFormat:@"%ld/%ld", (long)index, (long)count];
//    [self.cell.rightLabel setText:pageIndexString];
    [self.cell setStore:storeBean];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if ([view isKindOfClass:[UIButton class]]) {
        return [super hitTest:point withEvent:event];
    }
    CGPoint hitPoint =  [self convertPoint:point toView:self.cell];
    if ([self.cell pointInside:hitPoint withEvent:event]) {
        return self;
    } else {
        return [super hitTest:point withEvent:event];
    }
}

@end
