//
//  MAPhysicsViewCon.m
//  PhysicsTester
//
//  Created by Miles Alden on 7/19/12.
//  Copyright (c) 2012 Milk Drinking Cow. All rights reserved.
//

#import "MAPhysicsViewCon.h"

#import "MAPhysicalObject.h"
#import "MASliderView.h"
#import "MAAppDelegate.h"
#import "MAUtils.c"

#import <QuartzCore/QuartzCore.h>



extern const float kAccelerationConstant; 
extern const float kSpeedConstant; 
extern const float kMaxSpeedConstant; 
extern const NSString *kSavedSettings;






@interface MAPhysicsViewCon () {

        
    // Timing
    NSDate *touchTimeStart;
    NSDate *touchTimeEnd;

    
    // World
    struct WorldSettings worldSettings;
    
    
    // Objects
    CGRect sceneRects[10];
    
    // Ground
    float ground;
    CGRect groundRect;
    CGRect leftWall, rightWall, topWall;
    int grounded;
    
    // Screen
    CGRect screen;
    
    // Touches
    int fingerDown, wasFingerDown;


}

@property (strong) MAPhysicalObject *object;


@end




const float kAccelerationConstant = 0.0225;
const float kSpeedConstant = 1.1;
const float kMaxSpeedConstant = 12.5;
const NSString *kSavedSettings = @"lastWorldSettings";



@implementation MAPhysicsViewCon

@synthesize object, velocityYLabel, accelerationLabel, speedLabel, gravityLabel, elasticityLabel, angleLabel;
@synthesize accelerationSlider, gravitySlider, elasticitySlider, angleSlider;
@synthesize playPause;




#pragma mark -
#pragma mark Init
- (id)init {
    
    if ( self = [super init] ) {
        
        object = [[MAPhysicalObject alloc] initWithImage:[UIImage imageNamed:@"Rapture_Records_logo"]];
        object.frame = CGRectMake(100, 400, 100, 100);
        
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











#pragma mark -
#pragma mark App State
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





#pragma mark -
#pragma mark Touches
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





#pragma mark -
#pragma mark Controls
- (void)addSliderView {
    
    //MASliderView *sliderView = [[MASliderView alloc] initWithNibName:@"ValueSliders" bundle:[NSBundle mainBundle]];
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ValueSliders" owner:self options:nil];
    UIView *sliderView = [nib objectAtIndex:0];
    sliderView.frame = CGRectMake(768-sliderView.frame.size.width, 
                                  0, 
                                  sliderView.frame.size.width, 
                                  sliderView.frame.size.height);
    
    playPause.selected = true;
    
    [self.view addSubview:sliderView];
    
}



- (IBAction)playPause:(id)sender {
    
    MAAppDelegate *del = [[UIApplication sharedApplication] delegate];

    if ( [[del displayLink] isPaused] ) {
        // Show play symbol when paused
        playPause.selected = true;
        [del displayLink].paused = NO;
        LogMe(@"Resuming play...");
    } else {
        // Show pause symbol when playing
        playPause.selected = false;
        [del displayLink].paused = YES;
        LogMe(@"Pausing play...");
    }
    
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
    worldSettings.acceleration = 0.0035;
    accelerationLabel.text = [NSString stringWithFormat:@"acceleration: %0.2f", worldSettings.acceleration];
    accelerationSlider.value = worldSettings.acceleration;

    
    // Gravity
    worldSettings.gravity = 6;
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
    groundRect =    CGRectMake(0, ground-20, screen.size.width, 20);
    leftWall =      CGRectMake(0, 20, 20, screen.size.height);
    rightWall =     CGRectMake(screen.size.width-20, 0, 20, screen.size.height);
    topWall =       CGRectMake(0, -20, screen.size.width, 20);
    
    sceneRects[0] = groundRect;
    sceneRects[1] = leftWall;
    sceneRects[2] = rightWall;
    sceneRects[3] = topWall;
    
    grounded = false;
    
}

- (void)setVarLabels {
    
    angleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 100, 50)];
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
#pragma mark Update

// Deprecated update
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
    worldSettings.gravity += 0.001;
    
    
    // Check for ground collision
    [object setColliding: [self collisionTest]];

    
    // Upward user forces
    if ( fingerDown ) { 
        
        if ( worldSettings.speed < kMaxSpeedConstant ) {
            worldSettings.speed += worldSettings.acceleration; 
        }
        
    } else if ( object.collision.isColliding ) {
        
        if ( worldSettings.speed > kSpeedConstant ) {
            worldSettings.speed -= worldSettings.acceleration; 
        }

    }
   
    if ( object.collision.isColliding ) {
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
    [speedLabel sizeToFit];

    [self collisionTest];
}






#pragma mark -
#pragma mark Distance Calculations
- (double)distanceToPoint: (CGPoint)point {
    

    // Pythagorean theorum
    float dx=object.frame.origin.x - point.x;
    float dy=object.frame.origin.y - point.y;
    float distance =   quickSqrt(  (dx*dx) + (dy*dy) );    
        
    return distance;
}

- (double)distanceToObject: (CGRect)rect {
    
    // Convienience method
    return [self distanceToPoint:MARectGetCenter(rect)];
    
}






#pragma mark -
#pragma mark Collision Testing
- (int)collisionTest {
    
    // Should iterate through all objects in scene
    
    int colliding = false;
    
    for (int i = 0; i < 10; i++) {
        
        if ( [self areaCollisionTest:object.frame obj2:sceneRects[i]] ) {
            colliding = true;
        }

    }
    
    
    return colliding;
    
}

- (int)areaCollisionTest: (CGRect)object1 obj2: (CGRect) object2 {
    
    // Object-to-object bounding-box collision detector:
    
    int left1, left2;
    int right1, right2;
    int top1, top2;
    int bottom1, bottom2;
    
    left1 = object1.origin.x;
    left2 = object2.origin.x;
    right1 = object1.origin.x + object1.size.width;
    right2 = object2.origin.x + object2.size.width;
    top1 = object1.origin.y;
    top2 = object2.origin.y;
    bottom1 = object1.origin.y + object1.size.height;
    bottom2 = object2.origin.y + object2.size.height;
    
    if (bottom1 < top2) return(0);
    if (top1 > bottom2) return(0);
    
    if (right1 < left2) return(0);
    if (left1 > right2) return(0);
    
    // Just log once.
    if ( !object.collision.isColliding ) {
        LogMe(@"Collision!");
    }
    return(1);
        
    
}





@end
