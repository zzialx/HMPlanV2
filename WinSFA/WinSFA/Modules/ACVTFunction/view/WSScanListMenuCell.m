//
//  WSScanListMenuCell.m
//  WinSFA
//
//  Created by winchannel on 15/10/20.
//  Copyright © 2015年 WinChannel. All rights reserved.


#import "WSScanListMenuCell.h"
#import "NSString+Additions.h"

@implementation WSScanListMenuCell
@synthesize cellView;
@synthesize startX;
@synthesize cellX;
@synthesize delegate;
@synthesize indexPathNum;
@synthesize menuCout;
@synthesize menuView;
@synthesize menuViewHidden;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andCellWidth:(CGFloat)width{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        menuCout = 0;
        
        self.cellView = [[UIView alloc] init];
        self.width = width;
        self.cellView.frame = CGRectMake(0, 0, width, self.frame.size.height);
        self.cellView.backgroundColor =[UIColor clearColor];
        [self.contentView addSubview:self.cellView];
        
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cellPanGes:)];
        panGes.delegate = self;
        panGes.delaysTouchesBegan = YES;
        panGes.cancelsTouchesInView = NO;
        [self addGestureRecognizer:panGes];
        
    }
    return  self;
    
}


- (void)configWithData:(NSIndexPath *)indexPath mainTitle:(NSString *)mainTitle menuData:(NSArray *)menuData {
 
    CGFloat height =[WSScanListMenuCell heightWithMainTitle:mainTitle withSubTitle:nil withCellFrame:self.frame];
    CGRect rect = CGRectMake(0, 0, self.width, height);
    
    indexPathNum = indexPath;
    menuCout = [menuData count];
    if (self.cellView) {
        [self.cellView removeFromSuperview];
        self.cellView = nil;
    }
    self.cellView = [[UIView alloc] init];
    self.cellView.backgroundColor = [UIColor whiteColor];
    self.cellView.frame = rect;
    [self.contentView addSubview:self.cellView];
    

    
    self.mainTitle =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, height)];
    self.mainTitle.numberOfLines = 0;
    self.mainTitle.textAlignment = NSTextAlignmentLeft;
    self.mainTitle.font = [UIFont systemFontOfSize:16];
    self.mainTitle.backgroundColor = [UIColor clearColor];
    self.mainTitle.textColor = [UIColor blackColor];
    [self.cellView addSubview:self.mainTitle];
    
    
    if ([self.isPhotoRequire isEqualToString:@"PHOTO_R"]) {
        _addPhotoBtn = [[UIButton alloc] initWithFrame:CGRectMake(rect.size.width - 51, (rect.size.height- 27)/2.0, 31, 27)];
        [_addPhotoBtn setBackgroundImage:[UIImage imageNamed:@"icon_table_camera.png"] forState:UIControlStateNormal];
        [_addPhotoBtn addTarget:self action:@selector(addPhotos:) forControlEvents:UIControlEventTouchUpInside];
        [self.cellView addSubview:_addPhotoBtn];
        
        self.eventCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( kEventLabelWidth, - 8, kEventLabelWidth, kEventLabelWidth)];
        [self.eventCountLabel setBackgroundColor:[UIColor redColor]];
        [self.eventCountLabel setTextColor:[UIColor whiteColor]];
        [self.eventCountLabel setFont:[UIFont systemFontOfSize:12]];
        [self.eventCountLabel setTextAlignment:NSTextAlignmentCenter];
        [self.addPhotoBtn addSubview:self.eventCountLabel];
        self.eventCountLabel.layer.cornerRadius = kEventLabelWidth / 2.0;
        self.eventCountLabel.clipsToBounds = YES;
        
        [self setEventIdentifer:self.photosCout];
    }

    //设置编辑菜单视图
    menuView = [[WSMenuPanel alloc] initWithFrame:CGRectMake(rect.size.width - 80 * menuCout, 0, 80*menuCout, rect.size.height)];
    menuView.delegate = self;
    [self.contentView insertSubview:menuView belowSubview:self.cellView];
    
    self.menuViewHidden = YES;
    
    [self.mainTitle setText:nil];
    [self.menuView removeAllSubviews];
    
    [self.mainTitle setText:mainTitle];
    
    [self.menuView addMenuPanelData:menuData];

}

- (void)setEventIdentifer:(NSString *)identifer
{
    if (identifer) {
        self.eventCountLabel.hidden = NO;
    }
    else
    {
        self.eventCountLabel.hidden = YES;
    }
    [self.eventCountLabel setText:identifer];
}

- (void)addPhotos:(id)sender{
    
    [self.delegate addPhotosCell:self withIndex:self.indexPathNum];
}

-(void)cellPanGes:(UIPanGestureRecognizer *)panGes{
    if (self.selected) {
        [self setSelected:NO animated:NO];
    }
    
    CGPoint pointer = [panGes locationInView:self.contentView];
    
    if (panGes.state == UIGestureRecognizerStateBegan) {
        
        self.menuViewHidden = NO;
        startX = pointer.x;
        cellX = self.cellView.frame.origin.x;
        
    }else if (panGes.state == UIGestureRecognizerStateChanged){
        
        self.menuViewHidden = NO;
        [delegate tableMenuWillShowInCell:self];
        
    }else if (panGes.state == UIGestureRecognizerStateEnded){
        
        [self cellReset:pointer.x - startX];
        return;
        
    }else if (panGes.state == UIGestureRecognizerStateCancelled){
        
        [self cellReset:pointer.x - startX];
        return;
    }
    
    [self cellViewMoveToX:cellX + pointer.x - startX];
}

-(void)cellReset:(float)moveX{
    

    if (cellX <= -80*menuCout) {// 在向右滑动收回menu时，
        if (moveX <= 0) {
            return;
        }else if(moveX > 20){//满足条件，收回menu菜单
            [self hiddenMenuView];
        }else if (moveX <= 20){//不满足条件，menu依然打开
            [self showMenuVeiw];
        }
    }else{// 在向左滑动时，

        if (moveX >= 0) {
            return;
        }else if(moveX < -20){
            [self showMenuVeiw];
            
        }else if (moveX >= -20){
            [self hiddenMenuView];
        }
    }
}

-(void)cellViewMoveToX:(float)x{
    

    if (x <= -(menuCout*80+20)) {
        x = -(menuCout*80+20);
    }else if (x >= 50){
        x = 50;
    }
    
    if (x == -(menuCout*80+20)) {
        [self showMenuVeiw];
    }
    if (x == 50) {
        [self hiddenMenuView];
        
    }
}

- (void)hiddenMenuView{
    [UIView animateWithDuration:0.2 animations:^{
        [self initCellFrame:0];
    } completion:^(BOOL finished) {
        self.menuViewHidden = YES;
        [self.delegate tableMenuDidHideInCell:self];
    }];
}

- (void)showMenuVeiw{
    
    [UIView animateWithDuration:0.2 animations:^{
        [self initCellFrame:-menuCout*80];
    } completion:^(BOOL finished) {
        self.menuViewHidden = NO;
        [self.delegate tableMenuDidShowInCell:self];
    }];
    
}

- (void)initCellFrame:(float)x{
    CGRect frame = self.cellView.frame;
    frame.origin.x = x;
    
    self.cellView.frame = frame;
}

#pragma mark * UIPanGestureRecognizer delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
        return fabs(translation.x) > fabs(translation.y);
    }
    return YES;
}

#pragma mark WSMenuCellDelegate
- (void)ChooseMenuIndex:(NSInteger)menuIdexNum{
    
    self.menuViewHidden = YES;
    
    [delegate deleteCell:self];
    
}

//隐藏Menu
- (void)setMenuHidden:(BOOL)hidden animated:(BOOL)animated completionHandler:(void (^)(void))completionHandler{
    if (self.selected) {
        [self setSelected:NO animated:NO];
    }
    if (hidden) {
        CGRect frame = self.cellView.frame;
        if (frame.origin.x != 0) {
            [UIView animateWithDuration:0.2 animations:^{
                [self initCellFrame:0];
            } completion:^(BOOL finished) {
                
                self.menuViewHidden = YES;
                
                [self.delegate tableMenuDidHideInCell:self];
                
                if (completionHandler) {
                    completionHandler();
                }
            }];
        }
    }
}

- (void)setMenuViewHidden:(BOOL)Hidden{
    menuViewHidden = Hidden;
    
    if (Hidden) {
        self.menuView.hidden = YES;
    }else{
        self.menuView.hidden = NO;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    if (self.menuViewHidden) {
        self.menuView.hidden = YES;
        [super setHighlighted:highlighted animated:animated];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.menuViewHidden) {
        self.menuView.hidden = YES;
        [super setSelected:selected animated:animated];
    }
}

//得到扫描后字符串的文字高度
+ (CGFloat)heightWithMainTitle:(NSString *)mainTitle withSubTitle:(NSString *)subTitle withCellFrame:(CGRect)aFrame{
    
    CGSize size = [mainTitle ws_sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToWidth:aFrame.size.width];
    
    if (size.height < MAIN_CELL_HEIGHT) {
        return MAIN_CELL_HEIGHT;
    }
    return size.height + MAIN_PADDING * 2;

    
}
@end
