//
//  FUISingleSelectionListView.m
//  WinSFA
//
//  Created by dujinfeng481 on 14-7-28.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "FUISingleSelectionListView.h"

@implementation FUISingleSelectionSource

-(id) initWithName:(NSString*)pName withId:(NSString*)pId
{
    self = [super init];
    if (self) {
        self.sName = pName;
        self.sId = pId;
    }
    return self;
}

@end

@interface FUISingleSelectionListView() <UITableViewDataSource, UITableViewDelegate> {
    FSelectedBlock      fSelectBlock;
}

@property (nonatomic, strong) NSString      *keyStr;            //上传数据使用的key值（other中为col对应的值“memo1“等）
@property (nonatomic, strong) UIButton      *titleButton;       //标题
@property (nonatomic, strong) UITableView   *listTableView;     //下拉选项
@property (nonatomic, strong) NSArray       *listSourceArray;   //数据源 (FUISingleSelectionSource object)
@property (nonatomic, assign) NSInteger     selectedIndex;      //选中项

@end

@implementation FUISingleSelectionListView

- (id)initWithFrame:(CGRect)frame
         withKeyStr:(NSString*)sKey
withListSourceArray:(NSArray*)sourceArray
    withSelectedStr:(NSString*)selectedStr
          withBlock:(FSelectedBlock)block
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.keyStr = sKey;
        
        if (sourceArray && [sourceArray count] > 0) {
            fSelectBlock = block;
            _listSourceArray = sourceArray;
            
            //设置默认选中项
            if (selectedStr && [selectedStr length] > 0) {
                NSInteger iTemp = [self indexOfSignleSelectionSourceWithName:selectedStr];
                if ( NSNotFound == iTemp) {
                    _selectedIndex = -1;
                }else {
                    _selectedIndex = iTemp;
                }
            }else {
                _selectedIndex = -1;
            }
            
            //创建标题
            _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_titleButton setFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
            [_titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_titleButton setBackgroundColor:[UIColor clearColor]];
            [_titleButton.titleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
            [_titleButton setImageEdgeInsets:UIEdgeInsetsMake(0, CGRectGetWidth(frame) - 20, 0, 0)];
            [_titleButton setImage:[UIImage imageNamed:@"chevron.png"] forState:UIControlStateNormal];
            [_titleButton setImage:[UIImage imageNamed:@"chevron-active.png"] forState:UIControlStateHighlighted];
            [_titleButton setBackgroundImage:[[UIImage imageForName:@"inputBg.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:2] forState:UIControlStateNormal];
            [_titleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//            [_titleButton.layer setMasksToBounds:YES];
//            [_titleButton.layer setCornerRadius:10.0];      //设置矩形四个圆角半径
            _titleButton.adjustsImageWhenHighlighted = NO;
            _titleButton.adjustsImageWhenDisabled = NO;
            [_titleButton addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            if (_selectedIndex >= 0 && _selectedIndex < [sourceArray count]) {
                FUISingleSelectionSource *selectObj = [sourceArray objectAtIndex:_selectedIndex];
                [_titleButton setTitle:[selectObj sName] forState:UIControlStateNormal];
            }
            [self addSubview:_titleButton];
        }
    }
    
    return self;
}

#pragma mark - private method
- (NSInteger) indexOfSignleSelectionSourceWithName:(NSString*) pName
{
    NSInteger index = NSNotFound;
    NSInteger totalCount = [self.listSourceArray count];
    for (NSInteger i = 0 ; i < totalCount; ++i) {
        if ([[self.listSourceArray objectAtIndex:i] isKindOfClass:[FUISingleSelectionSource class]]) {
            FUISingleSelectionSource *tmp = [self.listSourceArray objectAtIndex:i];
            if (tmp && tmp.sName) {
                if ([tmp.sName isEqualToString:pName] || [tmp.sId isEqualToString:pName]) {
                    index = i;
                    break;
                }
            }
        }
    }
    
    return index;
}

- (void) btnAction:(UIButton*)send
{
    if (!self.listTableView) {
        //创建下拉列表
        self.listTableView = [[UITableView alloc] init];
        [self.listTableView setDelegate:self];
        [self.listTableView setDataSource:self];
        [self.listTableView setBackgroundColor:[UIColor whiteColor]];
        [self.listTableView.layer setMasksToBounds:YES];
        [self.listTableView.layer setCornerRadius:3];
        CGPoint point = CGPointMake(0, CGRectGetHeight(self.frame));
        CGPoint newPoint = [self convertPoint:point toView:[self superview]];
        [self.listTableView setFrame:CGRectMake(newPoint.x, newPoint.y+1, CGRectGetWidth(self.frame), 0)];
        
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.listTableView.bounds];
        [bgImgView setImage:[[UIImage imageForName:@"inputBg.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:2]];
        [self.listTableView setBackgroundView:bgImgView];
        [[self superview] addSubview:self.listTableView];
        
        if (self.selectedIndex) {
            [self.listTableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0]
                                            animated:NO
                                      scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    CGRect rect = self.listTableView.frame;
    if (CGRectGetHeight(rect) == 0) {
        rect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetWidth(rect), 44 * 3 - 20);
    }else {
        rect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetWidth(rect), 0);
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.listTableView setFrame:rect];
                     } completion:^(BOOL finished) {
                         
                     }];
}

//- (void)fold
//{
//    [UIView animateWithDuration:0.3f animations:^{
//        self.accessoryView.layer.transform = CATransform3DMakeRotation(0, 0, 0, 1.0f);
//    }];
//    
//    self.bFold = YES;
//}
//
//- (void)unfold
//{
//    [UIView animateWithDuration:0.3f animations:^{
//        self.accessoryView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1.0f);
//    }];
//    
//    self.bFold = NO;
//}

#pragma mark - UITableViewDataSource method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listSourceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellSS";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        UIView *selectBgView = [[UIView alloc] initWithFrame:CGRectZero];
        [selectBgView setBackgroundColor:[UIColor colorWithHexString:@"#cccccc"]];
        [cell setSelectedBackgroundView:selectBgView];
    }
    
    FUISingleSelectionSource *itemSource = [self.listSourceArray objectAtIndex:indexPath.row];
    cell.textLabel.text = itemSource.sName;

    return cell;
}

#pragma mark - UITableViewDelegate method
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FUISingleSelectionSource *itemSource = [self.listSourceArray objectAtIndex:indexPath.row];
    [self.titleButton setTitle:itemSource.sName forState:UIControlStateNormal];
    [self btnAction:nil];
    self.selectedIndex = indexPath.row;
    
    if (fSelectBlock) {
        fSelectBlock(self.keyStr, self.selectedIndex, itemSource);
    }
}

@end
