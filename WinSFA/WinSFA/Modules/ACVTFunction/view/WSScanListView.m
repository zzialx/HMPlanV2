//
//  WSScanListView.m
//  WinSFA
//
//  Created by winchannel on 15/10/14.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSScanListView.h"
#import "WSScanListViewController.h"


@interface WSScanListView ()

@property (nonatomic, strong) WSScanListMenuCell *activeCell;
@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, strong) WSOverLayView *overLayView;

@end

@implementation WSScanListView

@synthesize isAllowScroll,editingCellNum;

- (id)initWithFrame:(CGRect)frame withDataArray:(NSMutableArray *)dataArray withMenuArray:(NSMutableArray *)menuArray withQstId:(NSString *)qstId withBtnTitile:(NSString *)btnTitle{

    self = [super initWithFrame:frame];
    if (self) {
        
        self.isEditing = NO;
        self.menuArray = [[NSMutableArray alloc]init];
        self.resultArray = [[NSMutableArray alloc]init];
        self.photosDict = [[NSMutableDictionary alloc]init];
        
        self.menuArray = menuArray;
        for (NSString *code in dataArray) {
            [self.resultArray addObject:code];
        }
        
//        self.scanResultList = [[UITableView alloc]initWithFrame:CGRectMake(0,0, frame.size.width, self.resultArray.count * MAIN_CELL_HEIGHT) style:UITableViewStylePlain];
        self.scanResultList = [[UITableView alloc]initWithFrame:CGRectMake(0,0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        self.scanResultList.dataSource = self;
        self.scanResultList.delegate = self;
        self.scanResultList.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.scanResultList];
        
        self.isAllowScroll = TableIsForbiddenScroll;
        
        
    }
    
    return self;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.resultArray.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"cell";
    
    WSScanListMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        
        cell =[[WSScanListMenuCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier andCellWidth:self.scanResultList.bounds.size.width];
        cell.delegate = self;
        
    }
    
    cell.isPhotoRequire = self.isPhotoRequire;
   
    NSString *imei = [self.resultArray objectAtIndex:indexPath.row];
    NSInteger number = self.resultArray.count - indexPath.row;
    NSString *imeiAndNumber = [NSString stringWithFormat:@"%ld. %@",(long)number,imei];
    cell.photosCout = nil;
    if ([self.photosDict objectForKey:imei]) {
        NSArray *cellPhotos =[self.photosDict objectForKey:imei];
        if ([cellPhotos count] > 0) {
            cell.photosCout = [NSString stringWithFormat:@"%lu",(unsigned long)cellPhotos.count];
        }
    }
    
    [cell configWithData:indexPath mainTitle:imeiAndNumber menuData:self.menuArray];
    //    MN-2564 donghong 如果是最后一个cell不显示 线
    if (self.resultArray.count - 1 ==indexPath.row) {
        cell.separatorInset = UIEdgeInsetsMake(0, self.scanResultList.frame.size.width, 0, 0);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    return ;
    
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.scanResultList cellForRowAtIndexPath:indexPath] == self.activeCell) {
        [self hideMenuActive:YES];
        return NO;
    }
    
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *mainTitle = [self.resultArray objectAtIndex:indexPath.row];
    
    
    NSString *imeiAndNumber = [NSString stringWithFormat:@"%ld. %@", (long)indexPath.row,mainTitle];
    
    CGFloat height = [WSScanListMenuCell heightWithMainTitle:imeiAndNumber withSubTitle:nil withCellFrame:self.bounds];
    
    
    return height;
}

- (void)deleteCell:(WSScanListMenuCell *)cell{
    
    [cell.superview sendSubviewToBack:cell];
    self.isEditing = NO ;
    
    NSIndexPath *index = cell.indexPathNum ;
    
    //NSString *scanStr =[self.resultArray objectAtIndex:index.row];
    
    //[self.scanResultList deleteRowsAtIndexPaths:@[[self.scanResultList indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.delegate deletScanCodeWithSendeMode:DeleteMessage withCellIndexNum:index];
    
}
- (void)addPhotosCell:(WSScanListMenuCell *)cell withIndex:(NSIndexPath *)index{
    
    [self.delegate addPhotosWithCellIndex:index];
}

//OverLayView 点击视图的任何有效区域能够收起menu
- (void)setIsEditing:(BOOL)isEditing{
    if (_isEditing != isEditing) {
        _isEditing = isEditing;
    }
    
    if (isAllowScroll == TableIsScroll) {
        return;
    }
    
    if (_isEditing) {
        if (!_overLayView) {
            _overLayView = [[WSOverLayView alloc] initWithFrame:self.scanResultList.bounds];
            
        
            _overLayView.delegate = self;
            [self.scanResultList addSubview:_overLayView];
        }
    }else{
        self.activeCell = nil;
        [_overLayView removeFromSuperview];
        _overLayView = nil;
    }
}

- (UIView *)overLayView:(WSOverLayView *)view didHitPoint:(CGPoint)didHitPoint withEvent:(UIEvent *)withEvent{
    BOOL shoudReceivePointTouch = YES;
    
    //CGPoint location = [self convertPoint:didHitPoint fromView:view];
    CGRect rect = [self  convertRect:self.activeCell.frame toView:self];
    shoudReceivePointTouch = CGRectContainsPoint(rect, didHitPoint);
    if (!shoudReceivePointTouch) {
        [self hideMenuActive:YES];
    }
    
    return (shoudReceivePointTouch) ? [self.activeCell hitTest:didHitPoint withEvent:withEvent] : view;
}


- (void)hideMenuActive:(BOOL)aninated{
    
    __block WSScanListView *tableViewMenu = self;
    [self.activeCell setMenuHidden:YES animated:YES completionHandler:^{
        tableViewMenu.isEditing = NO;
    }];
    
}

- (void)tableMenuDidShowInCell:(WSScanListMenuCell *)cell{
    self.editingCellNum = [self.scanResultList indexPathForCell:cell].row;
    self.isEditing = YES;
    self.activeCell = cell;
}
- (void)tableMenuWillShowInCell:(WSScanListMenuCell *)cell{
    self.editingCellNum = [self.scanResultList indexPathForCell:cell].row;
    self.isEditing = YES;
    self.activeCell = cell;
}
- (void)tableMenuDidHideInCell:(WSScanListMenuCell *)cell{
    self.editingCellNum = -1;
    self.isEditing = NO;
    self.activeCell = nil;
}
- (void)tableMenuWillHideInCell:(WSScanListMenuCell *)cell{
    self.editingCellNum = -1;
    self.isEditing = NO;
    self.activeCell = nil;
}
- (void)reloadScanList{
    
    [self.scanResultList reloadData];
}

- (void)reSetScanResultListFrame{
    
    CGRect rect = self.scanResultList.frame;

    self.scanResultList.frame = CGRectMake(rect.origin.x,rect.origin.y, rect.size.width, self.resultArray.count *MAIN_CELL_HEIGHT);
}
@end
