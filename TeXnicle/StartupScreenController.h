//
//  NewProjectAssistantController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 28/1/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface StartupScreenController : NSWindowController {

	NSMutableArray *recentFiles;
	
	IBOutlet NSTableView *recentFilesTable;
		
	IBOutlet NSArrayController *recentFilesController;
  
  IBOutlet NSTextField *fileLabel;
  IBOutlet NSTextField *dateLabel;
	
	BOOL isOpen;
	
	NSRect openFrame;
}

-(IBAction)displayOrCloseWindow:(id)sender;
-(IBAction)displayWindow:(id)sender;

@property (readwrite, assign) BOOL isOpen;
@property (readwrite, assign) NSMutableArray *recentFiles;

- (IBAction) openRecentFile:(id)sender;
- (IBAction) newEmptyProject:(id)sender;
- (IBAction) openExistingDocument:(id)sender;
- (IBAction) newArticleDocument:(id)sender;
- (void) show;

- (void) updateFilepathLabel;

@end
