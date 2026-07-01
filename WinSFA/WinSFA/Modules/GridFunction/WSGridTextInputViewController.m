//
//  GridTextInputViewController.m
//  WinChannelFrameWork
//
//  Created by Zheng Jiepeng on 12-10-24.
//
//

#import "WSGridTextInputViewController.h"
#import "QuartzCore/QuartzCore.h"

@interface WSGridTextInputViewController ()

@end

@implementation WSGridTextInputViewController

@synthesize currentTextField = _currentTextField;
@synthesize inputTextField = _inputTextField;

#pragma mark - init & dealloc

#pragma mark - viewcontroller
- (void)viewDidLoad
{
    [super viewDidLoad];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        
        self.naviBar.size = CGSizeMake(320, 64);
        self.inputTextField.origin = CGPointMake(self.inputTextField.origin.x, self.inputTextField.origin.y+20);
    }
#endif
    self.inputTextField.text = _currentTextField.text;
    self.inputTextField.layer.borderWidth = 1;
    self.inputTextField.layer.cornerRadius = 7;
    
    //显示不切换输入法的键盘
    if ([self.currentTextField isKindOfClass:[WSHTextField class]]) {
        
        WSHTextField *tempTextFiled = (WSHTextField *)self.currentTextField;
        if (tempTextFiled.m_isGride && [tempTextFiled.m_type isEqualToString:COL_TYPTEXT])
            self.inputTextField.keyboardType = UIKeyboardTypeASCIICapable;
    }
    
    self.inputTextField.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.inputTextField becomeFirstResponder];
}

#pragma mark - private API
- (IBAction)finishButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.inputTextField.text.length>self.maxWordCount) {
        self.inputTextField.text = [self.inputTextField.text substringToIndex:self.maxWordCount];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:[NSString stringWithFormat:@"%@:%ld", NSLocalizedString(@"input_digits_max", nil), (long)self.maxWordCount] tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
    _currentTextField.text = self.inputTextField.text;
    if (self.delegate && [self.delegate respondsToSelector:@selector(gridTextInputFinish:)]) {
        [self.delegate performSelector:@selector(gridTextInputFinish:) withObject:self];
    }
}

- (IBAction)cancelButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidUnload {
    [self setInputTextField:nil];
    [self setNaviBar:nil];
    [super viewDidUnload];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

    _isValueChange = YES;
    
    //只接受字母和数字的输入的校验
    if ([self.currentTextField isKindOfClass:[WSHTextField class]]) {
        
        WSHTextField *tempTextFiled = (WSHTextField *)self.currentTextField;
        
        if (tempTextFiled.m_isGride && [tempTextFiled.m_type isEqualToString:COL_TYPTEXT]) {
            if (!textView.markedTextRange) {
                
                return [tempTextFiled shouldReplacementString:text inRange:range];
            }
            
        }
        
    }
    return YES;
}

@end
