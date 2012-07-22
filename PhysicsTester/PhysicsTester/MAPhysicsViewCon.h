//
//  MAPhysicsViewCon.h
//  PhysicsTester
//
//  Created by Miles Alden on 7/19/12.
//  Copyright (c) 2012 Milk Drinking Cow. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PI 3.14159
#define DegreesToRadians(x) x * (PI / 180)
#define LogMe(fmt, ...) NSLog((@"%s [line: %d] " fmt ), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__) 


@interface MAPhysicsViewCon : UIViewController 


    
@property (strong) IBOutlet UILabel *velocityYLabel, *accelerationLabel, *speedLabel, *gravityLabel, *elasticityLabel, *angleLabel, *realSpeedLabel;
@property (strong) IBOutlet UISlider *accelerationSlider, *gravitySlider, *elasticitySlider, *angleSlider, *speedSlider, *realSpeedSlider;
@property (strong) IBOutlet UIButton *playPause;
@property (strong) IBOutlet UITextField *gravityROCTextField, *baseAccelerationTextField;

- (int)loadLastValues;
- (void)setup;




@end
