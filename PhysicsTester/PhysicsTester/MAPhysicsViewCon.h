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

typedef struct Collision {
    
    double obj1_mass;
    double obj1_angle;
    double obj1_speed;
    float  obj1_elasticity;
    
    double obj2_mass;
    double obj2_angle;
    double obj2_speed;
    float  obj2_elasticity;
    
    
} Collision;


typedef struct WorldSettings {
    
    double angle;
    double speed;
    double acceleration;
    double maxAcceleration;
    double gravity;
    int moving;
    int falling;
    float elasticity;
    
    
} WorldSettings;

@interface MAPhysicsViewCon : UIViewController 


    
@property (strong) IBOutlet UILabel *velocityYLabel, *accelerationLabel, *speedLabel, *gravityLabel, *elasticityLabel, *angleLabel;
@property (strong) IBOutlet UISlider *accelerationSlider, *gravitySlider, *elasticitySlider, *angleSlider;


- (int)loadLastValues;



@end
