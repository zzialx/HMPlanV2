//
//  WCPopListView.m
//  LeveyPopListViewDemo
//
//  Created by xiaotang.wang on 3/13/13.
//  Copyright (c) 2013 Levey. All rights reserved.
//

#import "WCPopListView.h"
// Import QuartzCore.h at the top of the file
#import <QuartzCore/QuartzCore.h>

@interface WCPopListView()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView *iTableView;
@property (nonatomic, strong)NSArray *iTotalArray;
@property (nonatomic, strong)NSMutableArray *iAlreadySelectedArray;
@property (nonatomic, strong)UIView *iContentView;
@property (nonatomic, strong)UIView *iFromView;
@property (nonatomic , strong) UIColor * textColor ;

@end

#define WCSPACE        2.0f

@interface WCPopListView()

@property (nonatomic, assign)WCPopListSelectedMode iMode;

@property (nonatomic, assign)WCPopListAnimationType animationType;

@end

@implementation WCPopListView

@synthesize iDelegate = _iDelegate;
@synthesize iTableView = _iTableView;
@synthesize iTotalArray = _iTotalArray;
@synthesize iAlreadySelectedArray = _iAlreadySelectedArray;
@synthesize iContentView = _iContentView;
@synthesize iFromView = _iFromView;
@synthesize iMode = _iMode;

#pragma mark - init and dealloc

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithTotalArry:(NSArray *)aTotalArray selectedArray:(NSArray *)aSelectedArray withSelectedMode:(WCPopListSelectedMode) aMode
{
    return [self initWithTotalArry:aTotalArray selectedArray:aSelectedArray withSelectedMode:aMode animationType:WCPopListAnimationTypeZoom maxHeight:WCPOPLISTHIGHT];
}

- (id)initWithTotalArry:(NSArray *)aTotalArray selectedArray:(NSArray *)aSelectedArray withSelectedMode:(WCPopListSelectedMode)aMode animationType:(WCPopListAnimationType)animationType maxHeight:(CGFloat)maxHeight
{
    if (aTotalArray == nil) {
        return nil;
    }
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    if (self = [super initWithFrame:rect]) {
        self.backgroundColor = [UIColor clearColor];
        CGFloat height = WCPOPLISTHIGHT;
        if (maxHeight > 0) {
            height = maxHeight;
        }
        if ([aTotalArray count] * WCROWHEIGHT < height) {
            height = [aTotalArray count] * WCROWHEIGHT;
        }
        
        CGRect tabRect = CGRectMake(45, 45, WCPOPLISTWIDTH, height);
        UIView *contentView = [[UIView alloc] initWithFrame:tabRect];
        self.iContentView = contentView;
        contentView.layer.cornerRadius = 5.0;
        contentView.layer.borderWidth = 1.0;
        UIColor *mainTintColor = MAIN_TINT_COLOT;
        if (!mainTintColor) {
            mainTintColor = [UIColor lightGrayColor];
        }
        contentView.layer.borderColor = mainTintColor.CGColor;
        contentView.backgroundColor = [UIColor whiteColor];
        contentView.autoresizesSubviews = YES;
        contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        contentView.clipsToBounds = YES;
        
        _iTotalArray = [aTotalArray copy];
        if ([aSelectedArray count] > 0) {
            _iAlreadySelectedArray = [[NSMutableArray alloc] initWithArray:aSelectedArray];
        }else{
            _iAlreadySelectedArray = [[NSMutableArray alloc] init];
        }
        
        _iTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStylePlain];
        _iTableView.backgroundColor = [UIColor whiteColor];
        _iTableView.dataSource = self;
        _iTableView.delegate = self;
        _iTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _iTableView.rowHeight = WCROWHEIGHT;
        [contentView addSubview:_iTableView];
        [self addSubview:_iContentView];
        [self setFrame:contentView.bounds];
    }
    self.iMode = aMode;
    self.animationType = animationType;
    
    return self;
}

- (void)setBackgroundImage:(UIImage *)image{
    CGRect rect = self.iContentView.frame;
    rect.size.height += 15;
    self.iTableView.frame = CGRectMake(7.5, 15, rect.size.width - 15, rect.size.height - 35);
  
    UIImageView * imageViwe = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height - 15)];
    imageViwe.image = image;
    [self.iContentView addSubview:imageViwe];
    [self.iContentView bringSubviewToFront:self.iTableView];
    self.iContentView.layer.borderWidth = 0;
    self.iTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [super layoutIfNeeded];
}

- (void)setITableViewTextColor:(UIColor *)color{
    self.textColor = color;
}


- (void)setPopListViewColor:(UIColor *)aColor
{
    _iContentView.backgroundColor = aColor;
}

- (void)setRowHeight:(CGFloat)height{
    _iTableView.rowHeight = height;

}

#pragma mark - Private Methods
- (void)showInAnimation
{
    switch (self.animationType) {
        case WCPopListAnimationTypeZoom:
            [self zoomFadeIn];
            break;
        case WCPopListAnimationTypeFromPoint:
            [self animationFromPointIn];
            break;
            
        default:
            break;
    }
}

- (void)showOutAnimation
{
    switch (self.animationType) {
        case WCPopListAnimationTypeZoom:
            [self zoomFadeOut];
            break;
        case WCPopListAnimationTypeFromPoint:
            [self animationFromPointOut];
            break;
            
        default:
            break;
    }
}

- (void)zoomFadeIn
{
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
    
}
- (void)zoomFadeOut
{
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)animationFromPointIn
{
    CGPoint originCenter = self.center;
    self.center = self.animationPoint;
    self.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.center = originCenter;
        self.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
}

- (void)animationFromPointOut
{
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 0;
        self.center = self.animationPoint;
        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - public function
- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    self.iContentView.center = CGPointMake(100, 100);
    [aView addSubview:self];
    if (animated) {
        [self showInAnimation];
    }
}

- (void)showSpecialInView:(UIView *)aView animated:(BOOL)animated
{
    self.iContentView.center = CGPointMake(200, 50);
    [aView addSubview:self];
    if (animated) {
        [self showInAnimation];
    }    
}

- (void)showViewFromRect:(CGRect) aRect inView:(UIView *)aView animated:(BOOL)animated
{
    self.frame = aView.bounds;
    self.iContentView.frame = aRect;
    self.iTableView.frame = self.iContentView.bounds;
    [aView addSubview:self];
    if (animated) {
        [self showInAnimation];
    }   
}

- (void)showViewFromView:(UIView *)aFromView inView:(UIView *)aView animated:(BOOL)animated
{
    self.iFromView = aFromView;
    CGRect fromRect = aFromView.frame;
    CGRect contvertRect1 = [aView convertRect:fromRect toView:aView];

    [aView addSubview:self];
    
    CGRect contvertRect = [aView convertRect:contvertRect1 toView:self];
    
    float popListViewCenterX = 0;
    float popListViewCenterY = 0;
    
    float inViewWidth = self.bounds.size.width;
    float inViewHight = self.bounds.size.height;
    
    float convertRectWidth = contvertRect.size.width;
    float convertRectHight = contvertRect.size.height;
    float convertOriginX = contvertRect.origin.x;
    float convertOriginY = contvertRect.origin.y;
    
    //Firtst count center Y 
    if (convertOriginY > inViewHight/2.0f ) {
        popListViewCenterY = convertOriginY - WCSPACE - WCPOPLISTHIGHT/2.0f;
    }else{
        popListViewCenterY = convertOriginY + convertRectHight + WCSPACE + WCPOPLISTHIGHT/2.0f;
    }
    
    if ( convertOriginX > inViewWidth/2.0f ) {
        popListViewCenterX = convertOriginX - WCSPACE - WCPOPLISTWIDTH/2.0f;
        if ((popListViewCenterX - inViewWidth/2.0f) < 0 ) {
            popListViewCenterX = popListViewCenterX - (popListViewCenterX - inViewWidth/2.0f) + WCSPACE;
        }
    }else{
        popListViewCenterX = convertOriginX + convertRectWidth + WCSPACE + WCPOPLISTWIDTH/2.0f;
        if ( (popListViewCenterX + WCPOPLISTWIDTH/2.0f) > inViewWidth ) {
            
            popListViewCenterX = popListViewCenterX - (popListViewCenterX + WCPOPLISTWIDTH/2.0f - inViewWidth) - WCSPACE;
        }
    }
    
    CGPoint center = CGPointMake(popListViewCenterX, popListViewCenterY);
    self.iContentView.center = center;
    if (animated) {
        [self showInAnimation];
    }
    
}

- (UIView *)getFromView
{
    return self.iFromView;
}

- (NSArray *)getSelectedArray
{
    return self.iAlreadySelectedArray;
}

// 获取文字需要的最大宽度
- (CGFloat)getMaxWidth {
    CGFloat width = WCPOPLISTWIDTH;
    for (NSString *title in self.iTotalArray) {
        CGSize titleSize = [title ws_sizeWithFont:WCPOPFONT constrainedToHeight:WCROWHEIGHT lineBreakMode:NSLineBreakByCharWrapping];
        if ((titleSize.width + MAIN_PADDING * 2) > width) {
            width = titleSize.width + MAIN_PADDING * 2;
        }
        if (width >= WCPOPLISTMAXWIDTH) {
            width = WCPOPLISTMAXWIDTH;
            break;
        }
    }
    return width;
}

#pragma mark - table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.iTotalArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentify = @"multiselect";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentify];
    }
    
    for (NSString *item in self.iAlreadySelectedArray) {
        NSString *str = [self.iTotalArray objectAtIndex:indexPath.row];
        if ([str isEqualToString:item]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            if (self.iMode == WCPopListSigleSelected) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    
    cell.textLabel.font = WCPOPFONT;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.textLabel.text = [self.iTotalArray objectAtIndex:indexPath.row];
    if (self.textColor) {
        cell.textLabel.textColor = self.textColor;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = nil;
    
    cell.accessoryType = (cell.accessoryType == UITableViewCellAccessoryNone) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    BOOL bFind = NO;
    NSString *findItem = nil;
    for (NSString *item in self.iAlreadySelectedArray) {
        if ([item isEqualToString:cell.textLabel.text]) {
            bFind = YES;
            findItem = item;
            break;
        }
    }
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark ) {
        if (!bFind) {
            if (self.iMode == WCPopListSigleSelected) {
                [self.iAlreadySelectedArray removeAllObjects];
            }
            [self.iAlreadySelectedArray addObject:cell.textLabel.text];
        }
    }else{
        if (bFind && findItem != nil) {
            if (self.iMode == WCPopListSigleSelected) {
                // Don remove
            }else{
                [self.iAlreadySelectedArray removeObject:findItem];
            }
        }
    }
    
    if (self.iDelegate && [self.iDelegate respondsToSelector:@selector(popListView:didSelectedIndex:)])
    {
        [self.iDelegate popListView:self didSelectedIndex:indexPath.row];
    }
    
    if (self.autoHideWhenSelect) {
        [self removeFromSuperview];
    }else {
        [tableView reloadData];
    }
    
}


#pragma mark - TouchTouchTouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // tell the delegate the cancellation
    if (self.iDelegate && [self.iDelegate respondsToSelector:@selector(popListViewDidSelectedEnd:)]) {
        [self.iDelegate popListViewDidSelectedEnd:self];
    }
    
    // dismiss self
    [self showOutAnimation];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
