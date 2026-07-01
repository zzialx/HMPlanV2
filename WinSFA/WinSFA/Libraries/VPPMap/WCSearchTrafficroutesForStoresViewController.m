//
//  WCSearchTrafficroutesForStoresViewController.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 5/7/13.
//
//

#import "WCSearchTrafficroutesForStoresViewController.h"
#import "MapAnnotationExample.h"
#import "WSSelectListView.h"


enum {
    WCSearchRouteTypeBaiduMapApp = 0,
    WCSearchRouteTypeBaiduMapWeb,
    WCSearchRouteTypeGoogleMapApp,
    WCSearchRouteTypeGoogleMapWeb
};
typedef NSUInteger WCSearchType;


#define WC_BAIDUMAPWEB_SEARCHROUTE  @"http://api.map.baidu.com/direction?origin=latlng:%.12f,%.12f|name:%@&destination=latlng:%.12f,%.12f|name:%@&mode=transit&output=html"


#define WC_BAIDUMAPAPP_SEARCHROUTE  @"baidumap://map/direction?origin=latlng:%.12f,%.12f|name:%@&destination=latlng:%.12f,%.12f|name:%@&mode=transit"

#define WC_GOOGLEMAPAPP_SEARCHROUTE @"comgooglemaps://?saddr=%@@%.12f,%.12f&daddr=%@@%.12f,%.12f&directionsmode=transit"


@interface WCSearchTrafficroutesForStoresViewController ()<ZJPSelectListDelegate>

@property (nonatomic, retain)NSMutableArray *iAnnotations;
@property (nonatomic, retain)MKUserLocation *iCurrentLocation;
@property (nonatomic, retain)MapAnnotationExample *iTapAnnotation;
@property (nonatomic, retain)WSSelectListView *iSearchTypeView;
@property (nonatomic, retain)WSSelectListView *iStartPositionView;
@property (nonatomic, retain)WSSelectListView *iEndPositionView;
@property (nonatomic, assign)int iTapAnnotationIndex;
@property (nonatomic, assign)CLLocationCoordinate2D iOriginLocation;
@property (nonatomic, assign)CLLocationCoordinate2D iEndLocation;
@property (nonatomic, assign)WCSearchType iSearchType;
@end

@implementation WCSearchTrafficroutesForStoresViewController

@synthesize iAnnotations = _iAnnotations;
@synthesize iCurrentLocation = _iCurrentLocation;
@synthesize iTapAnnotation = _iTapAnnotation;
@synthesize iTapAnnotationIndex = _iTapAnnotationIndex;
@synthesize iSearchTypeView = _iSearchTypeView;
@synthesize iStartPositionView = _iStartPositionView;
@synthesize iEndPositionView = _iEndPositionView;
@synthesize iOriginLocation = _iOriginLocation;
@synthesize iEndLocation = _iEndLocation;
@synthesize iSearchType = _iSearchType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)clickForSearchRoutes:(id)sender {
    
    NSString *startPositionName = nil;
    NSString *endPositionName = nil;
    NSString *formatString = nil;
    //Search type
    NSInteger type = self.iSearchTypeView.selectedIndex;
    if (type == WCSearchRouteTypeBaiduMapApp) {
        formatString = WC_BAIDUMAPAPP_SEARCHROUTE;
    }else if (type == WCSearchRouteTypeBaiduMapWeb){
        formatString = WC_BAIDUMAPWEB_SEARCHROUTE;
    }else{
        formatString = WC_GOOGLEMAPAPP_SEARCHROUTE;
    }

    //set Start position
    NSInteger nStartPositionIndex = self.iStartPositionView.selectedIndex;
    id startItem = [self.iAnnotations objectAtIndex:nStartPositionIndex];
    if ([startItem isKindOfClass:[MapAnnotationExample class]]) {
        MapAnnotationExample *map = (MapAnnotationExample*)startItem;
        self.iOriginLocation = map.coordinate;
        startPositionName = map.title;
    }else if ([startItem isKindOfClass:[MKUserLocation class]]){
        MKUserLocation *location = (MKUserLocation *)startItem;
        self.iOriginLocation = location.coordinate;
        startPositionName = location.title;
    }
    
    // set End position
    NSInteger nEndPositionIndex = self.iEndPositionView.selectedIndex;
    id endItem = [self.iAnnotations objectAtIndex:nEndPositionIndex];
    if ([endItem isKindOfClass:[MapAnnotationExample class]]) {
        MapAnnotationExample *map = (MapAnnotationExample*)endItem;
        self.iEndLocation = map.coordinate;
        endPositionName = map.title;
    }else if ([endItem isKindOfClass:[MKUserLocation class]]){
        MKUserLocation *location = (MKUserLocation *)endItem;
        self.iEndLocation = location.coordinate;
        endPositionName = location.title;
    }
    
    // Open URL
    NSString *source = nil;
    if (type != WCSearchRouteTypeGoogleMapApp) {
            source = [NSString stringWithFormat:formatString, self.iOriginLocation.latitude, self.iOriginLocation.longitude,startPositionName,self.iEndLocation.latitude,self.iEndLocation.longitude,endPositionName];
    }else{
            source = [NSString stringWithFormat:formatString, startPositionName,self.iOriginLocation.latitude, self.iOriginLocation.longitude,endPositionName,self.iEndLocation.latitude,self.iEndLocation.longitude];
    }

    NSString *dealwithSource = [source stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *rul = [NSURL URLWithString:dealwithSource];
    BOOL bOpen = [[UIApplication sharedApplication] canOpenURL:rul];
    if (!bOpen) {
        NSString *searchType = [self.iSearchTypeView.content objectAtIndex:type];
        NSString *alertStr = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"if_install",nil),searchType];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertStr message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"confirm", nil) otherButtonTitles:nil,nil];
        [alert show];
        return;
    }
    BOOL bflag = [[UIApplication sharedApplication] openURL:rul];
    if (!bflag) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"search_failure", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"confirm", nil) otherButtonTitles:nil,nil];
        [alert show];
    }
}

- (void)setWithFunction:(WSFuncsBean *)aBean andAllAnnotations:(NSArray *)aAnnotations andTapAnnotation:(id<MKAnnotation>)aMapAnnotaion andCurrentLocation:(id<MKAnnotation>)aCurrentLocation
{
    self.iAnnotations = [NSMutableArray arrayWithArray:aAnnotations];
    self.iTapAnnotation = (MapAnnotationExample *)aMapAnnotaion;
    int i = 0;
    for (MapAnnotationExample *annotation in self.iAnnotations) {
        if ([annotation.title isEqualToString:self.iTapAnnotation.title]) {
            self.iTapAnnotationIndex = i;
            break;
        }
        i++;
    }
    self.iCurrentLocation = (MKUserLocation *)aCurrentLocation;
    if (self.iCurrentLocation.location != nil) {
        [self.iAnnotations addObject:self.iCurrentLocation];
    }    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSMutableArray *contents = [[NSMutableArray alloc] initWithCapacity:[self.iAnnotations count]];
    for (id annotation in self.iAnnotations) {
//        [contents addObject:annotation.title];
        if ([annotation isKindOfClass:[MapAnnotationExample class]]) {
            MapAnnotationExample *map = (MapAnnotationExample*)annotation;
            [contents addObject:map.title];
        }
        
        if ([annotation isKindOfClass:[MKUserLocation class]]) {
            MKUserLocation *location = (MKUserLocation *)annotation;
            [contents addObject:location.title];
        }
    }
    
    //Search Type select view
    NSMutableArray *types = [NSMutableArray arrayWithObjects:@"百度地图App", @"百度地图Web",@"GoogleMap App", nil];
//    NSMutableArray *types = [NSArray arrayWithObjects:@"百度地图App", @"百度地图Web", nil];

    self.iSearchTypeView = [[WSSelectListView alloc] initWithFrame:CGRectMake(10, self.iSearchTypeLabel.frame.origin.y + self.iSearchTypeLabel.frame.size.height+5, 280, 30) style:UITableViewStyleGrouped];
    self.iSearchTypeView.selectListDelegate = self;
    self.iSearchTypeView.content = types;
    [self.view addSubview:self.iSearchTypeView];

    //Start position
    self.iStartPositionView = [[WSSelectListView alloc] initWithFrame:CGRectMake(10, self.iStartPositionTitlelabel.frame.origin.y+self.iStartPositionTitlelabel.size.height+10, 280, 30) style:UITableViewStyleGrouped];
    self.iStartPositionView.selectListDelegate = self;
    self.iStartPositionView.content = contents;
    self.iStartPositionView.selectedIndex = self.iTapAnnotationIndex;
    [self.view addSubview:self.iStartPositionView];
    
    // End position
    self.iEndPositionView = [[WSSelectListView alloc] initWithFrame:CGRectMake(10, self.iEndPositionTitleLabel.frame.origin.y+self.iEndPositionTitleLabel.size.height+10, 280, 30) style:UITableViewStyleGrouped];
    self.iEndPositionView.selectListDelegate = self;
    self.iEndPositionView.content = contents;
    [self.view addSubview:self.iEndPositionView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setISearchTypeLabel:nil];
    [self setIStartPositionTitlelabel:nil];
    [self setIEndPositionTitleLabel:nil];
    [self setIAnnotations:nil];
    [self setICurrentLocation:nil];
    [self setITapAnnotation:nil];
    [self setISearchTypeView:nil];
    [self setIStartPositionView:nil];
    [self setIEndPositionView:nil];
    [super viewDidUnload];
}

- (void)selectListChange:(WSSelectListView *)aSelectListControl
{
    NSLog(@"select index = %ld", (long)aSelectListControl.selectedIndex);
}

@end
