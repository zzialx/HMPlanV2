//
//  WSMapViewController.m
//  WinSFA
//
//  Created by admin on 15/11/12.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSMapViewController.h"
#import "WSSalePersonModel.h"
#import "WSAnnotation.h"
#import "WSAnnotationView.h"
#import "WSDetailAnnotation.h"
#import "WSDetailAnnotationView.h"
#import "UIView+Extension.h"
#import "WSPerson4Store.h"
@interface WSMapViewController ()<MKMapViewDelegate>

@property(nonatomic,strong) MKMapView * mapView;
@end

@implementation WSMapViewController

-(instancetype)initWithModel:(WSSalePersonModel *)SalePersonModel{
    
    if(SalePersonModel == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        self.salePerson = SalePersonModel;
        return self;
    }
    
    return nil;


}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.mapView = [[MKMapView alloc]initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(39.42, 116.42);
    MKCoordinateRegion region =  MKCoordinateRegionMake(coor, span);
    [self.mapView setRegion:region animated:YES];
    [self.view addSubview:self.mapView];
    
    
    for (WSPerson4Store * personModel  in self.salePerson.person4store) {
        WSAnnotation * anno = [[WSAnnotation alloc]init];
        
        anno.personModel = personModel;
        
        [self.mapView addAnnotation:anno];
    }

}



-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    if ([annotation isKindOfClass:[WSAnnotation class]]) {
        static NSString * ID = @"anno";
        
        WSAnnotationView *annoView = (WSAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:ID];
        if (annoView == nil) {
            annoView = [[WSAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:ID];
        }
        // 设置数据
        WSAnnotation *anno = (WSAnnotation * )annotation;
        
        annoView.image = [UIImage imageNamed:anno.personModel.icon];
        
        
        return annoView;
    }else if ([annotation isKindOfClass:[WSDetailAnnotation class]]){ // 信息大头针视图
        static NSString * detailID = @"annoDetail";
        
        WSDetailAnnotationView * detailView = (WSDetailAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:detailID];
        if (detailView == nil) {
            
            detailView = [[WSDetailAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:detailID];
        }
        detailView.frame = CGRectMake(0, 0, 100, 150);
        
        WSDetailAnnotation * detail = (WSDetailAnnotation * )annotation;
        
        detailView.personModel = detail.personModel;
        
        return detailView;
        
    }else{
        return nil;
        
    }
    
    
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
    if ([view isKindOfClass:[WSAnnotationView class]]) {
        // 拿到销售模型
        WSAnnotationView * annoView = (WSAnnotationView *) view;
        
        // 取出模型
        WSAnnotation * anno = (WSAnnotation *)annoView.annotation;
        if (anno.isShowDesc) {
            return;
        }else{
            // 删除别的大头针
            // 删除 模型
            for (id anno in mapView.annotations) {
                // 是信息大头针 才删除
                if ([anno isKindOfClass:[WSDetailAnnotation class]]) {
                    [mapView removeAnnotation:anno];
                }else{ // 销售人员模型  需要把isShowDesc 置为no
                    
                    WSAnnotation * annoSaleModel = (WSAnnotation *)anno;
                    annoSaleModel.isShowDesc = NO;
                    
                }
            }
            
            // 获取销售 视图的模型数据]
            WSAnnotation * anno = (WSAnnotation *) view.annotation;
            
            // 添加大头针模型
            // 创建 信息大头针模型  :位置与现售人员大头针模型一至
            WSDetailAnnotation * detailAnno = [[WSDetailAnnotation alloc]init];
            
            detailAnno.personModel = anno.personModel;
            
            [mapView addAnnotation:detailAnno];
            // 把新添加的这个模型对应的 团购模型里面的ishowDesc 置为YES
            anno.isShowDesc = YES;
            
        }
    }else{
        
        //点击了其他的大头针视图
        
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
