//
//  WCSubInventoryandSalesReportViewController.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 7/8/13.
//
//

#import "WCSubInventoryandSalesReportViewController.h"
#import "WSOutPlanStoreBean.h"
#import "WSAppData.h"
#import "WSFuncsBean_opt.h"

@interface WCSubInventoryandSalesReportViewController ()

@end

@implementation WCSubInventoryandSalesReportViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        self.currentFuncs = funcs;
        self.title = funcs.name;
        NSMutableArray* array = [[NSMutableArray alloc]init];
        self.storeArray = array;
        [self initDataArray];
        return self;
    }
    return nil;
}


- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initDataArray
{
    [self.storeArray removeAllObjects];
    WSOutPlanStoreBean* outPlanStoreArray = [WSAppData getObjectbyKey:OUTPLANSTORE];
    [self.storeArray addObjectsFromArray:outPlanStoreArray.storesArray];
    self.filterArray = [NSMutableArray arrayWithArray:self.storeArray];
}

#pragma mark - search bar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    if([self.currentFuncs.funcsArray count] < 1)
        return;
    
    //modify by wang
    NSArray *results=[self searchUnitbyString:searchBar.text];
    self.filterArray = [NSMutableArray arrayWithArray:results];
    [self.tableView reloadData];    
}

- (NSArray *)searchUnitbyString:(NSString *)aText
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    NSRange range;
    memset(&range, 0, sizeof(NSRange));
    
    for (id obj in self.storeArray) {
        memset(&range, 0, sizeof(NSRange));
        if ([obj isKindOfClass:[WSStoreBean class]]){
            WSStoreBean *store = (WSStoreBean *)obj;
            
            NSString *content = nil;
            if ([self.currentFuncs.opt.isCode isKindOfClass:[NSString class]] && [self.currentFuncs.opt.isCode isEqualToString:@"0"]) {
                content = store.name;
            } else {
                content = [NSString stringWithFormat:@"%@-%@", store.code, store.name];
            }
            
            range = [content rangeOfString:aText];
            
            if (range.length > 0) {
                [ret addObject:store];
            }
        }
    }
    
    return ret;    
}
@end
