//
//  WCPfizerSelectedDoctorsViewController.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 7/1/13.
//
//

#import "WCPfizerSelectedDoctorsViewController.h"

@interface WCPfizerSelectedDoctorsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)NSArray *iSourceArray;
@property (nonatomic, strong)NSMutableArray *iResultArray;
@property (nonatomic, strong)UITableView *iTableView;

@end

@implementation WCPfizerSelectedDoctorsViewController

@synthesize iSourceArray = _iSourceArray;
@synthesize iResultArray = _iResultArray;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

#pragma mark - init and dealloc

- (id)initWithSourceArray:(NSArray *)aSourceArray andResultArray:(NSMutableArray *)aResultArray
{
    self = [super init];
    if (self) {
        _iSourceArray = aSourceArray;
        _iResultArray = aResultArray;
    }
    return  self;
}


- (void)loadView
{
    [super loadView];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    
    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    tv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tv.delegate = self;
    tv.dataSource = self;
    [self.view addSubview:tv];
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
    if (!self.isViewLoaded) {
        self.iTableView = nil;
    }
}


#pragma mark - UITableView delegate and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.iSourceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tvIndentify = @"selecteddoctors";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tvIndentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tvIndentify];
    }
    
    NSDictionary *docInfo = [self.iSourceArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:UI_Font];
    cell.textLabel.text = (NSString *)[docInfo objectForKey:@"name"];
    cell.textLabel.numberOfLines = 0;
    if ([self findDoctorInfoInResultArray:docInfo]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictory = [self.iSourceArray objectAtIndex:indexPath.row];
    NSString *name = [dictory objectForKey:@"name"];
    UIFont *font = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? [UIFont systemFontOfSize:17] : [UIFont systemFontOfSize:22];

    CGSize size = [name ws_sizeWithFont:font constrainedToWidth:self.view.bounds.size.height lineBreakMode:NSLineBreakByCharWrapping];
    
    return size.height+20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dicInfo = [self.iSourceArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil && cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        [self.iResultArray removeObject:dicInfo];
    }else{
        [self.iResultArray addObject:dicInfo];
    }
    [tableView reloadData];
}


- (BOOL)findDoctorInfoInResultArray:(NSDictionary *)aDoctorInfo
{
    __block BOOL bfind = NO;
    [self.iResultArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *docInfo = (NSDictionary *)obj;
        if ([aDoctorInfo isEqualToDictionary:docInfo]) {
            bfind = YES;
            (*stop) = YES;
        }
    }];
    return bfind;
}


@end
