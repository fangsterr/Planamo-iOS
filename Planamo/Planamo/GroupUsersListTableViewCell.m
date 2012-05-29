//
//  GroupUsersListTableViewCell.m
//  Planamo
//
//  Created by Stanley Tang on 14/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "GroupUsersListTableViewCell.h"

@implementation GroupUsersListTableViewCell

@synthesize nameLabel = _nameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


/* Custom "indentation" of organizer label, to counteract the indentation from editing mode,
   so it appears that the organizer label doesn't indent 
 
    maybe can be used for "YOU" label
 */
- (void)layoutSubviews {
    [super layoutSubviews];
    
  /*  if (self.organizerLabel.hidden == NO) {
        if (self.editing) {
            [UIView animateWithDuration:0.5 animations:^{
                CGRect frame=self.organizerLabel.frame;
                frame.origin.x=219;
                self.organizerLabel.frame=frame;
            }];
        } else if (!self.editing) {
            [UIView animateWithDuration:0.5 animations:^{
                CGRect frame=self.organizerLabel.frame;
                frame.origin.x=251;
                self.organizerLabel.frame=frame;
            }];
        }
    } */
}


@end
