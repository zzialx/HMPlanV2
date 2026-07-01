//
//  WSLocationSelectViewController.m
//  WinSFA
//
//  Created by ZhengJiepeng on 13-8-16.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSLocationSelectViewController.h"

#define K_SEARCHBAR_HEIGHT 44.0f

@interface WSLocationSelectViewController ()

@property (nonatomic, copy) NSString *currentLocation;
@property (nonatomic, strong) WSLocationArray *locationArray;
@property (nonatomic, assign) NSInteger locationSelectIndex;
@property (nonatomic,strong) UITableView *locationTableView;

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSArray *dicts;

@property (nonatomic, strong) NSMutableArray *sectionIndexTitles;

@end

@implementation WSLocationSelectViewController

- (id)initWithCurrentLocation:(NSString *)aCurrentLocation dicts:(NSArray *)dicts  selectIndex:(NSInteger)aLocationSelectIndex {
    self = [super init];
    if (self) {
        self.dicts = dicts;
        self.currentLocation = aCurrentLocation;
        _locationSelectIndex = aLocationSelectIndex;
        if (_sections == nil) {
            if (_sectionIndexTitles == nil) {
                _sectionIndexTitles = [[NSMutableArray alloc] init];
                for(char c = 'A'; c <= 'Z'; c++ )
                {
                    [_sectionIndexTitles addObject:[NSString stringWithFormat:@"%c",c]];
                    
                }
            }
            
            _sections = [[NSMutableArray alloc] init];
            NSArray *sectionTitles = [dicts valueForKeyPath:@"@distinctUnionOfObjects.fl"];
            
            for (NSInteger i = 0; i < [sectionTitles count]; i++) {
                NSString *sectionTitle = sectionTitles[i];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.fl == %@",sectionTitle];
                NSArray *rowDatas = [dicts filteredArrayUsingPredicate:predicate];
                [self.sections addObject:rowDatas];
            }
        }
    }
    return self;
}




- (id)initWithCurrentLocation:(NSString *)aCurrentLocation locationArray:(WSLocationArray *)aLocationArray  selectIndex:(NSInteger)aLocationSelectIndex {
    self = [super init];
    if (self) {
        self.currentLocation = aCurrentLocation;
        self.locationArray = aLocationArray;
        _locationSelectIndex = aLocationSelectIndex;
    }
    return self;
}


- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                   target:self
         
                                                                                   action:@selector(cancel)];
    
    self.navigationItem.leftBarButtonItem = flexibleSpace;
    [self.navigationItem.leftBarButtonItem setWidth:12.0f];
    
    [self loadSearchBar];
    
    _locationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, K_SEARCHBAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - K_SEARCHBAR_HEIGHT) style:UITableViewStylePlain];
    self.locationTableView.delegate = self;
    self.locationTableView.dataSource = self;
    [self.view addSubview:self.locationTableView];
    
    
}
- (void)loadSearchBar {
    WSSearchBar *searchBar = [[WSSearchBar alloc] initWithFrame:CGRectMake(0.0, 0, self.view.bounds.size.width, K_SEARCHBAR_HEIGHT)];
    self.ownSearchBar = searchBar;
    self.ownSearchBar.searchBar.delegate = self;
    self.ownSearchBar.searchBar.placeholder = NSLocalizedString(@"query_label", nil);
   [self.view addSubview:self.ownSearchBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   
}


- (void)cancel {
    [self cancelAtIndex:_locationSelectIndex];
}

- (void)cancelAtIndex:(NSInteger)index {
    WSLocationSelectViewController *vc = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (vc.selectDelegate && [vc.selectDelegate respondsToSelector:@selector(locationSelectedAtIndex:andArrat:)]) {
            [vc.selectDelegate performSelector:@selector(locationSelectedAtIndex:andArrat:) withObject:[NSNumber numberWithInteger:index] withObject:self.filterArray];
        }
    }];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 2;
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (section == 0) {
//        return 1;
//    }
//    return [self.filterArray count];
    
    return [self.sections[section] count];
}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionIndexTitles;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.sectionIndexTitles indexOfObject:title];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return self.sectionIndexTitles[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"WSLocationSelectViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
    }
    // clear cell
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.textLabel.text = [(WSDictBean *)(self.sections[indexPath.section][indexPath.row]) name];
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        [self cancelAtIndex:-1];
    } else {
        [self cancelAtIndex:[indexPath row]];
    }
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
    self.filterArray = [NSMutableArray arrayWithArray:self.locationArray.locationArray];
    [self.locationTableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.filterArray = [NSMutableArray arrayWithArray:[self searchUnitbyString:searchBar.text]];
    [self.locationTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    self.filterArray = [NSMutableArray arrayWithArray:[self searchUnitbyString:searchBar.text]];
    [self.locationTableView reloadData];
    
}

- (NSArray *)searchUnitbyString:(NSString *)search{
    
    if (search == nil || [search isEqualToString:@""]) {
        return self.dicts;
    }
    
    NSArray *searchArray = [search componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (searchArray != nil) {
        NSMutableString *format = [NSMutableString stringWithCapacity:4];
        int i = 0;
        NSMutableArray *formatArray = [[NSMutableArray alloc] initWithCapacity:4];
        for (NSString *item in searchArray) {
            if (![item isEqualToString:@""]) {
                if (i == 0) {
                    [format appendString:@"(SELF.name contains[cd] %@)"];
                    [formatArray addObject:item];
                }else{
                    [format appendString:@" AND (SELF.name contains[cd] %@)"];
                    [formatArray addObject:item];
                }
                i++;
            }
            
        }
        if ([formatArray count] > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:format argumentArray:formatArray];
            return [self.dicts filteredArrayUsingPredicate:predicate];
        }
    }
    return nil;
}



@end
