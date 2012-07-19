//
//  MAAppDelegate.m
//  PhysicsTester
//
//  Created by Miles Alden on 7/18/12.
//  Copyright (c) 2012 Milk Drinking Cow. All rights reserved.
//

#define PI 3.14159
#define DegreesToRadians(x) x * (PI / 180)
#define LogMe(fmt, ...) NSLog((@"%s [line: %d] " fmt ), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__) 

#import "MAAppDelegate.h"
#import <QuartzCore/QuartzCore.h>


extern const float kAccelerationConstant; 
extern const float kSpeedConstant; 


@interface PhysicsViewCon : UIViewController {
    
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
@property (strong) UILabel *velocityYLabel, *accelerationLabel;
 

@end


const float kAccelerationConstant = 0.0125;
const float kSpeedConstant = 1.1;


@implementation PhysicsViewCon

@synthesize object, velocityYLabel, accelerationLabel;


- (id)init {
    
    if ( self = [super init] ) {
        
        object = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Rapture_Records_logo"]];
        object.frame = CGRectMake(20, 900, 100, 100);
        [self.view addSubview:object];
        
        [self setWorldVars];
        [self setVarLabels];

    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    touchTimeStart = [NSDate date];
    acceleration = kAccelerationConstant;
    speed = kSpeedConstant;
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
    acceleration = 0.0125;
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
    
    velocityYLabel = [[UILabel alloc] initWithFrame:CGRectMake(150,924, 100, 50)];
    [velocityYLabel setText:[NSString stringWithFormat:@"velocity_y: %0.2f", 0.0]];
    [velocityYLabel sizeToFit];
    [self.view addSubview:velocityYLabel];
    
    accelerationLabel = [[UILabel alloc] initWithFrame:CGRectMake(300,924, 100, 50)];
    [accelerationLabel setText:[NSString stringWithFormat:@"acceleration: %0.2f", 0.0]];
    [accelerationLabel sizeToFit];
    [self.view addSubview:accelerationLabel];

    
}


- (void)update {
    
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


@end








@interface MAAppDelegate () {
    

}

@end

@implementation MAAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    PhysicsViewCon *theViewController = [[PhysicsViewCon alloc] init];
    theViewController.view.frame = [[UIScreen mainScreen] bounds];
    self.window.rootViewController = theViewController;
    

    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:theViewController selector:@selector(update)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PhysicsTester" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PhysicsTester.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
