//
//  MAPhysicalObject.m
//  PhysicsTester
//
//  Created by Miles Alden on 7/21/12.
//  Copyright (c) 2012 Milk Drinking Cow. All rights reserved.
//

#import "MAPhysicalObject.h"

@implementation MAPhysicalObject

@synthesize collision, lastPosition, deltaPosition;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setRectName:@"None"];
    }
    return self;
}

- (void)setColliding: (int)_isColliding {
    
    collision.isColliding = _isColliding;
}

- (void)setBouncing: (int)_isBouncing {
    collision.bouncing = _isBouncing;
}

- (void)setRectName: (NSString *)name {
    
    collision.rectName = [name cStringUsingEncoding:NSUTF8StringEncoding];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
