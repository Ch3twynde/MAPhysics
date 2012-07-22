//
//  MAArrayChecker.m
//  PhysicsTester
//
//  Created by Miles Alden on 7/21/12.
//  Copyright (c) 2012 Milk Drinking Cow. All rights reserved.
//

#import "MAArrayChecker.h"

@implementation MAArrayChecker

+ (int)containsAnyItem: (void *)arrayPtr dataType:(NSString *)dataType {
        
    // Find if any of the array are true
    int someIntArray[5] = {0,0,1,0,0};    
    int returnValue;   
    
    for ( int i = 0; i < 5; i++ ) {
        
        if ( someIntArray[i] ) { returnValue = true; }
        
    }
    
    return returnValue;
    
}

@end
