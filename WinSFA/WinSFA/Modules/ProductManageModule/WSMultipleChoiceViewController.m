//
//  WCMultipleChoiceViewController.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 7/17/13.
//
//

#import "WSMultipleChoiceViewController.h"
#import "WSBaseItemOfChoice.h"

@interface WSMultipleChoiceViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)NSArray *iSourceArray;
@property (nonatomic, strong)NSMutableArray *iResultsArray;

@end

@implementation WSMultipleChoiceViewController

@synthesize delegate = _delegate;
@synthesize iSourceArray = _iSourceArray;
@synthesize iResultsArray = _iResultsArray;
@synthesize iTitle = _iTitle;
@synthesize iSourceView = _iSourceView;


#pragma mark - init and dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithSourceArray:(NSArray *)aSourceArray andResultsArray:(NSMutableArray *)aResultsArray
{
    self = [super init];
    if (self) {
        _iSourceArray = aSourceArray;
        _iResultsArray = aResultsArray;
    }
    return self;
}


#pragma mark - view load cycle

- (void)loadView
{
    [super loadView];
    
    // Add table view
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.rowHeight = 40.0f;
    [self.view addSubview:tableview];
    
    NSString *title = NSLocalizedString(@"confirm", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(dismissViewController:)];
    
    
    NSString *cancel = NSLocalizedString(@"cancel_label", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:cancel style:UIBarButtonItemStyleDone target:self action:@selector(cancelClicked:)];
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

#pragma mark - private function

- (NSInteger)findItemIndexInArray:(NSArray *)aSourceArray withName:(NSString *)aName
{
    __block NSInteger index = -1;
    
    [aSourceArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id<WSBaseItemOfChoice> item = (id<WSBaseItemOfChoice>)obj;
        if ([item conformsToProtocol:@protocol(WSBaseItemOfChoice)]) {
            NSString *name = item.name;
            if ([name isEqualToString:aName]) {
                index = idx;
                (*stop) = YES;
            }
        }
    }];
    
    return index;
}

#pragma mark - tableview datasource and delegate

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.iTitle != nil && [self.iTitle length] > 0) {
        return self.iTitle;
    }else{
//        NSString *title = NSLocalizedString(@"MutileChoice", nil);
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.iSourceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"identifychoice";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    id<WSBaseItemOfChoice> item = [self.iSourceArray objectAtIndex:indexPath.row];
    if ([item conformsToProtocol:@protocol(WSBaseItemOfChoice)]) {
        cell.textLabel.text = item.name;
        NSInteger idx = [self findItemIndexInArray:self.iResultsArray withName:item.name];
        cell.accessoryType = (idx > -1) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id<WSBaseItemOfChoice> item = [self.iSourceArray objectAtIndex:indexPath.row];
    if ([item conformsToProtocol:@protocol(WSBaseItemOfChoice)]) {
        NSInteger idx = [self findItemIndexInArray:self.iResultsArray withName:item.name];
        if (idx > -1) {
            [self.iResultsArray removeObjectAtIndex:idx];
        }else{
            [self.iResultsArray addObject:item];
        }
    }
    NSArray *array = [NSArray arrayWithObjects:indexPath, nil];
    [tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - right bar item action

- (void)dismissViewController:(id)sender
{
    __weak WSMultipleChoiceViewController *wvc = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (wvc.delegate != nil && [wvc.delegate respondsToSelector:@selector(multipleChoiceViewController:withResults:)]) {
            [wvc.delegate multipleChoiceViewController:wvc withResults:wvc.iResultsArray];
        }
    }];
}

- (void)cancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
