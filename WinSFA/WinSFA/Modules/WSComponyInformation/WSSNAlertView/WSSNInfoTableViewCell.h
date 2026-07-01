//
//  WSSNInfoTableViewCell.h
//  HookExampleApp
//
//  Created by admin on 2023/2/15.
//

#import <UIKit/UIKit.h>
#import "WSMsgsBean_msg.h"
NS_ASSUME_NONNULL_BEGIN

@interface WSSNInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *infoNameLab;

@property (weak, nonatomic) IBOutlet UILabel *infoContentLab;

@property (nonatomic, strong)WSMsgsBean_msg * model;

@end

NS_ASSUME_NONNULL_END
