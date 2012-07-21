//
//  MAAppDelegate.h
//  PhysicsTester
//
//  Created by Miles Alden on 7/18/12.
//  Copyright (c) 2012 Milk Drinking Cow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong) CADisplayLink *displayLink;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
