//
//  WSSingleSelectAndSearchViewController.m
//  WinSFA
//
//  Created by xiajl on 15/3/4.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSSingleSelectAndSearchViewController.h"
#import "WidgetConstant.h"
#import "WSInterAction.h"
#import "WSEnvrionment.h"
#import "WSSearchBar.h"

@interface WSSingleSelectAndSearchViewController () <UISearchBarDelegate>
@property (nonatomic, strong) WSSearchBar       *ownSearchBar;
@property (nonatomic, strong) NSArray    *filterItems;
@property (nonatomic ,strong) UITableView       *tableView;
@end

@implementation WSSingleSelectAndSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"confirm", nil) style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    // Do any additional setup after loading the view from its nib.
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = [self getTableHeaderView];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self.view addSubview:self.tableView];
    
    if ([self.executeParam.execute_class_param isKindOfClass:[NSArray class]]) {
        [self setItemArray:(NSArray *)self.executeParam.execute_class_param];
    }
}

- (void) setItemArray:(NSArray *)itemArray
{
    if (_itemArray) {
        _itemArray = nil;
    }
    _itemArray = itemArray;
    self.filterItems = [NSArray arrayWithArray:itemArray];
    [self.tableView reloadData];
}

-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filterItems count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"singleSelectedAndSearch";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier ];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if (self.isForAcvtGrid) {
        cell.textLabel.text = [self.filterItems objectAtIndex:indexPath.row];
    }
    else {
        
        NSObject <I_W_OptionDataItem> *optionItem = (NSObject<I_W_OptionDataItem> *)[self.filterItems objectAtIndex:indexPath.row];
        cell.textLabel.text = [optionItem getDataItemName];
        if ([[optionItem getDataItemID] isEqualToString:kCancelItemId]) {
            cell.textLabel.textColor = [UIColor lightGrayColor];
        }else {
            cell.textLabel.textColor = [UIColor blackColor];
        }
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*因调查问卷中的表格  */
    if (self.isForAcvtGrid) {
        if (self.selectedDelegate != nil && [self.selectedDelegate respondsToSelector:@selector(singleSelectAndSearchView:selectedItem:)])
        {
            [self.selectedDelegate performSelector:@selector(singleSelectAndSearchView:selectedItem:) withObject:self withObject:[self.filterItems objectAtIndex:indexPath.row]];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else {
        
        if (self.selectedDelegate != nil && [self.selectedDelegate respondsToSelector:@selector(singleSelectAndSearchView:didSelectedItem:)])
        {
            [self.selectedDelegate singleSelectAndSearchView:self didSelectedItem:[self.filterItems objectAtIndex:indexPath.row]];
        }
        
        if (self.wcBaseViewdelegate && [self.wcBaseViewdelegate respondsToSelector:@selector(callBackWhenFinishTask:)]) {
            self.executeParam.execute_result = [self.filterItems objectAtIndex:indexPath.row];
            [self.wcBaseViewdelegate callBackWhenFinishTask:self.executeParam];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (UIView *)getTableHeaderView {
    
    WSSearchBar *searchBar = [[WSSearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0) isResetTextField:NO isResetBackgroundColor:NO isTop:NO isNotAutoresizingFlexible:YES];
    self.ownSearchBar = searchBar;
    self.ownSearchBar.searchBar.delegate = self;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    if (INTERFACE_IS_PHONE) {
        [headerView setBackgroundColor:MAIN_SEARCH_BG_COLOR];
    }
    [headerView  addSubview:self.ownSearchBar];
  
    self.ownSearchBar.searchBar.placeholder = NSLocalizedString(@"query_label", nil);
    return headerView;
}
#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    
    for(id cc in [searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            NSString *CancelString = NSLocalizedString(@"cancel_label",nil);
            [btn setTitle:CancelString  forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.filterItems = [NSMutableArray arrayWithArray:self.itemArray];
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (self.isForAcvtGrid) {
        self.filterItems = [NSMutableArray arrayWithArray:[self searchUnitbyString:searchBar.text]];
    }else {
        self.filterItems = [NSMutableArray arrayWithArray:[self searchItemByKeyword:searchBar.text]];
    }
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    if (self.isForAcvtGrid) {
        self.filterItems = [NSMutableArray arrayWithArray:[self searchUnitbyString:searchBar.text]];
    }else {
        self.filterItems = [NSMutableArray arrayWithArray:[self searchItemByKeyword:searchBar.text]];
    }
    [self.tableView reloadData];
    
}

- (NSArray *)searchUnitbyString:(NSString *)search{
    
    if (search == nil) {
        return self.itemArray;
    }
    
    //去除字符串两边的空格
    search = [search stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //只有空格 不作为
    if ([search isEqualToString:@""]) {
        return self.itemArray;
    }
    
    NSArray *searchArray = [search componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (searchArray != nil) {
        NSMutableString *format = [NSMutableString stringWithCapacity:4];
        int i = 0;
        NSMutableArray *formatArray = [[NSMutableArray alloc] initWithCapacity:4];
        for (NSString *item in searchArray) {
            if (![item isEqualToString:@""]) {
                if (i == 0) {
                    [format appendString:@"(SELF contains[cd] %@)"];
                    [formatArray addObject:item];
                    
                }else{
                    [format appendString:@" AND (SELF contains[cd] %@)"];
                    [formatArray addObject:item];
                }
                i++;
            }
            
        }
        
        if ([formatArray count] > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:format argumentArray:formatArray];
            NSArray *proArray = [self.itemArray filteredArrayUsingPredicate:predicate];
            return proArray;
        }
    }
    return nil;
}

- (NSArray *)searchItemByKeyword:(NSString *)keywordString{
    
    if (keywordString == nil) {
        return self.itemArray;
    }
    
    //去除字符串两边的空格
    keywordString = [keywordString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //只有空格 不作为
    if ([keywordString isEqualToString:@""]) {
        return self.itemArray;
    }
    
    NSArray *keywordArray = [keywordString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    if ([keywordArray count] > 0) {
        
        for (NSObject<I_W_OptionDataItem> *dataItem in self.itemArray) {
            NSString *name = [dataItem getDataItemName];
            BOOL isMatch = YES;
            for (NSString *keyword in keywordArray) {
                if ([name rangeOfString:keyword options:NSCaseInsensitiveSearch].location == NSNotFound) {
                    isMatch = NO;
                    break;
                }
            }
            if (isMatch) {
                [resultArray addObject:dataItem];
            }
        }
    }
    
    if ([resultArray count] > 0) {
        return resultArray;
    }
    else {
        return nil;
    }

}


@end
