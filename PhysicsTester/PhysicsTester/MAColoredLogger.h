//
//  MAColoredLogger.h
//  UICatalog
//
//  Created by Miles Alden on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Logging.h"

#define XCODE_COLORS_ESCAPE_MAC @"\033["
#define XCODE_COLORS_ESCAPE_IOS @"\xC2\xA0["



//#if ( !TARGET_IPHONE_SIMULATOR )
//#define XCODE_COLORS_ESCAPE  XCODE_COLORS_ESCAPE_IOS
//#endif

#if ( TARGET_OS_MAC )
#define XCODE_COLORS_ESCAPE  XCODE_COLORS_ESCAPE_MAC
#endif

//#define XCODE_COLORS_ESCAPE XCODE_COLORS_ESCAPE_MAC

#define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE @"fg;" // Clear any foreground color
#define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE @"bg;" // Clear any background color
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color

//    NSLog(XCODE_COLORS_ESCAPE @"fg0,0,255;" @"Blue text" XCODE_COLORS_RESET);

//@"Blue text" @"\xC2\xA0[" @";"
#define RED XCODE_COLORS_ESCAPE @"fg150,0,0;"
#define BLUE XCODE_COLORS_ESCAPE @"fg0,0,150;"
#define GREEN XCODE_COLORS_ESCAPE @"fg0,150,0;"
#define FLIP XCODE_COLORS_RESET

// NSLog(RED @"Red text" FLIP);

#ifdef DEBUG
//#define LogMe(fmt, ...) NSLog(@"[%@ %@] (Line: %d) %@", [self class], NSStringFromSelector(_cmd), __LINE__, [NSString stringWithFormat:(fmt), ##__VA_ARGS__] )
#define LogMeColored(x,fmt,...) NSLog( x @"[%@ %@] (Line: %d) %@" FLIP , [self class], NSStringFromSelector(_cmd), __LINE__, [NSString stringWithFormat:(fmt), ##__VA_ARGS__] )
#endif

@interface MAColoredLogger : NSObject

@end
