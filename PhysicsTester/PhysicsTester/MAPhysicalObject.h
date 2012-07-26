//
//  MAPhysicalObject.h
//  PhysicsTester
//
//  Created by Miles Alden on 7/21/12.
//  Copyright (c) 2012 Milk Drinking Cow. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "MAStructs.h"


@interface MAPhysicalObject : UIImageView

    
@property CGPoint deltaPosition;
@property CGPoint lastPosition;
@property struct Collision collision;


- (void)setColliding: (int)_isColliding;
- (void)setRectName: (NSString *)name;
- (void)setBouncing: (int)_isBouncing;



@end
