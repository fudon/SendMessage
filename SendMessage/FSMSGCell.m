//
//  FSMSGCell.m
//  SendMessage
//
//  Created by FudonFuchina on 16/5/2.
//  Copyright © 2016年 fusu. All rights reserved.
//

#import "FSMSGCell.h"
#import "FuData.h"

@implementation FSMSGCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDictionary:(NSDictionary *)dictionary
{
    if (_dictionary != dictionary) {
        _dictionary = dictionary;
        
        self.nameLabel.text = [dictionary objectForKey:@"account"];
        self.codeLabel.text = [dictionary objectForKey:@"code"];
        self.typeLabel.text = [self types:[dictionary objectForKey:@"type"]];
        
        NSString *time = [dictionary objectForKey:@"time"];
        NSTimeInterval timeInterval = [time doubleValue] / 1000;
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:timeInterval];
        NSString *dateString = [FuData stringByDate:date];
        self.timeLabel.text = dateString;
        
        NSTimeInterval over = ([[dictionary objectForKey:@"validity"] doubleValue] / 1000 + timeInterval);
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        if (over - now >= 0) {
            self.overLabel.text = [[NSString alloc] initWithFormat:@"还剩%@",[FuData easySeeTimesBySeconds:over - now]];
        }else{
            self.overLabel.text = [[NSString alloc] initWithFormat:@"已过期%@",[FuData easySeeTimesBySeconds:now - over]];
        }
    }
}

- (NSString *)types:(NSString *)type
{
    NSArray *types = @[@"未知",@"注册类",@"其他"];
    return types[[type integerValue] % types.count];
}

@end
