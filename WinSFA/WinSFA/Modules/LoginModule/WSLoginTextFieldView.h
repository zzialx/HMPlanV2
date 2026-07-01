//
//  WSLoginTextFieldView.h
//  WinSFA
//
//  Created by Alicia on 2017/10/27.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>


//
#define k_TextFieldXOffSet ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 15 : 100)
#define k_TextFieldYOffSet ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? SCREEN_HEIGHT * 0.01 : 20)
#define k_TextFieldHeight 44


#define k_RemeberYOffSet  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? SCREEN_HEIGHT * 0.02 : 20)
#define k_RemeberIconWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 22 : 30)
#define k_RemeberIconHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 22 : 30)




//
#define k_TextFieldXOffSet ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 15 : 100)
#define k_TextFieldYOffSet ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? SCREEN_HEIGHT * 0.01 : 20)
#define k_TextFieldHeight 44


#define k_RemeberYOffSet  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? SCREEN_HEIGHT * 0.02 : 20)
#define k_RemeberIconWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 22 : 30)
#define k_RemeberIconHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 22 : 30)


#define k_IconImageWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 0 : 55)
#define k_IconImageHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 0 : 31)
#define k_IconImageBottomSpace ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 0 : 72)
#define k_UserPwdIconWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 22 : 30)
#define k_UserPwdIconHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 22 : 30)

@protocol WSLoginTextFieldDelegate <NSObject>

@optional
- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (void)textFieldDidEndEditing:(UITextField *)textField;
- (void)textFieldDidChange:(UITextField *)textField;

@end

@interface WSLoginTextFieldView : UIView

@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, copy) NSString *placeHolderString;
@property (nonatomic, weak) id <WSLoginTextFieldDelegate> delegate;


- (UITextField *)getTextField;

@end
