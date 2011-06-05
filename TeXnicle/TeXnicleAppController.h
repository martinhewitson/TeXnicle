//
//  TeXnicleAppController.h
//  TeXnicle
//
//  Created by hewitson on 26/5/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import <Foundation/Foundation.h>

@class StartupScreenController;

@interface TeXnicleAppController : NSObject {
@private
	StartupScreenController *startupScreenController;    
}

- (IBAction)showPreferences:(id)sender;
- (id)startupScreen;
- (IBAction) showStartupScreen:(id)sender;

#pragma mark -
#pragma mark Document Control 


- (IBAction) newLaTeXFile:(id)sender;

@end
