    //
//  MAControlPanelViewCon.m
//  PhysicsTester
//
//  Created by Miles Alden on 7/25/12.
//  Copyright (c) 2012 Milk Drinking Cow. All rights reserved.
//

#import "MAControlPanelViewCon.h"

@implementation MAControlPanelViewCon
@synthesize onScreen;


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if  ( !onScreen ) {
        
        CGRect screen = [[UIScreen mainScreen] bounds];
            
        [UIView animateWithDuration:0.25 
                              delay:0 
                            options:UIViewAnimationCurveEaseIn 
                         animations:^{
                                self.view.frame = CGRectMake(screen.size.width - self.view.frame.size.width,
                                                             0,
                                                             self.view.frame.size.width,
                                                             self.view.frame.size.height); } 
                         completion:NULL];
        onScreen = true;
        
    }     
}

- (void)dismissControlPanel {
        
        CGRect screen = [[UIScreen mainScreen] bounds];
        
        [UIView animateWithDuration:0.25 
                              delay:0 
                            options:UIViewAnimationCurveEaseIn 
                         animations:^{
                             self.view.frame = CGRectMake(screen.size.width - 15,
                                                          0,
                                                          self.view.frame.size.width,
                                                          self.view.frame.size.height); } 
                         completion:NULL];
        onScreen = false;

}


@end
