

#import "WSAnnotationContentView.h"

@implementation WSAnnotationContentView
@synthesize iActionDelegate = _iActionDelegate;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)clearStartAndEndPosition:(id)sender {
    if (self.iActionDelegate && [self.iActionDelegate respondsToSelector:@selector(clearStartAndEndPositionAction)]) {
        [self.iActionDelegate clearStartAndEndPositionAction];
    }
}

- (IBAction)searchRoutes:(id)sender {
    if (self.iActionDelegate && [self.iActionDelegate respondsToSelector:@selector(searchRoutesAction)]) {
        [self.iActionDelegate searchRoutesAction];
    }
}
@end
