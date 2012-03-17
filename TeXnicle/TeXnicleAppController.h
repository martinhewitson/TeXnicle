//
//  TeXnicleAppController.h
//  TeXnicle
//
//  Created by hewitson on 26/5/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StartupScreenController;

@interface TeXnicleAppController : NSObject <NSApplicationDelegate> {
@private
	StartupScreenController *startupScreenController;    
  BOOL openStartupScreenAtAppStartup;
  NSInteger lineToOpen;
}

@property (assign) BOOL openStartupScreenAtAppStartup;

- (void) checkVersion;

- (IBAction)showPreferences:(id)sender;
- (id)startupScreen;
- (IBAction) showStartupScreen:(id)sender;

#pragma mark -
#pragma mark Document Control 

- (IBAction)createProjectFromTemplate:(id)sender;
- (IBAction) newEmptyProject:(id)sender;
- (IBAction) newArticleDocument:(id)sender;
- (IBAction)buildProject:(id)sender;
- (IBAction) newLaTeXFile:(id)sender;

@end
