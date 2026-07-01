//
//  WSPfizerAcvtListViewController.m
//  Pfizer
//
//  Created by yang on 13-11-11.
//  Copyright (c) 2013年 Winchannel. All rights reserved.
//

#import "WSPfizerAcvtListViewController.h"
#import "WSMarketActivityForAcvt.h"
#import "WSVisitStoreActionTable.h"

@interface WSPfizerAcvtListViewController ()

@end

@implementation WSPfizerAcvtListViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WSAcvtBean* l_acvtBean = [self.m_currentAcvtArray objectAtIndex:indexPath.row];
    WSMarketActivityForAcvt *avc = [[WSMarketActivityForAcvt alloc] initWithAcvt:l_acvtBean Funcs:self.m_currentFuncs Store:self.m_currentStore];

    
    avc.title = l_acvtBean.acvtName;
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    if (self.m_currentStore != nil) {
        action.store_id = self.m_currentStore.Id;
    }else{
        action.store_id = self.m_SubempstoreBean.Id;
    }
    action.func_code = self.m_currentFuncs.fc;
    action.dict_id = l_acvtBean.acvtId;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.title = l_acvtBean.acvtName;
    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        
        action.module_fc = self.currentVisitAction.module_fc;
    }else{
        
        action.module_fc = action.func_code;
    }
    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
    
    avc.currentVisitAction = action;
    
    if (avc) {
        if (self.navigationController != nil) {
            [self.navigationController pushViewController:avc animated:YES];
        }else{
            [self.m_ParentViewController.navigationController pushViewController:avc animated:YES];
        }
        
        avc = nil;
    }
    
    
}


@end
