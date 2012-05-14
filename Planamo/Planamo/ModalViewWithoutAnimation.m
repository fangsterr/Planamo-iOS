//
//  ModalViewWithoutAnimation.m
//  Planamo
//
//  Created by Stanley Tang on 13/05/2012.
//  Copyright (c) 2012 Planamo. All rights reserved.
//

#import "ModalViewWithoutAnimation.h"

@implementation ModalViewWithoutAnimation

- (void)perform {
    [self.sourceViewController presentModalViewController:self.destinationViewController animated:NO]; 
}

@end
