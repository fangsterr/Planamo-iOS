//
//  GroupMessagesTableViewCell.h
//  Planamo
//
//  Created by Stanley Tang on 27/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupMessagesTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;

+ (NSString *)transformedValueForDate:(NSDate *)date;
+ (CGFloat)messageLabelHeightForText:(NSString *)text;

@end
