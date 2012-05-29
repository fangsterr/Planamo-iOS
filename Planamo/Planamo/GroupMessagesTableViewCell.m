//
//  GroupMessagesTableViewCell.m
//  Planamo
//
//  Created by Stanley Tang on 27/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "GroupMessagesTableViewCell.h"

#define kMessageFont    [UIFont systemFontOfSize:14.0]
#define kMinimumHeight  21.0f

@implementation GroupMessagesTableViewCell

@synthesize nameLabel, messageLabel, dateLabel;

+ (NSString *)transformedValueForDate:(NSDate *)date
{
    // Initialize the formatter.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    
    // Initialize the calendar and flags.
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Create reference date for supplied date.
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    NSDate *suppliedDate = [calendar dateFromComponents:comps];
    
    // Iterate through the eight days (tomorrow, today, and the last six).
    int i;
    for (i = -1; i < 7; i++)
    {
        // Initialize reference date.
        comps = [calendar components:unitFlags fromDate:[NSDate date]];
        [comps setHour:0];
        [comps setMinute:0];
        [comps setSecond:0];
        [comps setDay:[comps day] - i];
        NSDate *referenceDate = [calendar dateFromComponents:comps];
        // Get week day (starts at 1).
        int weekday = [[calendar components:unitFlags fromDate:referenceDate] weekday] - 1;
        
        if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == -1)
        {
            // Tomorrow
            return [NSString stringWithString:@"Tomorrow"];
        }
        else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 0)
        {
            // Today's time (a la iPhone Mail)
            [formatter setDateStyle:NSDateFormatterNoStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            return [formatter stringFromDate:date];
        }
        else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 1)
        {
            // Today
            return [NSString stringWithString:@"Yesterday"];
        }
        else if ([suppliedDate compare:referenceDate] == NSOrderedSame)
        {
            // Day of the week
            NSString *day = [[formatter weekdaySymbols] objectAtIndex:weekday];
            return day;
        }
    }
    
    // It's not in those eight days.
    NSString *defaultDate = [formatter stringFromDate:date];
    return defaultDate;
}


+ (CGFloat)messageLabelHeightForText:(NSString *)text {
    CGSize maxSize = CGSizeMake(270.0f, 1000.0f);
    CGFloat height = [text sizeWithFont:kMessageFont constrainedToSize:maxSize lineBreakMode:UILineBreakModeWordWrap].height;
    if (height > kMinimumHeight) return height;
    return kMinimumHeight;
}


@end
