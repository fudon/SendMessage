//
//  FSMSGCell.h
//  SendMessage
//
//  Created by FudonFuchina on 16/5/2.
//  Copyright © 2016年 fusu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSMSGCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *overLabel;

@property (nonatomic,strong) NSDictionary    *dictionary;

@end
