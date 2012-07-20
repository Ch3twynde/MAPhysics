//
//  MAPhysicsViewCon.m
//  PhysicsTester
//
//  Created by Miles Alden on 7/19/12.
//  Copyright (c) 2012 Milk Drinking Cow. All rights reserved.
//

#import "MAPhysicsViewCon.h"
#import "MASliderView.h"

extern const float kAccelerationConstant; 
extern const float kSpeedConstant; 
extern const float kMaxSpeedConstant; 
extern const NSString *kSavedSettings;




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


@end




const float kAccelerationConstant = 0.0125;
const float kSpeedConstant = 1.1;
const float kMaxSpeedConstant = 12.5;
const NSString *kSavedSettings = @"lastWorldSettings";

@implementation MAPhysicsViewCon

@synthesize object, velocityYLabel, accelerationLabel, speedLabel, gravityLabel, elasticityLabel, angleLabel;
@synthesize accelerationSlider, gravitySlider, elasticitySlider, angleSlider;


- (id)init {
    
    if ( self = [super init] ) {
        
        object = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Rapture_Records_logo"]];
        object.frame = CGRectMake(20, 400, 100, 100);
        
        [self.view addSubview:object];
        
        
        [self addSliderView];
        
        [self loadLastValues];
        [self setVarLabels];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(appIsEnding:) 
                                                     name:UIApplicationDidEnterBackgroundNotification 
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(appIsResuming:) 
                                                     name:UIApplicationDidEnterBackgroundNotification 
                                                   object:nil];

        
    }
    
    return self;
}

- (void)addSliderView {
    
   //MASliderView *sliderView = [[MASliderView alloc] initWithNibName:@"ValueSliders" bundle:[NSBundle mainBundle]];
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ValueSliders" owner:self options:nil];
    UIView *sliderView = [nib objectAtIndex:0];
    sliderView.frame = CGRectMake(768-sliderView.frame.size.width, 
                                  0, 
                                  sliderView.frame.size.width, 
                                  sliderView.frame.size.height);
    
    [self.view addSubview:sliderView];
    
}

- (void)appIsEnding:(NSNotification *)notification {
    
    // Wrap last settings
    void *ptr = (void*)malloc(sizeof(WorldSettings));
    ptr = &worldSettings;
    
    WorldSettings *ptrToSettings = (WorldSettings *)ptr;
//    WorldSettings theSettings = *ptrToSettings;
    
    NSData *dataWithWorldSettings = [NSData dataWithBytes:ptrToSettings length:sizeof(WorldSettings)];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:dataWithWorldSettings forKey:@"lastWorldSettings"];
    LogMe(@"Saved current settings.");
}

- (void)appIsResuming: (NSNotification *)notification {
    
    [self loadLastValues];
}


- (int)loadLastValues {
    
    // Unwrap
    void *ptr = (void*)malloc(sizeof(WorldSettings));
    NSData *worldSettingsAsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastWorldSettings"];
    if ( worldSettingsAsData ) {
        ptr = (void*)[worldSettingsAsData bytes];
        WorldSettings *ptrToSettings = (WorldSettings *)ptr;
        worldSettings = *ptrToSettings;
        LogMe(@"Loaded saved settings");
    } else {
        LogMe(@"Starting with default settings");
        [self setWorldVars];
    }
    
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


- (IBAction)slidersWereUpdated: (id)sender {
    
    if ( [sender isKindOfClass:[UISlider class]] ) {
        UISlider *currentSlider = (UISlider *)sender;
        
        if ( currentSlider.tag == 0 ) {
            // Acceleration
            accelerationLabel.text = [NSString stringWithFormat:@"Acceleration: %0.4f", currentSlider.value];
            worldSettings.acceleration = currentSlider.value;
        } else if ( currentSlider.tag == 1 ) {
            // Gravity
            gravityLabel.text = [NSString stringWithFormat:@"Gravity: %0.2f", currentSlider.value];
            worldSettings.gravity = currentSlider.value;
        } else if ( currentSlider.tag == 2 ) {
            // Elasticity
            elasticityLabel.text = [NSString stringWithFormat:@"Elasticity: %0.2f", currentSlider.value];
            worldSettings.elasticity = currentSlider.value;
        } else if ( currentSlider.tag == 3 ) {
            // Angle
            angleLabel.text = [NSString stringWithFormat:@"Angle: %0.2f", currentSlider.value];
            worldSettings.angle = currentSlider.value;
        }
        
    }
}


- (void)setWorldVars {
    
    // Angle
    worldSettings.angle = 270;
    angleLabel.text = [NSString stringWithFormat:@"Angle: %0.2f", worldSettings.angle];
    angleSlider.value = worldSettings.angle;
    
    
    // Acceleration
    worldSettings.acceleration = 0.0025;
    accelerationLabel.text = [NSString stringWithFormat:@"acceleration: %0.2f", worldSettings.acceleration];
    accelerationSlider.value = worldSettings.acceleration;

    
    // Gravity
    worldSettings.gravity = 4;
    gravityLabel.text = [NSString stringWithFormat:@"gravity: %0.2f", worldSettings.gravity];
    gravitySlider.value = worldSettings.gravity;

    
    // Elasticity
    worldSettings.elasticity = 2.5;
    elasticityLabel.text = [NSString stringWithFormat:@"elasticity: %0.2f", worldSettings.elasticity];
    elasticitySlider.value = worldSettings.elasticity;

    
    
    // Other values
    worldSettings.speed = 1.1;
    worldSettings.maxAcceleration = 0.15;
    worldSettings.moving = true;
    worldSettings.falling = false;

    screen = [[UIScreen mainScreen] bounds];
    ground = self.view.frame.origin.y + self.view.frame.size.height;
    groundRect = CGRectMake(0, ground-20, screen.size.width, 20);
    grounded = false;
    
}

- (void)setVarLabels {
    
    UILabel *angleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 100, 50)];
    [angleLabel setText:[NSString stringWithFormat:@"angle: %f", worldSettings.angle]];
    
    velocityYLabel = [[UILabel alloc] initWithFrame:CGRectMake(150,924, 150, 50)];
    [velocityYLabel setText:[NSString stringWithFormat:@"velocity_y: %0.2f", 0.0]];
    [velocityYLabel sizeToFit];
    [self.view addSubview:velocityYLabel];
    
//    accelerationLabel = [[UILabel alloc] initWithFrame:CGRectMake(350,924, 150, 50)];
//    [accelerationLabel setText:[NSString stringWithFormat:@"acceleration: %0.2f", 0.0]];
//    [accelerationLabel sizeToFit];
//    [self.view addSubview:accelerationLabel];
    
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
        
        if ( worldSettings.acceleration < worldSettings.maxAcceleration ) {
            worldSettings.acceleration += kAccelerationConstant;
        }
    }
    
    
    if ( !worldSettings.falling && fingerDown ) {
        
        scale_x = cos(DegreesToRadians(worldSettings.angle));
        scale_y = sin(DegreesToRadians(worldSettings.angle));
        
        velocity_x = worldSettings.speed * scale_x;
        velocity_y = worldSettings.speed * scale_y + worldSettings.gravity;
        
        object.frame = CGRectMake(object.frame.origin.x + velocity_x,
                                  object.frame.origin.y + velocity_y,
                                  object.frame.size.width,
                                  object.frame.size.height);
        
        worldSettings.speed += worldSettings.acceleration;
        
    } else if ( worldSettings.moving ) {
        
        worldSettings.falling = true;
        velocity_y = velocity_y + worldSettings.gravity;
        
        if ( (object.frame.origin.y+object.frame.size.height) - velocity_y < ground - 50 ) {
            
            object.frame = CGRectMake(object.frame.origin.x,
                                      object.frame.origin.y + velocity_y,
                                      object.frame.size.width,
                                      object.frame.size.height);
            
            worldSettings.gravity += 0.5;
        } else {
            
            worldSettings.gravity = 0;
            velocity_y = velocity_y * worldSettings.elasticity;
            
            object.frame = CGRectMake(object.frame.origin.x,
                                      object.frame.origin.y - velocity_y,
                                      object.frame.size.width,
                                      object.frame.size.height);
            worldSettings.elasticity /= 2;
            
        }
        
    }
    
    velocityYLabel.text = [NSString stringWithFormat:@"velocity_y: %0.2f", velocity_y];
    
    
}

- (void)substituteUpdate {
    
    
    
    double scale_x;
    double scale_y;
    double velocity_x = 0;
    double velocity_y = 0;

    
    scale_x = cos(DegreesToRadians(worldSettings.angle));
    scale_y = sin(DegreesToRadians(worldSettings.angle));
    
    velocity_x = worldSettings.speed * scale_x;
    velocity_y = worldSettings.speed * scale_y + worldSettings.gravity;
    
    // Check for ground collision
    bool isGrounded = [self collisionTest];

    
    // Upward user forces
    if ( fingerDown ) { 
        
        if ( worldSettings.speed < kMaxSpeedConstant ) {
            worldSettings.speed += worldSettings.acceleration; 
        }
        
    } else if ( !isGrounded ) {
        
        if ( worldSettings.speed > kSpeedConstant ) {
            worldSettings.speed -= worldSettings.acceleration; 
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
    speedLabel.text = [NSString stringWithFormat:@"speed: %0.2f", worldSettings.speed];

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
