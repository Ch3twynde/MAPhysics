//
//  main.m
//  PhysicsTester
//
//  Created by Miles Alden on 7/18/12.
//  Copyright (c) 2012 Milk Drinking Cow. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MAAppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        
        setenv("XcodeColors", "YES", 0); // Enables XcodeColors (you obviously have to install it too)

        return UIApplicationMain(argc, argv, nil, NSStringFromClass([MAAppDelegate class]));
    }
}
