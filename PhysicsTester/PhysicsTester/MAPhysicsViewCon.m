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
extern const float kGravityConstant;
extern const double kMaxAccelerationConstant;
extern const NSString *kSavedSettings;






@interface MAPhysicsViewCon () {

        
    // Timing
    NSDate *touchTimeStart;
    NSDate *touchTimeEnd;
    NSTimeInterval lastFrameDisplayStamp, deltaTime;
    
    
    // Display Link ref
    CADisplayLink *_displayLink;

    
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

    // Other labels
    UILabel *speedLabelPlain;

}

@property (strong) MAPhysicalObject *object;


@end




const float kAccelerationConstant =     0.0225;
const float kSpeedConstant =            1.1;
const float kMaxSpeedConstant =         10.5;
const float kGravityConstant =          2.98;
const double kMaxAccelerationConstant = 1.0;

const NSString *kSavedSettings = @"lastWorldSettings";



@implementation MAPhysicsViewCon

@synthesize object, velocityYLabel, accelerationLabel, speedLabel, gravityLabel, elasticityLabel, angleLabel;
@synthesize accelerationSlider, gravitySlider, elasticitySlider, angleSlider, speedSlider;
@synthesize playPause, gravityROCTextField, baseAccelerationTextField, realSpeedLabel, realSpeedSlider;




#pragma mark -
#pragma mark Init
- (id)init {
    
    if ( self = [super init] ) {
        
        
        object = [[MAPhysicalObject alloc] initWithImage:[UIImage imageNamed:@"Rapture_Records_logo"]];
        object.frame = CGRectMake(100, 400, 100, 100);
        
        [self.view addSubview:object];
        
        
        [self addSliderView];
        
        [self loadLastValues];
        [self setScreenRects];
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


- (void)setup {
    
    // Just for setting things up after we've 
    // been initialized

    // Keep a reference to this for timing purposes
    _displayLink = [(MAAppDelegate *)[[UIApplication sharedApplication] delegate] displayLink];

}











#pragma mark -
#pragma mark App State
- (void)appIsEnding:(NSNotification *)notification {
    
    [self saveCurrentSettings];
}

- (void)appIsResuming: (NSNotification *)notification {
    
    [self loadLastValues];
}






#pragma mark -
#pragma mark Settings
- (IBAction)ibActionSaveCurrentSettings:(id)sender {
    
    [self saveCurrentSettings];
}

- (IBAction)deleteSavedSettings: (id)sender {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:(NSString *)kSavedSettings];
    
    LogMe(@"Removed saved settings success: %d.", [[NSUserDefaults standardUserDefaults] synchronize]);
    
}

- (int)saveCurrentSettings {
    
    // Wrap last settings
    void *ptr = (void*)malloc(sizeof(WorldSettings));
    ptr = &worldSettings;
    
    WorldSettings *ptrToSettings = (WorldSettings *)ptr;
    //    WorldSettings theSettings = *ptrToSettings;
    
    NSData *dataWithWorldSettings = [NSData dataWithBytes:ptrToSettings length:sizeof(WorldSettings)];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:dataWithWorldSettings forKey:(NSString *)kSavedSettings];
    LogMe(@"Saved current settings. Success: %d", [[NSUserDefaults standardUserDefaults] synchronize]);

    return 1;
}


- (int)loadLastValues {
    
    // Unwrap
    void *ptr = (void*)malloc(sizeof(WorldSettings));
    NSData *worldSettingsAsData = [[NSUserDefaults standardUserDefaults] objectForKey:(NSString *)kSavedSettings];
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


- (void)setWorldVars {
    
    /*
     * This will set hard coded default values
     */
    
    
    // Angle
    worldSettings.angle = 270;
    
    // Acceleration
    worldSettings.acceleration = 0.000135;
    
    // Gravity
    worldSettings.gravity = 3;
    
    // Gravity ROC (Rate Of Change)
    worldSettings.gravityROC = 1.0255;
    
    // Elasticity
    worldSettings.elasticity = 2.5;
    
    // Speed
    // A base figure to determine how
    // fast to go
    worldSettings.speed = 1.1;
    
    // Real Speed
    // How fast the user is going
    worldSettings.realSpeed = 0;
    
    // Other values
    worldSettings.moving = true;
    worldSettings.falling = false;
    grounded = false;
    
}

- (void)setScreenRects {
    
    /*
     * You HAVE to call this if you want
     * screen borders.
     */
    
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
    
    
}







#pragma mark -
#pragma mark Touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    touchTimeStart = [NSDate date];
//    worldSettings.acceleration = kAccelerationConstant;
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
            accelerationLabel.text = [NSString stringWithFormat:@"Acceleration: %0.6f", currentSlider.value];
            worldSettings.acceleration = currentSlider.value;
            [accelerationLabel sizeToFit];
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
        } else if ( currentSlider.tag == 4 ) {
            // Speed
            speedLabel.text = [NSString stringWithFormat:@"Speed: %0.2f", currentSlider.value];
            worldSettings.speed = currentSlider.value;
            
        }

        
    }
}


- (IBAction)textFieldsWereUpdate:(id)sender {
    
    if ( [sender isKindOfClass:[UITextField class]] ) {
        UITextField *currentTextField = (UITextField *)sender;
        
        if ( currentTextField.tag == 0 ) {
            // Gravity ROC
            worldSettings.gravityROC = currentTextField.text.floatValue;
        } else if ( currentTextField.tag == 1 ) {
            // Acceleration base
            worldSettings.acceleration = currentTextField.text.floatValue;
        }
    
    }

}





- (void)setVarLabels {
    
    // Angle
    angleLabel.text = [NSString stringWithFormat:@"Angle: %0.2f", worldSettings.angle];
    angleSlider.value = worldSettings.angle;

    
    // Acceleration Base
    baseAccelerationTextField.text = [NSString stringWithFormat:@"%f",worldSettings.acceleration];
    
    // Acceleration
    accelerationLabel.text = [NSString stringWithFormat:@"Acceleration: %0.6f", worldSettings.acceleration];
    accelerationSlider.value = worldSettings.acceleration;
    accelerationSlider.maximumValue = 1.0;

    // Gravity ROC
    gravityROCTextField.text = [NSString stringWithFormat:@"%0.7f", worldSettings.gravityROC];
    
    
    // Gravity
    gravityLabel.text = [NSString stringWithFormat:@"Gravity: %0.2f", worldSettings.gravity];
    gravitySlider.value = worldSettings.gravity;

    // Elasticity
    elasticityLabel.text = [NSString stringWithFormat:@"Elasticity: %0.2f", worldSettings.elasticity];
    elasticitySlider.value = worldSettings.elasticity;

    // Speed
    speedLabel.text = [NSString stringWithFormat:@"Speed: %0.2f", worldSettings.speed];
    speedSlider.value = worldSettings.speed;
    speedSlider.maximumValue = kMaxSpeedConstant;

    // VelocityY
    velocityYLabel = [[UILabel alloc] initWithFrame:CGRectMake(150,924, 150, 50)];
    [velocityYLabel setText:[NSString stringWithFormat:@"velocity_y: %0.2f", 0.0]];
    [velocityYLabel sizeToFit];
    [self.view addSubview:velocityYLabel];

    // Speed
    speedLabelPlain = [[UILabel alloc] initWithFrame:CGRectMake(500,924, 150, 50)];
    [speedLabelPlain setText:[NSString stringWithFormat:@"speed: %0.2f", 0.0]];
    [speedLabelPlain sizeToFit];
    [self.view addSubview:speedLabelPlain];

    
}










#pragma mark -
#pragma mark Update


- (void)update {
    
    // Some timing
    deltaTime = _displayLink.timestamp - lastFrameDisplayStamp;
    lastFrameDisplayStamp = _displayLink.timestamp;
    
    
    // Delta position tracking
    object.deltaPosition = MASubtractPoints(object.frame.origin, object.lastPosition);
    object.lastPosition = object.frame.origin;
    
    
    // Angle to travel calculation
    double scale_x;
    double scale_y;
    double velocity_x = 0;
    double velocity_y = 0;

    
    scale_x = cos(DegreesToRadians(worldSettings.angle));
    scale_y = sin(DegreesToRadians(worldSettings.angle));
    
    velocity_x = worldSettings.speed * scale_x;
    velocity_y = worldSettings.speed * scale_y;
    
    
    
    // Check for ground collision
    [object setColliding: [self collisionTest]];

    
    // Upward user forces
    if ( fingerDown ) { 

        if ( worldSettings.angle != 270 ) worldSettings.angle = 270;

        // Increase speed
        if ( worldSettings.speed < kMaxSpeedConstant ) {
            worldSettings.speed += worldSettings.acceleration; 
        }
        
        // Accelerate acceleration -- heh.
        if ( worldSettings.acceleration < kMaxAccelerationConstant ) {
            worldSettings.acceleration += kAccelerationConstant;
        }
        
        // Flip gravity to default
        if ( worldSettings.gravity > kGravityConstant ) worldSettings.gravity /= worldSettings.gravityROC;
        
    } else if ( !object.collision.isColliding ) {
        
        if ( worldSettings.speed > kSpeedConstant ) {
            worldSettings.speed -= worldSettings.acceleration; 
        }
        
        // Increase gravity
        if ( worldSettings.gravity < 20 ) worldSettings.gravity *= worldSettings.gravityROC;
        
        // Flip acceleration to default
        worldSettings.acceleration = kAccelerationConstant;


    }
   
    // Get off of a stuck floor
    if ( object.collision.isColliding ) {
        
        // If no finger down, stop.
        if ( !fingerDown ) {
            
            // Check rect tag name
            if ( [[NSString stringWithCString:object.collision.rectName encoding:NSUTF8StringEncoding] isEqualToString:@"groundRect"] ) {  
                
                // Colliding with ground will just stop (for now).
                velocity_x = 0;
                velocity_y = 0;
                
            } else {
                worldSettings.speed = kSpeedConstant;
                worldSettings.gravity = kGravityConstant;
                worldSettings.angle = -270;
            }
            
        }
        
        
    } else {
        
        velocity_y += worldSettings.gravity;
    }

        
    object.frame = CGRectMake(object.frame.origin.x + velocity_x,
                              object.frame.origin.y + velocity_y,
                              object.frame.size.width,
                              object.frame.size.height);
        
    
    velocityYLabel.text = [NSString stringWithFormat:@"velocity_y: %0.2f", velocity_y];
    [velocityYLabel sizeToFit];
    speedLabelPlain.text = [NSString stringWithFormat:@"speed: %0.2f", worldSettings.speed];
    [speedLabelPlain sizeToFit];
    
    speedLabel.text = speedLabelPlain.text;
    speedSlider.value = worldSettings.speed;
    
    // Acceleration
    accelerationLabel.text = [NSString stringWithFormat:@"Acceleration: %0.6f", worldSettings.acceleration];
    accelerationSlider.value = worldSettings.acceleration;
    accelerationSlider.maximumValue = 1.0;
    
    // Gravity
    gravityLabel.text = [NSString stringWithFormat:@"Gravity: %0.2f", worldSettings.gravity];
    gravitySlider.value = worldSettings.gravity;

    // Real speed
    // Means actual velocity. Some of these vars are named poorly and
    // I'll have to deal with that later. TODO
    worldSettings.realSpeed = MADividePointByTime(object.deltaPosition, deltaTime);
    realSpeedLabel.text = [NSString stringWithFormat:@"RSpeed: %0.2f", worldSettings.realSpeed];
    realSpeedSlider.value = worldSettings.realSpeed;
    
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

- (double)distanceToFrame: (CGRect)rect {
    
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
            [object setRectName:[self nameForRectByIndex:i]];
            break;
        }

    }
    
    
    return colliding;
    
}


- (NSString *)nameForRectByIndex: (int)index {
    
    NSString *rectName;
    
    if ( index == 0 ) {
        rectName = @"groundRect";
    } else if (index == 1 ) {
        rectName = @"leftWall";
    } else if (index == 2 ) {
        rectName = @"rightWall";
    } else if (index == 3 ) {
        rectName = @"topWall";
    } else {
        rectName = @"UNK";
    }
    
    return rectName;
    
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
