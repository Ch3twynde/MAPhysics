//
//  MAStructs.h
//  PhysicsTester
//
//  Created by Miles Alden on 7/22/12.
//  Copyright (c) 2012 Milk Drinking Cow. All rights reserved.
//

#ifndef PhysicsTester_MAStructs_h
#define PhysicsTester_MAStructs_h


typedef struct Collision {
    
    
    double  objectMass;
    double  objectAngle;
    double  objectSpeed;
    float   objectElasticity;
    int     bouncing;
    int     isColliding;
    const char   *rectName;
    
} Collision;


typedef struct WorldSettings {
    
    double angle;
    double speed;
    double realSpeed;
    double acceleration;
    double gravity;
    double gravityROC;
    double gravityBase;
    int moving;
    int falling;
    float elasticity;

    
    
} WorldSettings;

#endif
