//
//  OTCFollowUpVisitStoreListViewController.m
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-7-2.
//
//

#import "OTCFollowUpVisitStoreListViewController.h"
#import "WSRequestHelper.h"
#import "WSVisitStoreStatusTable.h"

@interface OTCFollowUpVisitStoreListViewController ()

@property (nonatomic, strong) NSArray *storesArray;

@property (nonatomic, assign) BOOL isEverLoad;

@end

@implementation OTCFollowUpVisitStoreListViewController

@synthesize storesArray = _storesArray;


- (id)initWithFuncs:(WSFuncsBean *)funcs Stores:(NSArray *)stores {
    self = [super initWithFuncs:funcs];
    if (self) {
        self.storesArray = stores;
        _isEverLoad = NO;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
   
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.storeArray = [NSMutableArray arrayWithArray:self.storesArray];
    self.filterArray = [NSMutableArray arrayWithArray:self.storesArray];
    for (WSStoreBean * store in self.filterArray) {
        store.actionState = [[WSVisitStoreStatusTable shareInstance] queryStatusWithStoreId:store.Id];
    }
    [self.tableView reloadData];
    /*因需要子类(本类)的数据覆盖父类（WSAllStoreViewController）
     此时父类的self.filterArray = nil(初始化的地图无门店数据) 
     但父类已加载self.stroeMapVC 故为了不影响父类逻辑,删除并重新初始化地图*/
//    if (self.storeMapVC && !_isEverLoad) {
//        [self.storeMapVC.view removeFromSuperview];
//        [self.storeMapVC removeFromParentViewController];
//        [self addOptMapView];
//        
//    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _isEverLoad = YES;
 
}

-(void)startUpdata:(WSStoreBean*)store
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:UPDATA_NOTIFY
                                               object:nil];
    
    NSDictionary *subempPlan = [NSDictionary dictionaryWithObjects:[NSArray
                                         arrayWithObjects:[NSString stringNotNilWithValue:store.Id],
                                         [NSString stringNotNilWithValue:[self getObjIDToStoreInfo]],
                                         [NSString stringNotNilWithValue:self.currentStore.srid],
                                         nil]
                                forKeys:[NSArray arrayWithObjects:
                                         @"storeId",
                                         @"objId",
                                         @"empId",
                                         nil]];
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr postRequestData:subempPlan notifyName:UPDATA_NOTIFY];
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.hidesWhenStopped = YES;
    [aiv startAnimating];
    [self querying_messageTips];
}

-(void)reloadStoreList{
    
}

#pragma mark - UISearchBarDelegate
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:NO animated:YES];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    for(UIView *cc in [searchBar subviews])
    {
        for (UIView *views in [cc subviews]) {
            if([views isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)views;
                NSString *CancelString = NSLocalizedString(@"cancel_label",nil);
                [btn setTitle:CancelString  forState:UIControlStateNormal];
                //                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                //                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                break;
            }
        }
        
    }
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.filterArray = [self searchUnitbyString:searchBar.text].mutableCopy;
    [self.tableView reloadData];

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.filterArray = [self searchUnitbyString:searchBar.text].mutableCopy;
    [self.tableView reloadData];

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    self.filterArray = [self searchUnitbyString:searchBar.text].mutableCopy;
    [self.tableView reloadData];

}

- (NSArray *)searchUnitbyString:(NSString *)search{
    
    if (search == nil || [search isEqualToString:@""]) {
        return self.storeArray;
    }
    
    NSArray *searchArray = [search componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (searchArray != nil) {
        NSMutableString *format = [NSMutableString stringWithCapacity:4];
        int i = 0;
        NSMutableArray *formatArray = [[NSMutableArray alloc] initWithCapacity:4];
        for (NSString *item in searchArray) {
            if (![item isEqualToString:@""]) {
                if (i == 0) {
                    if ([self.currentFuncs.opt.isCode isKindOfClass:[NSString class]] && [self.currentFuncs.opt.isCode isEqualToString:@"0"]) {
                        [format appendString:@"(SELF.name contains[cd] %@)"];
                        [formatArray addObject:item];
                    }else{
                        [format appendString:@"((SELF.name contains[cd] %@) OR (SELF.code contains[cd] %@))"];
                        [formatArray addObject:item];
                        [formatArray addObject:item];
                    }
                    
                }else{
                    if ([self.currentFuncs.opt.isCode isKindOfClass:[NSString class]] && [self.currentFuncs.opt.isCode isEqualToString:@"0"]) {
                        [format appendString:@" AND (SELF.name contains[cd] %@)"];
                        [formatArray addObject:item];
                    }else{
                        [format appendString:@" AND ((SELF.name contains[cd] %@) OR (SELF.code contains[cd] %@))"];
                        [formatArray addObject:item];
                        [formatArray addObject:item];
                    }
                }
                i++;
            }
            
        }
        if ([formatArray count] > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:format argumentArray:formatArray];
            return [self.storeArray filteredArrayUsingPredicate:predicate];
        }
    }
    return nil;
}

@end
