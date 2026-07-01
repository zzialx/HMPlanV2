//
//  JFDExecuteViewController.m
//  WinSFA
//
//  Created by dujinfeng481 on 14/12/1.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "JFDExecuteViewController.h"
#import "JFDEntryObject.h"

@interface JFDExecuteViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *serverIpTextField;
@property (weak, nonatomic) IBOutlet UITextField *webAddressTextField;
@property (weak, nonatomic) IBOutlet UISwitch *serverIpSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *webAddressSwitch;

@end

@implementation JFDExecuteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.serverIpTextField.delegate = self;
    self.webAddressTextField.delegate = self;
    
    if ([JFDEntryObject getInstance].debugServerIp) {
        [self.serverIpSwitch setOn:YES animated:NO];
        [self.serverIpTextField setText:[JFDEntryObject getInstance].debugServerIp];
    }else {
        NSString *ServerString = [WSPlistHelper valueForKey:kServerIP withPlistName:kConfilgFileName];
        [self.serverIpTextField setText:ServerString];
    }
    
    if ([JFDEntryObject getInstance].debugWebServer) {
        [self.webAddressSwitch setOn:YES animated:NO];
        [self.webAddressTextField setText:[JFDEntryObject getInstance].debugWebServer];
    }else {
        NSUserDefaults *addressDefaults= [NSUserDefaults standardUserDefaults];
        NSString *loginUrl = [addressDefaults objectForKey:WEB_ADDRESS];
        [self.webAddressTextField setText:loginUrl];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clearDBAction:(id)sender {
    
    //Documents
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataBaseFilePath= [documentsDirectory stringByAppendingPathComponent:@"wch_DataBase.db"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataBaseFilePath])
    {
        NSError *error;
        if ([[NSFileManager defaultManager] removeItemAtPath:dataBaseFilePath error:&error]) {
            [[WSFMDatebase getInstance] closeDB];
            [self.outputLabel setText:[NSString stringWithFormat:@"清除数据库成功:  %@", documentsDirectory]];
        }else {
            [self.outputLabel setText:error.description];
        }
    }else {
        [self.outputLabel setText:[NSString stringWithFormat:@"数据库不存在:  %@", documentsDirectory]];
    }
}

#pragma mark - 设置服务器地址 method
- (IBAction)serverSwitchAction:(UISwitch*)sender {
    [self.serverIpTextField setEnabled:sender.isOn];
}

- (IBAction)webAddressSwitchAction:(UISwitch*)sender {
    [self.webAddressTextField setEnabled:sender.isOn];
}

- (IBAction)okAction:(id)sender {
    if (self.serverIpSwitch.isOn) {
        if (self.serverIpTextField.text.length > 0) {
            [[JFDEntryObject getInstance] exchangeAndsetDebugServerIp: self.serverIpTextField.text];
        }else {
            [self.serverIpSwitch setOn:NO animated:YES];
            [[JFDEntryObject getInstance] exchangeAndsetDebugServerIp: nil];
        }
    }else {
        [[JFDEntryObject getInstance] exchangeAndsetDebugServerIp: nil];
    }
    
    if (self.webAddressSwitch.isOn) {
        if (self.webAddressTextField.text.length > 0) {
            [JFDEntryObject getInstance].debugWebServer = self.webAddressTextField.text;
        }else {
            [self.webAddressSwitch setOn:NO animated:YES];
            [JFDEntryObject getInstance].debugWebServer = nil;
        }
    }else {
        [JFDEntryObject getInstance].debugWebServer = nil;
    }
}

@end
