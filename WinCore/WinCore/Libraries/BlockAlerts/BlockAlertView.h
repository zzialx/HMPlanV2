//
//  BlockAlertView.h
//
//

#import <UIKit/UIKit.h>

@class BlockAlertView;

@protocol I_OP_BlockAlertViewDelegate <NSObject>

-(void)clickBtnAtIndex:(NSInteger)index inBlockView:(BlockAlertView *)blockview;

@end

@interface BlockAlertView : NSObject {
    
    __unsafe_unretained id<I_OP_BlockAlertViewDelegate>   opdelegate;
    
@protected
    UIView *_view;
    NSMutableArray *_blocks;
    CGFloat _height;
    NSString *_title;
    NSString *_message;
    BOOL _shown;
    BOOL _cancelBounce;
}

typedef enum {
    BlockAlertViewTypeInfo,
    BlockAlertViewTypeIndeterminate
}BlockAlertViewType;

typedef enum {
    BlockAlertViewAlignmentCenter,
    BlockAlertViewAlignmentLeft
}BlockAlertViewAlignment;


+ (BlockAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message subMessage:(NSString *)subMessage subColor:(UIColor *)subColor alignment:(BlockAlertViewAlignment)alignment subMessageAlignment:(BlockAlertViewAlignment)subMessageAlignment;

+ (BlockAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message;

+ (BlockAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message alignment:(BlockAlertViewAlignment)alignment;
// + (BlockAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message type:(BlockAlertViewType)alertType;

+ (void)showInfoAlertWithTitle:(NSString *)title message:(NSString *)message;
+ (void)showErrorAlert:(NSError *)error;

- (id)initWithTitle:(NSString *)title message:(NSString *)message;

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block;
- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block;
- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block;

// Images should be named in the form "alert-IDENTIFIER-button.png"
- (void)addButtonWithTitle:(NSString *)title imageIdentifier:(NSString*)identifier block:(void (^)())block;

- (void)addComponents:(CGRect)frame;

- (void)show;

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

- (void)setupDisplay;

@property (nonatomic, retain) UIImage *backgroundImage;

@property (nonatomic, readonly) UIView *view;

@property (nonatomic, readwrite) BOOL vignetteBackground;

@property (nonatomic,assign) id<I_OP_BlockAlertViewDelegate>   opdelegate;

@property (nonatomic,assign) BlockAlertViewAlignment alignment;

@property (nonatomic,assign) BlockAlertViewAlignment subAlignment;

@property (nonatomic,copy) NSString *subMessage;

@property (nonatomic,strong) UIColor *subColor;

@end
