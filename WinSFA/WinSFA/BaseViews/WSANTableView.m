//
//  WSANTableView.m
//  WinSFA
//
//  Created by xiajl on 14-11-6.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSANTableView.h"
#import "WSStoreInfoTableViewCell.h"
#import "WSAcvtGridTableViewCell.h"
#import "WSAcvtGridTableViewHeaderView.h"
#import "WSCustomGestrueScrollView.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSAcvtListDataItem.h"

@interface WSANTableView () <UITableViewDataSource,UITableViewDelegate,WSAcvtGridTableViewHeaderViewDelegate,WSAcvtGridTableViewCellDelegate>
{
    NSUInteger tableViewContentHeight;
    
    
    NSMutableArray *acvtNameQstArray;
    
    WSAcvtGridTableViewHeaderView *headerView;
    
    WSAcvtBean_qst *leftTitleQst;
    
    WSCustomGestrueScrollView *contentSrcollView;

}




@end
@implementation WSANTableView
@synthesize usereditable;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.usereditable = YES;
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        
        if (INTERFACE_IS_PAD) {
            
//            UIColor *bgColor = [UIColor colorForKey:@"AcvtViewBackgroundColor"];
//            if (!bgColor) {
//                bgColor = [UIColor whiteColor];
//            }
            
            self.tableView.backgroundColor = RGBCOLOR(246, 246, 246);
            self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            contentSrcollView = [[WSCustomGestrueScrollView alloc] initWithFrame:self.bounds];
            contentSrcollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            contentSrcollView.bounces = NO;
            contentSrcollView.delegate = self;
            [self addSubview:contentSrcollView];
            [contentSrcollView addSubview:self.tableView];
//            self.tableView.bounces = NO;
        }else {
            [self addSubview:self.tableView];
        }
        
        tableViewContentHeight = 0;
        
        acvtNameQstArray = [NSMutableArray array];
    }
    return self;
}

- (void)setAcvtBean:(WSAcvtBean *)acvtBean
{
    _acvtBean = acvtBean;
    
    if ([acvtNameQstArray count] == 0) {
        NSMutableArray *mainQstArray = [NSMutableArray array];
        NSMutableArray *subQstArray = [NSMutableArray array];
        
        for (WSAcvtBean_qst *qst in acvtBean.qsts) {
            if ([qst.isAcvtName isEqualToString:@"1"]) {
                [mainQstArray addObject:qst];
            }else if ([qst.isAcvtName isEqualToString:@"2"]) {
                [subQstArray addObject:qst];
            }else if ([qst.isAcvtName isEqualToString:@"3"]) {
                leftTitleQst = qst;
            }
        }
        
        [acvtNameQstArray addObjectsFromArray:mainQstArray];
        [acvtNameQstArray addObjectsFromArray:subQstArray];
    }
    
    if (INTERFACE_IS_PAD) {
        CGFloat width = [WSAcvtGridTableViewCell getCellRealWidthWithDataCount:[acvtNameQstArray count] displayWidth:self.width hasLeftTitle:leftTitleQst ? YES : NO];
        if (width < self.width) {
            width = self.width;
        }
        [self.tableView setWidth:width];
    }
}

- (void)setReadonly:(BOOL)readonly
{
    _readonly = readonly;
    
    headerView.readonly = readonly;
    
}

#pragma mark - table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (INTERFACE_IS_PAD) {
        return [self.embeddedAcvtsMD5 count];
    }else {
        return [self.dataArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    if (INTERFACE_IS_PAD) {
        WSAcvtGridTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[WSAcvtGridTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        NSString *md5 = self.embeddedAcvtsMD5[indexPath.row];
        NSMutableArray *values = [NSMutableArray array];
        
        cell.md5 = md5;
        cell.delegate = self;
        
        WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
        for (WSAcvtBean_qst *qst in acvtNameQstArray) {
            NSString *value = [service queryPeopleQstValuePresentationByGenID:md5 acvtId:self.acvtBean.acvtId qstBean:qst];
            
            if (!value) {
                value = @"";
            }
            [values addObject:value];
        }
        
        NSString *leftValue;
        if (leftTitleQst) {
            
            leftValue = [service queryPeopleQstValuePresentationByGenID:md5 acvtId:self.acvtBean.acvtId qstBean:leftTitleQst];
        }
        
        [cell setDataArray:values leftTitleQst:leftTitleQst leftTitleValue:leftValue indexPath:indexPath totalCount:self.embeddedAcvtsMD5.count];
        
        return cell;
    }else {
        WSStoreInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[WSStoreInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        WSAcvtListDataItem *item = [self.dataArray objectAtIndex:indexPath.row];
        [cell setData:item];
        cell.readonly = _readonly;
        
        return cell;
    }
    
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (INTERFACE_IS_PAD) {
        return AcvtGridTableViewCellHeight;
    }else {
        return [self statisticsCellHeight:indexPath.row];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (INTERFACE_IS_PAD && self.acvtBean) {
        return AcvtGridTableViewHeaderHeight;
    }else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.acvtBean) {
        NSArray *titleArray = [acvtNameQstArray valueForKey:@"qstName"];
        WSAcvtGridTableViewHeaderView *view = [[WSAcvtGridTableViewHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, AcvtGridTableViewHeaderHeight) titleArray:titleArray leftSpace:leftTitleQst ? AcvtGridTableViewCellLeftTitleTotalWidth : 0];
        view.readonly = self.readonly;
        
        view.delegate = self;
        
        headerView = view;
        
        return view;
    }else {
        return nil;
    }
}

- (NSUInteger)statisticsCellHeight:(NSInteger)row
{
    WSAcvtListDataItem *item = self.dataArray[row];
    return [WSStoreInfoTableViewCell cellHeightWithMainTitle:item.mainTitle rightTitle:item.rightTitle subTitle:item.subTitle.string leftTitle:item.leftTitle tableWidth:self.width isShowActionTip:NO isNotRead:NO isShowLeftIcon:NO];

}

- (CGFloat)getStringHeight:(BOOL) bigText andText:(NSString *)textString
{
    CGSize stringSize;
    
    if (bigText) {
#if  __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        stringSize = [textString sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]}];
#else
        stringSize = [textString sizeWithFont:[UIFont systemFontOfSize:18]];
#endif
    }else{
#if  __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        stringSize = [textString sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
#else
        stringSize = [textString sizeWithFont:[UIFont systemFontOfSize:12]];
#endif
    }
    
    return stringSize.height;
}

#pragma  mark - 

- (void)setEmbeddedAcvtsMD5:(NSMutableArray *)embeddedAcvtsMD5
{
    if (_embeddedAcvtsMD5) {
        
        _embeddedAcvtsMD5 = nil;
    }
    
    _embeddedAcvtsMD5 = embeddedAcvtsMD5;
    
    [self statisticsViewHeight];
    
    [self.tableView reloadData];
        
}

- (void)setDataArray:(NSMutableArray *)dataArray
{
    _dataArray = dataArray;
    
    [self statisticsViewHeight];
    
    [self.tableView reloadData];
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (INTERFACE_IS_PHONE) {
        [self.tableView setFrame:self.bounds];
    }else {
        
        CGFloat width = [WSAcvtGridTableViewCell getCellRealWidthWithDataCount:[acvtNameQstArray count] displayWidth:self.width hasLeftTitle:leftTitleQst ? YES : NO];
        if (width < self.width) {
            width = self.width;
        }
        [self.tableView setFrame:CGRectMake(0, 0, width, self.height)];
        contentSrcollView.contentSize = CGSizeMake(width, self.height);
    }
}

- (void) statisticsViewHeight
{
    tableViewContentHeight = 0;
    
    if (INTERFACE_IS_PAD && self.acvtBean) {
        tableViewContentHeight = AcvtGridTableViewHeaderHeight + AcvtGridTableViewCellHeight * [self.embeddedAcvtsMD5 count];
    }else {
        for (int i =0; i < [self.dataArray count]; i++) {
            
            tableViewContentHeight = tableViewContentHeight + [self statisticsCellHeight:i];
            
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.usereditable) {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if ([self.delegate respondsToSelector:@selector(anTableView:didSelectRowAtIndexPath:)]) {
        
            [self.delegate anTableView:self didSelectRowAtIndexPath:indexPath];
        
        }
        
    }else{
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return !_readonly;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"delete_label", nil);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [self.embeddedAcvtsMD5 removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if ([self.delegate respondsToSelector:@selector(anTableView:didDeleteRowAtIndexPath:)]) {
            [self.delegate anTableView:self didDeleteRowAtIndexPath:indexPath];
        }
        
    }
    
}

- (NSUInteger)tableViewHeight
{
    return tableViewContentHeight;
}

-(void)clearView{
  
    
  
}

#pragma mark - WSAcvtGridTableViewHeaderViewDelegate
- (void)headerViewAddButtonClicked:(WSAcvtGridTableViewHeaderView *)headerView
{
    if ([self.delegate respondsToSelector:@selector(anTableViewAddButtonClicked:)]) {
        [self.delegate anTableViewAddButtonClicked:self];
    }
}

#pragma mark - WSAcvtGridTableViewCellDelegate

- (void)acvtGridTableViewCell:(WSAcvtGridTableViewCell *)cell leftTitleButtonSelected:(BOOL)isSelected
{
    if ([self.delegate respondsToSelector:@selector(anTableView:leftTitleQst:isSelected:md5:)]) {
        [self.delegate anTableView:self leftTitleQst:leftTitleQst isSelected:isSelected md5:cell.md5];
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == contentSrcollView) {
        self.tableView.scrollEnabled = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if(scrollView == contentSrcollView) {
        self.tableView.scrollEnabled = YES;
    }
    
}


@end
