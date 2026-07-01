//
//  WSRMShowBaseController.m
//  WinSFA
//
//  Created by zhiqing on 16/9/1.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRMShowBaseController.h"
#import "WSBaseDictsTable.h"
#import "WSRichMediaTable.h"
#import "WSRichModel.h"
#import "WSRichItemModel.h"
#import "PureLayout.h"
#import "QRCodeGenerator.h"
#import "WSRichMediaTemplateTable.h"
#import "WSRichMediaTemplate.h"
#import "WSServerIPList.h"
#import "WSServerIPController.h"
#import "WSShowH5ViewController.h"
#define CACHE_DIR [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface WSRMShowBaseController ()



@end

@implementation WSRMShowBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.allItemModel = [self getAllItemWith:self.filterName]; // 获取搜索数据源
}

-(void)reloadData{

    self.allItemModel = [self getAllItemWith:self.filterName]; // 获取搜索数据源

}

-(NSArray * )getFilterItemsWiht:(NSString *)filter{  


    NSString *sql = [NSString stringWithFormat:@"SELECT dict2._id,dict2.name,dict2.pid  FROM base_dicts AS dict1, base_dicts AS dict2 WHERE dict1.typ ='fumeiti_label' AND dict1.name = '%@' AND dict1.levelCode = 1 AND dict1._id = dict2.pid ORDER BY dict2.SEQ *1;",filter];
   return  [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSRichModel"];
    

}

-(NSArray *)getAllItemWith:(NSString *)filter withFilterName:(NSString *)FilterName{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT spe.ID, spe.speid, spe.cod,spe.name ,spe.typ, spe.memo, spe.img_url, spe.h5_url, spe.levelCode, spe.h5_add, spe.img_add , spe.share_url , spe.isread ,spe.type_,spe.fenleiId FROM  base_dicts AS dict, spe_richMedia AS spe WHERE dict.name = '%@' AND  dict.typ = 'fumeiti_label' AND dict._id = spe.typ AND spe.type_ = '1' ORDER BY spe.seq * 1;",filter];
    
   NSArray * allArray =  [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSRichItemModel"];
    
    
    NSMutableArray *itemArray = [NSMutableArray array];
    for (int i = 0; i < allArray.count; i++) {
        WSRichItemModel *item = allArray[i];
        NSArray *memoItem = [item.memo componentsSeparatedByString:@","];
        for (int j = 0; j < memoItem.count; j++) {
            NSString *str2 = memoItem[j];
            if ([str2 isEqualToString:FilterName]) {
                [itemArray addObject:item];
            }
        }
    }
   
    
    return itemArray;


}

-(NSArray *)getAllItemWith:(NSString *)filter{

    NSString *sql = [NSString stringWithFormat:@"SELECT spe.ID, spe.speid, spe.cod,spe.name ,spe.typ, spe.memo, spe.img_url, spe.h5_url, spe.levelCode, spe.h5_add, spe.img_add ,spe.share_url , spe.isread ,spe.type_,spe.fenleiId FROM  base_dicts AS dict, spe_richMedia AS spe WHERE dict.name = '%@' AND  dict.typ = 'fumeiti_label' AND dict._id = spe.typ AND spe.type_ = '1' ORDER BY spe.seq * 1;",filter];
    
   return  [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSRichItemModel"];
    

}
-(UIImage *)getImageWith:(NSString *)filePath wihtType:(NSString *)type{

    NSString *imgStr = [NSString stringWithFormat:@"%@/richMedia/%@/%@",CACHE_DIR,filePath,type];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:imgStr];
    if (image == nil) {
        image = [UIImage imageNamed:@"3d-0@2x"];
    }
    return image;
}


#pragma mark - webView

- (void)itemClickCallH5WithItemModel:(WSRichItemModel *)item
{
    WSShowH5ViewController  *h5Ctrl = [[WSShowH5ViewController alloc]init];
    h5Ctrl.filterName = self.filterName;
    [h5Ctrl itemClickCallH5WithItemModel:item];
    h5Ctrl.reloadBlock = ^(){
        [self reloadData];
    };
    [self presentViewController:h5Ctrl animated:YES completion:nil];
}

@end
