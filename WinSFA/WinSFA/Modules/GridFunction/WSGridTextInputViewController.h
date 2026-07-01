//
//  GridTextInputViewController.h
//  WinChannelFrameWork
//
//  Created by Zheng Jiepeng on 12-10-24.
//
//

#import <UIKit/UIKit.h>

@class WSGridTextInputViewController;

@protocol WSGridTextInputDelegate <NSObject>

@optional
- (void)gridTextInputFinish:(WSGridTextInputViewController *)gridTextInput;

@end

@interface WSGridTextInputViewController : UIViewController<UITextViewDelegate>

@property (nonatomic, strong) UITextField *currentTextField;

@property (strong, nonatomic) IBOutlet UITextView *inputTextField;

@property (retain, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (nonatomic,assign) NSInteger maxWordCount;

@property (nonatomic, assign) BOOL isValueChange;

@property (nonatomic, weak) id<WSGridTextInputDelegate> delegate;

@end
