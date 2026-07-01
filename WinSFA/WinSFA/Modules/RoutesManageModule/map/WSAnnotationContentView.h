

#import <UIKit/UIKit.h>

@protocol annotationContentViewDelegate <NSObject>

- (void)clearStartAndEndPositionAction;
- (void)searchRoutesAction;

@end

@interface WSAnnotationContentView : UIView
@property (nonatomic, weak) id <annotationContentViewDelegate> iActionDelegate;
@property (strong, nonatomic) IBOutlet UILabel *iTitle;
@property (strong, nonatomic) IBOutlet UILabel *iSubTitle;
@property (strong, nonatomic) IBOutlet UILabel *iStartPosition;
@property (strong, nonatomic) IBOutlet UILabel *iEndPosition;
@property (strong, nonatomic) IBOutlet UIButton *iClearBtn;
@property (strong, nonatomic) IBOutlet UIButton *iSearchBtn;
- (IBAction)clearStartAndEndPosition:(id)sender;
- (IBAction)searchRoutes:(id)sender;
@end
