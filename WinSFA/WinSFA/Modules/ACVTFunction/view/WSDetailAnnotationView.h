

#import <MapKit/MapKit.h>
@class WSSalePersonModel;
@class WSPerson4Store;
@interface WSDetailAnnotationView : MKAnnotationView
//数据模型
@property (nonatomic, strong) WSSalePersonModel *saleModel;
@property(nonatomic,strong) WSPerson4Store * personModel;

@end
