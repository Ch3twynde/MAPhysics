//
//  MAUtils.h
//  PhysicsTester
//
//  Created by Miles Alden on 7/22/12.
//  Copyright (c) 2012 Milk Drinking Cow. All rights reserved.
//

#ifndef PhysicsTester_MAUtils_h
#define PhysicsTester_MAUtils_h


float quickSqrt( float number )
{
    long i;
    float x2, y;
    const float threehalfs = 1.5F;
    
    x2 = number * 0.5F;
    y  = number;
    i  = * ( long * ) &y;                       // evil floating point bit level hacking
    i  = 0x5f3759df - ( i >> 1 );               // what the fuck?
    y  = * ( float * ) &i;
    y  = y * ( threehalfs - ( x2 * y * y ) );   // 1st iteration
    //      y  = y * ( threehalfs - ( x2 * y * y ) );   // 2nd iteration, this can be removed
    
    return y*number; // y * number = squareRoot.
}

CGPoint MARectGetCenter (CGRect rect) {
    
    return CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
}

#endif
