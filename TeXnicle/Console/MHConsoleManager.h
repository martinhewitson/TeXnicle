//
//  MHConsoleManager.h
//  TeXnicle
//
//  Created by Martin Hewitson on 26/10/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHConsoleViewer.h"


@interface MHConsoleManager : NSObject <MHConsoleViewer> {
@private
  NSMutableSet *consoles;
}

@property (retain) NSMutableSet *consoles;

- (BOOL) registerConsole:(id<MHConsoleViewer>)aConsole;

@end
