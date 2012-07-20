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
extern const NSString *kSavedSettings;


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


@interface MAPhysicsViewCon () {

        
    // Timing
    NSDate *touchTimeStart;
    NSDate *touchTimeEnd;

    
    // World
    WorldSettings worldSettings;

    
    // Ground
    float ground;
    CGRect groundRect;
    int grounded;
    
    // Screen
    CGRect screen;
    
    // Touches
    int fingerDown, wasFingerDown;


}

@property (strong) UIImageView *object;
@property (strong) UILabel *velocityYLabel, *accelerationLabel, *speedLabel;


@end




const float kAccelerationConstant = 0.0125;
const float kSpeedConstant = 1.1;
const float kMaxSpeedConstant = 12.5;
const NSString *kSavedSettings = @"lastWorldSettings";

@implementation MAPhysicsViewCon

@synthesize object, velocityYLabel, accelerationLabel, speedLabel;


- (id)init {
    
    if ( self = [super init] ) {
        
        object = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Rapture_Records_logo"]];
        object.frame = CGRectMake(20, 400, 100, 100);
        
        [self.view addSubview:object];
        
        [self setWorldVars];
        [self setVarLabels];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(appIsEnding:) 
                                                     name:UIApplicationDidEnterBackgroundNotification 
                                                   object:nil];
        
        
    }
    
    return self;
}

- (void)appIsEnding:(NSNotification *)notification {
    
    void *ptr = (void*)worldSettings;
    [[NSUserDefaults standardUserDefaults] setObject:[NSValue valueWithBytes:<#(const void *)#> objCType:<#(const char *)#>] forKey:@"lastWorldSettings"]
}


- (int)loadLastValues: (WorldSettings)settings {
    
    worldSettings = settings;
    [self setWorldVars];
    
    return true;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    touchTimeStart = [NSDate date];
    worldSettings.acceleration = kAccelerationConstant;
    fingerDown = true;
    wasFingerDown = false;
    worldSettings.falling = false;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    touchTimeEnd = [NSDate date];
    fingerDown = false;
    wasFingerDown = true;
}

- (void)setWorldVars {
    
    worldSettings.angle = 270;
    worldSettings.speed = 1.1;
    worldSettings.acceleration = 0.0025;
    worldSettings.maxAcceleration = 0.15;
    worldSettings.gravity = 4;
    worldSettings.moving = true;
    worldSettings.falling = false;
    worldSettings.elasticity = 2.5;

    screen = [[UIScreen mainScreen] bounds];
    ground = self.view.frame.origin.y + self.view.frame.size.height;
    groundRect = CGRectMake(0, ground-20, screen.size.width, 20);
    grounded = false;
    
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






#pragma mark -
#pragma Update
- (void)update {
    
    
    // Just for testing the other update method
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
    
    // Check for ground collision
    bool isGrounded = [self collisionTest];

    
    // Upward user forces
    if ( fingerDown ) { 
        
        if ( speed < kMaxSpeedConstant ) {
            speed += acceleration; 
        }
        
    } else if ( !isGrounded ) {
        
        if ( speed > kSpeedConstant ) {
            speed -= acceleration; 
        }

    }
   
    if ( isGrounded ) {
        if ( velocity_x > 0 ) velocity_x = 0;
        if ( velocity_y > 0 ) velocity_y = 0;
    }

        
    object.frame = CGRectMake(object.frame.origin.x + velocity_x,
                              object.frame.origin.y + velocity_y,
                              object.frame.size.width,
                              object.frame.size.height);
        
    
    velocityYLabel.text = [NSString stringWithFormat:@"velocity_y: %0.2f", velocity_y];
    [velocityYLabel sizeToFit];
    accelerationLabel.text = [NSString stringWithFormat:@"acceleration: %0.2f", acceleration];
    speedLabel.text = [NSString stringWithFormat:@"speed: %0.2f", speed];

    [self collisionTest];
}


- (int)collisionTest {
    
    // Another detection style
    float dx=object.frame.origin.x - groundRect.origin.x;
    float dy=object.frame.origin.y - groundRect.origin.y;
    float distance = dx+dy;

    if ( pow(distance, 2) < object.frame.size.height ) {
        return true;
    }
    
    //sqrt( (dx*dx) + (dy*dy) );
    
    
    // One detection style
    if (CGRectIntersectsRect(object.frame, groundRect) || 
        CGRectContainsRect(object.frame, groundRect) || 
        (CGRectContainsRect(groundRect, object.frame) ) ) {
        // they either overlap or one is inside the other
        return true;
    }    
    
    return false;
}



@end
