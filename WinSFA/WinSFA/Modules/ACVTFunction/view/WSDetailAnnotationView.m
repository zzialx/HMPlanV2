

#import "WSDetailAnnotationView.h"
#import "UIView+Extension.h"
#import "WSDetailView.h"

@interface WSDetailAnnotationView ()

@property(nonatomic,strong)WSDetailView * detail;

@property(nonatomic ,strong)UIView  *leftView;

@property(nonatomic ,strong)UIView  *rightView;
@end
@implementation WSDetailAnnotationView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
       
        self.detail = [[WSDetailView alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];

        [self addSubview:self.detail];

    }

 // self.backgroundColor = [UIColor orangeColor];
  
    return self;
    
}

-(void)setSaleModel:(WSSalePersonModel *)saleModel{

    _saleModel = saleModel;
    self.detail.saleModel = saleModel;

}

-(void)setPersonModel:(WSPerson4Store *)personModel{
    _personModel = personModel;
    
    self.detail.personModel = personModel;


}


@end
