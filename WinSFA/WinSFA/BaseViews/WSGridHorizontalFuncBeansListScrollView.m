//
//  WSGridHorizontalFuncBeansListScrollView.m
//  WinSFA
//
//  Created by HZH on 2017/12/1.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSGridHorizontalFuncBeansListScrollView.h"
#import "WSWorkbenchCollectionViewCell.h"

#define kWorkbenchItemHeight 74

@interface WSGridHorizontalFuncBeansListScrollView ()
{
    WSFuncsBean *_pFuncsBean;
    NSInteger _pageCnt;
    NSInteger _lastRowColCnt;
    NSInteger _maxRow;
    NSInteger _maxCol;
}
@end

@implementation WSGridHorizontalFuncBeansListScrollView

- (id)initWithFrame:(CGRect)frame andParentFuncsBean:(WSFuncsBean *)pFuncsBean
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _pFuncsBean = pFuncsBean;
        _maxRow = _pFuncsBean.maxRow > 0 ? _pFuncsBean.maxRow : 1;
        _maxCol = _pFuncsBean.colNum > 0 ? _pFuncsBean.colNum : 3;
        
        [self setupAllSubviews];
        
        return self;
    }
    
    return nil;
}

- (void)setupAllSubviews
{
    [self resetScrollViewContentSize];
    
    for (int i = 0; i < [[_pFuncsBean funcsArray] count]; i ++) {
        WSWorkbenchCollectionViewCell *cell = [[WSWorkbenchCollectionViewCell alloc] initWithFrame:[self getItemFrameWithFuncsBeanIndex:i]];
        
        WSFuncsBean *funcBean = [[_pFuncsBean funcsArray] objectAtIndex:i];
        
        [cell setDataWithFuncsBean:funcBean visitActionStatus:nil badgeCount:nil];
        
        UITapGestureRecognizer *oneTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellClickedAction:)];
        
        [cell addGestureRecognizer:oneTapGR];
        
        [self addSubview:cell];
    }
}

- (CGRect)getItemFrameWithFuncsBeanIndex:(NSInteger)funcsBeanIndex
{
    CGRect finalFrame = CGRectMake(0, 0, 0, 0);
    CGFloat itemWidth = (self.frame.size.width - 30.0)/_maxCol;
    
    NSInteger pIndex = funcsBeanIndex / (_maxCol * _maxRow);
    NSInteger rIndex = funcsBeanIndex / _maxCol % _maxRow;
    NSInteger cIndex = funcsBeanIndex % _maxCol;
    
    finalFrame = CGRectMake(pIndex*self.frame.size.width + cIndex*itemWidth, rIndex*kWorkbenchItemHeight, itemWidth, kWorkbenchItemHeight);
    
    return finalFrame;
}

- (void)resetScrollViewContentSize
{
    _pageCnt = 1;
    _lastRowColCnt = _pFuncsBean.funcsArray.count % (_maxRow * _maxCol);
    if (_lastRowColCnt == 0) {
        _pageCnt = _pFuncsBean.funcsArray.count/(_maxRow * _maxCol);
        _lastRowColCnt = _maxCol;
    }else
        _pageCnt = _pFuncsBean.funcsArray.count/(_maxRow * _maxCol) + 1;
    
    [self setContentSize:CGSizeMake(self.frame.size.width * _pageCnt, self.frame.size.height)];
    
}

- (void)cellClickedAction:(id)sender
{
    UITapGestureRecognizer *tapGR = (UITapGestureRecognizer *)sender;
    WSWorkbenchCollectionViewCell *cell = (WSWorkbenchCollectionViewCell *)tapGR.view;
    
    if ([self.fDelegate respondsToSelector:@selector(doActionAfterCellClickedWithFuncsBean:)]) {
        [self.fDelegate doActionAfterCellClickedWithFuncsBean:cell.funcsBean];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
