//
//  MAPhysicsViewCon.m
//  PhysicsTester
//
//  Created by Miles Alden on 7/19/12.
//  Copyright (c) 2012 Milk Drinking Cow. All rights reserved.
//

#import "MAPhysicsViewCon.h"


extern const float kAccelerationConstant; 
extern const float kSpeedConstant; 
extern const float kMaxSpeedConstant; 


@interface MAPhysicsViewCon () {

NSDate *touchTimeStart;
NSDate *touchTimeEnd;


double angle;
double speed;
double acceleration;
double maxAcceleration;
double gravity;
int moving;
int falling;
float elasticity;

float ground;

int fingerDown;


}

@property (strong) UIImageView *object;
@property (strong) UILabel *velocityYLabel, *accelerationLabel, *speedLabel;


@end


const float kAccelerationConstant = 0.0125;
const float kSpeedConstant = 1.1;
const float kMaxSpeedConstant = 12.5;


@implementation MAPhysicsViewCon

@synthesize object, velocityYLabel, accelerationLabel, speedLabel;


- (id)init {
    
    if ( self = [super init] ) {
        
        object = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Rapture_Records_logo"]];
        object.frame = CGRectMake(20, 400, 100, 100);
        [self.view addSubview:object];
        
        [self setWorldVars];
        [self setVarLabels];
        
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    touchTimeStart = [NSDate date];
    acceleration = kAccelerationConstant;
    fingerDown = true;
    falling = false;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    touchTimeEnd = [NSDate date];
    fingerDown = false;
}

- (void)setWorldVars {
    
    angle = 270;
    speed = 1.1;
    acceleration = 0.0025;
    maxAcceleration = 0.15;
    gravity = 4;
    moving = true;
    falling = false;
    ground = self.view.frame.origin.y + self.view.frame.size.height;
    elasticity = 2.5;
}

- (void)setVarLabels {
    
    UILabel *angleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 100, 50)];
    [angleLabel setText:[NSString stringWithFormat:@"angle: %f", angle]];
    
    velocityYLabel = [[UILabel alloc] initWithFrame:CGRectMake(150,924, 150, 50)];
    [velocityYLabel setText:[NSString stringWithFormat:@"velocity_y: %0.2f", 0.0]];
    [velocityYLabel sizeToFit];
    [self.view addSubview:velocityYLabel];
    
    accelerationLabel = [[UILabel alloc] initWithFrame:CGRectMake(350,924, 150, 50)];
    [accelerationLabel setText:[NSString stringWithFormat:@"acceleration: %0.2f", 0.0]];
    [accelerationLabel sizeToFit];
    [self.view addSubview:accelerationLabel];
    
    speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(500,924, 150, 50)];
    [speedLabel setText:[NSString stringWithFormat:@"speed: %0.2f", 0.0]];
    [speedLabel sizeToFit];
    [self.view addSubview:speedLabel];

    
}


- (void)update {
    
    [self substituteUpdate];
    return;
    
    double scale_x;
    double scale_y;
    double velocity_x = 0;
    double velocity_y = 0;
    
    
    // User touches screen to make object
    // rise
    if ( fingerDown ) {
        
        if ( acceleration < maxAcceleration ) {
            acceleration += kAccelerationConstant;
        }
    }
    
    
    if ( !falling && fingerDown ) {
        
        scale_x = cos(DegreesToRadians(angle));
        scale_y = sin(DegreesToRadians(angle));
        
        velocity_x = speed * scale_x;
        velocity_y = speed * scale_y + gravity;
        
        object.frame = CGRectMake(object.frame.origin.x + velocity_x,
                                  object.frame.origin.y + velocity_y,
                                  object.frame.size.width,
                                  object.frame.size.height);
        
        speed += acceleration;
        
    } else if ( moving ) {
        
        falling = true;
        velocity_y = velocity_y + gravity;
        
        if ( (object.frame.origin.y+object.frame.size.height) - velocity_y < ground - 50 ) {
            
            object.frame = CGRectMake(object.frame.origin.x,
                                      object.frame.origin.y + velocity_y,
                                      object.frame.size.width,
                                      object.frame.size.height);
            
            gravity += 0.5;
        } else {
            
            gravity = 0;
            velocity_y = velocity_y * elasticity;
            
            object.frame = CGRectMake(object.frame.origin.x,
                                      object.frame.origin.y - velocity_y,
                                      object.frame.size.width,
                                      object.frame.size.height);
            elasticity /= 2;
            
        }
        
    }
    
    velocityYLabel.text = [NSString stringWithFormat:@"velocity_y: %0.2f", velocity_y];
    accelerationLabel.text = [NSString stringWithFormat:@"acceleration: %0.2f", acceleration];
    
    
}

- (void)substituteUpdate {
    
    double scale_x;
    double scale_y;
    double velocity_x = 0;
    double velocity_y = 0;

    
        
        scale_x = cos(DegreesToRadians(angle));
        scale_y = sin(DegreesToRadians(angle));
        
        velocity_x = speed * scale_x;
        velocity_y = speed * scale_y + gravity;
        
        object.frame = CGRectMake(object.frame.origin.x + velocity_x,
                                  object.frame.origin.y + velocity_y,
                                  object.frame.size.width,
                                  object.frame.size.height);
        
    if ( fingerDown ) { 
        
        if ( speed < kMaxSpeedConstant ) {
            speed += acceleration; 
        }
        
    } else {
        if ( speed > kSpeedConstant ) {
            speed -= acceleration;
        }
    }

    velocityYLabel.text = [NSString stringWithFormat:@"velocity_y: %0.2f", velocity_y];
    accelerationLabel.text = [NSString stringWithFormat:@"acceleration: %0.2f", acceleration];
    speedLabel.text = [NSString stringWithFormat:@"speed: %0.2f", speed];

}

@end
