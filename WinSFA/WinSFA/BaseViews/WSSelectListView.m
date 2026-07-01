//
//  SelectListControl.m
//  SelectList
//
//  Created by Jiepeng Zheng on 12-8-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSSelectListView.h"
#import "QuartzCore/QuartzCore.h"

#define defaultString           NSLocalizedString(@"please_select", nil)

#define DEFAULT_SELECTED -1

@interface WSSelectListView ()

@property (nonatomic, strong) UITableView *titleTable;
@property (nonatomic, strong) UITableView *sourceTable;

@property (nonatomic, strong) UIView *backView;
//sourceTable初始化时的坐标系
@property (nonatomic, assign) CGRect sourceTableOriginRect;

@property (nonatomic,assign) CGFloat sourceTableMoveHeight;


@end

@implementation WSSelectListView

//@synthesize title = _title;
//@synthesize titleTable = _titleTable;
@synthesize content = _content;
@synthesize sourceTable = _sourceTable;
@synthesize selectedIndex = _selectedIndex;
@synthesize backView = _backView;
@synthesize title = _title;
@synthesize selectListDelegate = _selectListDelegate;
@synthesize sourceTableReadOnly = _sourceTableReadOnly;
@synthesize m_nRow = _m_nRow;
@synthesize m_nColumn = _m_nColumn;

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame selectMode:WSSelectListViewSelectModeSingleSelection];
    return self;
}

- (id)initWithFrame:(CGRect)frame selectMode:(WSSelectListViewSelectMode)selectMode
{
    self = [self initWithFrame:frame style:UITableViewStyleGrouped selectMode:selectMode];
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [self initWithFrame:frame style:UITableViewStyleGrouped selectMode:WSSelectListViewSelectModeSingleSelection];
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style selectMode:(WSSelectListViewSelectMode)selectMode
{
    self = [super initWithFrame:frame style:UITableViewStyleGrouped];
    if (self)
    {
        self.delegate = self;
        self.dataSource = self;
        self.sectionHeaderHeight = 0;
        self.backgroundColor = [UIColor clearColor];
        self.scrollEnabled = NO;
        self.backgroundView = nil;
        self.content = [[NSMutableArray alloc] init];
        self.contentDicts = [[NSMutableArray alloc]init];
        self.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height/8)];
        self.selectMode = selectMode;
        
        if (self.selectMode == WSSelectListViewSelectModeMultipleChoice) {
            self.selectedIndexArray = [[NSMutableArray alloc] init];
        }
    }
    return self;
}


- (BOOL)isIndexSelected:(NSInteger)index
{
    BOOL seleted = NO;
    for (NSNumber *number in self.selectedIndexArray) {
        if (number.integerValue == index) {
            seleted = YES;
            break;
        }
    }
    
    return seleted;
}

- (void)addSelectionForIndex:(NSInteger)index
{
    if ([self isIndexSelected:index]) {
        return;
    }
    
    [self.selectedIndexArray addObject:[NSNumber numberWithInteger:index]];
}

- (void)removeSelectionForIndex:(NSInteger)index
{
    if (![self isIndexSelected:index]) {
        return;
    }
    
    for (int i = 0; i < [self.selectedIndexArray count]; i++) {
        NSNumber *number = [self.selectedIndexArray objectAtIndex:i];
        if (number.integerValue == index) {
            [self.selectedIndexArray removeObjectAtIndex:i];
            break;
        }
    }
}

- (NSString *)currentSelectedContent {
    return [self.content objectAtIndex:self.selectedIndex];
}

- (NSString *)getSelectedContentString
{
    NSMutableArray *contentArray = [NSMutableArray array];
    NSString *result = nil;
    if (!self.selectedIndexArray || [self.selectedIndexArray count] <= 1) {
        NSNumber *number = [self.selectedIndexArray firstObject];
        if (!number || [number integerValue] == DEFAULT_SELECTED) {
            result = [self getDefaultString];
        }
    }
    
    if (!result) {
        for (NSNumber *number in self.selectedIndexArray) {
            if (number.integerValue > DEFAULT_SELECTED && number.integerValue < [self.content count]) {
                [contentArray addObject:[self.content objectAtIndex:number.integerValue]];
            }
        }
        result = [contentArray componentsJoinedByString:@","];
    }

    
    return result;
}

- (void)touch
{
    [self moveSourceTableDown];
    [_sourceTable removeFromSuperview];
    [_backView removeFromSuperview];
    self.hidden = NO;
}

- (void)closeSelectList {
    
    if(!self.isShow)
    {
        return ;
    }
    self.isShow = NO;
    [self.backView removeFromSuperview];
    [self.sourceTable removeFromSuperview];
}

// 如果下拉框内容被遮挡 上移后 下拉框在消失 父视图回到的正常frame的方法
- (void)moveSourceTableDown {
    if ((_sourceTable.frame.origin.y + self.sourceTable.size.height + self.sourceTableMoveHeight) > [self superview].height) {
        [UIView animateWithDuration:0.2 animations:^{
            
            UIView *superView = [self superview];
            [superView setFrame:CGRectMake(superView.frame.origin.x, superView.frame.origin.y + self.sourceTableMoveHeight, superView.frame.size.width, superView.frame.size.height)];
            
            [_sourceTable setFrame:CGRectMake(_sourceTable.frame.origin.x, _sourceTable.frame.origin
                                              .y + self.sourceTableMoveHeight, _sourceTable.frame.size.width, _sourceTable.frame.size.height)];
        } completion:nil];
    }
}


- (void)setCell:(UITableViewCell *)cell selected:(BOOL)isSelected {
    if (isSelected) {
    
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.80f green:0.90f blue:0.96f alpha:1.00f];
    }
    else{
        cell.contentView.backgroundColor =[UIColor clearColor];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.frame.size.height/4*3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self)
        return 1;
    return [_content count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"tb";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];

        
        
        UIFont *font = [UIFont systemFontOfSize:14];
        
        cell.textLabel.font = font;
        cell.detailTextLabel.font = font;
        UIColor *textColor =[UIColor grayColor]; //[UIColor colorWithHexString:@"#b5b5b5"]
        
        cell.textLabel.textColor = textColor;
        cell.detailTextLabel.textColor = textColor;
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    

    if (tableView == self)
    {

//        UIColor *mainTintColor = MAIN_TINT_COLOT;
//        if (!mainTintColor) {
//            mainTintColor = [UIColor colorWithHexString:@"#00b4ff"];
//        }
//        cell.backgroundColor = mainTintColor;
        
        cell.backgroundColor = [UIColor colorWithRed:0.96f green:0.98f blue:0.98f alpha:1.00f];
        cell.layer.cornerRadius=self.frame.size.height/3;
        
        cell.layer.borderColor =[[UIColor colorWithRed:0.42f green:0.69f blue:0.86f alpha:1.00f] CGColor];
        cell.layer.borderWidth = 1;
        cell.layer.masksToBounds=YES;
        
        UIButton *accessoryView = [UIButton buttonWithType:UIButtonTypeCustom];
        accessoryView.frame = CGRectMake(0, 0, 12, 6);
        accessoryView.userInteractionEnabled = NO;
        [accessoryView setImage:[UIImage imageNamed:@"triangle_down.png"] forState:UIControlStateNormal];
        cell.accessoryView = accessoryView;
        
        NSString *selectedContent = nil;
        if (_selectMode == WSSelectListViewSelectModeSingleSelection) {
            if(_selectedIndex>DEFAULT_SELECTED && _content.count > _selectedIndex){
                selectedContent = [_content objectAtIndex:_selectedIndex];
            }else{
                selectedContent = [self getDefaultString];
            }
        }
        else if (_selectMode == WSSelectListViewSelectModeMultipleChoice)
        {
            selectedContent = [self getSelectedContentString];
        }
        
        cell.textLabel.text = selectedContent;
        
        if (self.title && [selectedContent isEqualToString:[self getDefaultString]]) {
            cell.detailTextLabel.text = self.title;
        }
        
        return cell;
    }
    
    cell.accessoryView = nil;
    cell.backgroundColor=[UIColor clearColor];
    
    if ([indexPath row] == 0)
    {
        cell.textLabel.text = defaultString;
        cell.detailTextLabel.text = self.title;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UIButton *accessoryView = [UIButton buttonWithType:UIButtonTypeCustom];
        accessoryView.frame = CGRectMake(0, 0, 12, 6);
        UIImage *image = [UIImage imageNamed:@"triangle_down.png"];
        [accessoryView setImage:image forState:UIControlStateNormal];
        accessoryView.userInteractionEnabled = NO;
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
        [accessoryView setTransform:transform];
        
        cell.accessoryView = accessoryView;
    }
    else
    {
        cell.textLabel.text = [_content objectAtIndex:[indexPath row] - 1];
        cell.detailTextLabel.text = @"";
    }
    
    cell.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    BOOL isSelected = NO;

    if (_selectedIndex != DEFAULT_SELECTED) {
        if (self.selectMode == WSSelectListViewSelectModeSingleSelection) {
            if (_selectedIndex == indexPath.row - 1) {
                isSelected = YES;
            }
        }else if (self.selectMode == WSSelectListViewSelectModeMultipleChoice) {
            if ([self isIndexSelected:indexPath.row-1]) {
                isSelected = YES;
            }
        }
    }
    
    
    [self setCell:cell selected:isSelected];

    return cell;
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor=[UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self)
    {
        
        if (self.selectType == WSSelectLIstViewTypePopShow) {
            if([self.selectListDelegate respondsToSelector:@selector(popupSelectListViewDidAppear:)]){
                [self.selectListDelegate popupSelectListViewDidAppear:self];
            }
            return;
        }
        tableView.hidden = YES;

        UIWindow *wc = [[[UIApplication sharedApplication] windows] firstObject];
        UIViewController *rootViewController = wc.rootViewController;
        if (rootViewController.presentedViewController) {
            rootViewController = rootViewController.presentedViewController;
        }
        if (rootViewController.presentedViewController) {
            rootViewController = rootViewController.presentedViewController;
        }
        UIView* rootView = rootViewController.view;
        
        [self touch];
        
        BOOL isFirstLoad = NO;
        
        if (self.sourceTable == nil)
        {

            self.sourceTable = [[UITableView alloc] initWithFrame:CGRectMake(self.frame.origin.x ,self.frame.origin.y+self.tableHeaderView.frame.size.height, self.frame.size.width, (_content.count+1)*self.frame.size.height/4*3) style:UITableViewStylePlain];

           
//            UIColor *mainTintColor = MAIN_TINT_COLOT;
//            if (!mainTintColor) {
//                mainTintColor = [UIColor colorWithHexString:@"#00b4ff"];
//            }
//            _sourceTable.backgroundColor = mainTintColor;
            
             _sourceTable.backgroundColor = [UIColor colorWithRed:0.96f green:0.98f blue:0.98f alpha:1.00f];
            _sourceTable.layer.borderColor =[[UIColor colorWithRed:0.42f green:0.69f blue:0.86f alpha:1.00f] CGColor];
            _sourceTable.layer.borderWidth = 1;
            _sourceTable.layer.cornerRadius = self.frame.size.height/3;
            _sourceTable.layer.masksToBounds = YES;
            _sourceTable.delegate = self;
            _sourceTable.dataSource = self;
            _sourceTable.bounces=NO;
            _sourceTable.separatorStyle=UITableViewCellSeparatorStyleNone;
            self.sourceTableOriginRect = _sourceTable.frame;
            
            isFirstLoad = YES;
        }
        
        
        if (self.sourceTableReadOnly) {
            _sourceTable.userInteractionEnabled = NO;
        }else {
            _sourceTable.userInteractionEnabled = YES;
        }
        
        CGRect rect = self.sourceTableOriginRect;
        CGPoint point = rect.origin;
        point = [[self superview] convertPoint:point toView:rootView];
        rect.origin = point;
        
        CGFloat cellheight = self.frame.size.height/4*3;
        
        rect.size.height = (_content.count+1) * cellheight;
        
        CGFloat topSpaceHeight = rect.origin.y - 64 - 5 + cellheight;
        CGFloat downSpaceHeight = rootView.height - rect.origin.y - 5;
        
        if (downSpaceHeight < rect.size.height) {
            
            if (topSpaceHeight >= rect.size.height) {
                rect.origin.y -= rect.size.height - cellheight;
            }else {
                if (downSpaceHeight > topSpaceHeight){
                    rect.size.height = downSpaceHeight;
                }else {
                    rect.size.height = topSpaceHeight;
                    rect.origin.y -= rect.size.height - cellheight;
                }
            }
        }
        
        _sourceTable.frame = rect;

        _sourceTable.tag=9876;

        if (_backView == nil)
        {
            _backView = [[UIView alloc] initWithFrame:rootView.bounds];
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch)];
            [tapRecognizer setNumberOfTapsRequired:1];
            [tapRecognizer setNumberOfTouchesRequired:1];
            [_backView addGestureRecognizer:tapRecognizer];
        }
        _backView.tag=9875;

        [rootView addSubview:_backView];
        [rootView addSubview:_sourceTable];
        [rootView bringSubviewToFront:_sourceTable];
        
        if (!isFirstLoad) {
            [_sourceTable reloadData];
        }
        
        self.isShow = YES;
        if (self.selectListDelegate && [self.selectListDelegate respondsToSelector:@selector(selectListViewDidAppear:)])
        {
            [self.selectListDelegate performSelector:@selector(selectListViewDidAppear:) withObject:self];
        }
        _sourceTable.contentOffset = CGPointMake(0, 0);
    }else{

        if (_selectMode == WSSelectListViewSelectModeSingleSelection) {
            self.isShow = NO;
            self.hidden = NO;
            [self.backView removeFromSuperview];
            [self.sourceTable removeFromSuperview];
            if ([indexPath row] == 0)
            {
                return;
            }
            if (_selectedIndex != [indexPath row] - 1)
            {
                _selectedIndex = [indexPath row] - 1;
                _isValueChange = YES;
                [self startObservingEntity];

                [self reloadData];
                if (self.selectListDelegate && [self.selectListDelegate respondsToSelector:@selector(selectListChange:)])
                {
                    [self.selectListDelegate performSelector:@selector(selectListChange:) withObject:self];
                }
            }
        }
        else if (_selectMode == WSSelectListViewSelectModeMultipleChoice)
        {
            if ([indexPath row] == 0)
            {
                [self moveSourceTableDown];
                self.hidden = NO;
                [self.backView removeFromSuperview];
                [self.sourceTable removeFromSuperview];
                return;
            }
            if (![self isIndexSelected:[indexPath row] - 1])
            {
                [self addSelectionForIndex:[indexPath row] - 1];
            }
            else
            {
                [self removeSelectionForIndex:[indexPath row] - 1];
            }
            
            _isValueChange = YES;
            [self startObservingEntity];
            [self.sourceTable reloadData];
            [self reloadData];
            if (self.selectListDelegate && [self.selectListDelegate respondsToSelector:@selector(selectListChange:)])
            {
                [self.selectListDelegate performSelector:@selector(selectListChange:) withObject:self];
            }
        }
        
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [self reloadData];
    if (self.selectListDelegate && [self.selectListDelegate respondsToSelector:@selector(selectListChange:)])
    {
        [self.selectListDelegate performSelector:@selector(selectListChange:) withObject:self];
    }
}


- (void)setSelectedIndexArray:(NSMutableArray *)selectedIndexArray{
    _selectedIndexArray = selectedIndexArray;
    [self reloadData];
    if (self.selectListDelegate && [self.selectListDelegate respondsToSelector:@selector(selectListChange:)])
    {
        [self.selectListDelegate performSelector:@selector(selectListChange:) withObject:self];
    }
}

- (NSString *)getDefaultString
{
    return defaultString;
}
#pragma mark - WSValidateData

- (void)dealloc{

    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)setNotificationPrefix:(NSString *)aNotificationPrefix
                       andRow:(unsigned int)aRow
                    andColumn:(unsigned int)aColumn
                  andDataType:(WSValidateDataDependType)aDataType
{
    //    NSLog(@"%d--%s---%p", __LINE__, __FUNCTION__,self);
    
    if (aNotificationPrefix == nil) return;
    
    self.iNotificationPrefix = aNotificationPrefix;
//    self.iRow = aRow;
//    self.iColumn = aColumn;
    self.m_nRow = aRow;
    self.m_nColumn = aColumn;
    self.iDataType = aDataType;
    
    if (self.iDataType == WSValidateDataDependOtherData){
        NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, aRow, aColumn];
        //        NSLog(@"notifyname = %@", notifyName);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateState:) name:notifyName object:nil];
    }
}

- (void)startObservingEntity
{
    //    NSLog(@"%s---%d", __FUNCTION__, __LINE__);
    if (self.iDataType == WSValidateDataIsDepended) {
        NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.iRow, self.iColumn];
        NSNumber *number = nil;
        if (_selectedIndex && _selectedIndex > 0) {
            number = [NSNumber numberWithBool:YES];
        }else{
            number = [NSNumber numberWithBool:NO];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:number userInfo:nil];
        
        self.iIsObserver = YES;
    }
}

- (void)updateState:(NSNotification *)sender
{
    //    NSLog(@"%d--%s--%p", __LINE__, __FUNCTION__,self);
    NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.m_nRow, self.m_nColumn];
    if (sender.name != nil && [sender.name isEqualToString:notifyName]) {
        NSNumber *number = (NSNumber *)sender.object;
        BOOL isEnable = [number boolValue];
        if (!isEnable) {
            [self setSelectedIndex:DEFAULT_SELECTED];
        }
        self.userInteractionEnabled = isEnable;
        self.alpha = isEnable ? 1.0 : 0.5;
        _isValueChange = YES;
    }
}

- (BOOL)isValueChange {
    return _isValueChange;
}

- (BOOL)entityIsEnable
{
    return self.isUserInteractionEnabled;
}

- (NSString *)getTextValue
{
    
    if (self.selectMode == WSSelectListViewSelectModeSingleSelection) {
        
        if (self.selectedIndex > DEFAULT_SELECTED && self.selectedIndex < [self.content count]) {
            
            return [self.content objectAtIndex:self.selectedIndex];
        }else{
            
            return nil;
        }
    
    }else{
        if ([[self getSelectedContentString] isEqualToString:[self getDefaultString]]) {
            
            return nil;
        }else{
        
            return [self getSelectedContentString];
        }
    }
}

- (BOOL)isValueLegal
{
    return ([self getTextValue] != nil && [[self getTextValue] length] > 0) ? YES : NO;
}

- (BOOL)textCheck
{

    return YES;
}

- (void) flushTable
{
    if (self.sourceTable) {
        [self.sourceTable reloadData];
    }

}

- (void)setContent:(NSMutableArray *)content
{
    if (_content) {
        _content = nil;
    }
    _content = content;
    
    
    
    if (self.selectMode == WSSelectListViewSelectModeSingleSelection){
        
        if ([_content count] > 10) {
            self.selectType = WSSelectLIstViewTypePopShow;
        }else{
            self.selectType = WSSelectLIstViewTypeDefaultShow;
        }
        
    }
}
- (void)setContentDicts:(NSMutableArray *)contentDicts{
    
    if (_contentDicts) {
         _contentDicts = nil;
    }
    _contentDicts = contentDicts;
}
@end
