//
//  WCAcvtListViewController.m
//  WinChannelFrameWork
//
//  Created by Niu Zhaowang on 12/11/12.
//
//

#import "WCAcvtListViewController.h"
#import "WSAcvtViewController.h"
#import "WSAppData.h"

@interface WCAcvtListViewController ()

@end

@implementation WCAcvtListViewController
@synthesize currentFunc = _currentFunc;
@synthesize acvtArray = _acvtArray;

- (id)initWithFuncs:(WSFuncsBean *)funcs
{
    if (self = [super init]) {
        self.currentFunc = funcs;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initAcvtList];
    WSFuncsBean *fb = [self.currentFunc.funcsArray objectAtIndex:0];
    self.title = fb.name;
    // Do any additional setup after loading the view from its nib.
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(void)initAcvtList
{
    if(self.acvtArray == nil)
        self.acvtArray = [[NSMutableArray alloc]init];
    
    WSAcvtBeanArray* l_acvtBeanArray = [WSAppData getObjectbyKey:ACVTS];
    WSFuncsBean *fb = [self.currentFunc.funcsArray objectAtIndex:0];
    NSArray* filtersArray = [l_acvtBeanArray getAcvtsWithFilter:fb.filter];
    for(WSAcvtBean* ab in filtersArray)
    {
        [self.acvtArray addObject:ab];
    }    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.acvtArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    WSAcvtBean* l_acvtBean = [self.acvtArray objectAtIndex:indexPath.row];
    cell.textLabel.text = l_acvtBean.acvtName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WSAcvtBean* l_acvtBean = [self.acvtArray objectAtIndex:indexPath.row];
    WSAcvtViewController* avc = [[WSAcvtViewController alloc]initWithAcvt:l_acvtBean Funcs: self.currentFunc Store:nil];
    avc.title = l_acvtBean.acvtName;
    [self.navigationController pushViewController:avc animated:YES];
}
@end
