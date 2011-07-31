//
//  NewProjectAssistantController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 28/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TPDescriptionView;

@interface StartupScreenController : NSWindowController <NSMetadataQueryDelegate> {
  
  IBOutlet TPDescriptionView *emptyProjectDescription;
  IBOutlet TPDescriptionView *newArticleDescription;
  IBOutlet TPDescriptionView *buildProjectDescription;
  
  IBOutlet NSView *containerView;
  IBOutlet NSView *startView;
  IBOutlet NSView *buildView;
  IBOutlet NSButton *bottomBarButton;
  
	NSMutableArray *recentFiles;
	
	IBOutlet NSTableView *recentFilesTable;
		
	IBOutlet NSArrayController *recentFilesController;
  
  IBOutlet TPDescriptionView *fileLabel;
  IBOutlet NSTextField *dateLabel;
  
  IBOutlet NSButton *recentBtn;
  IBOutlet NSButton *allBtn;
  
	NSMetadataQuery* query;
  NSMutableArray *texnicleFiles;
  
	BOOL isOpen;
	
	NSRect openFrame;
}

-(IBAction)displayOrCloseWindow:(id)sender;
-(IBAction)displayWindow:(id)sender;

@property (readwrite, assign) BOOL isOpen;
@property (readwrite, assign) NSMutableArray *recentFiles;

- (IBAction) openRecentFile:(id)sender;

- (IBAction) newProject:(id)sender;
- (IBAction)cancelNewProject:(id)sender;

- (IBAction) buildProject:(id)sender;
- (IBAction) newEmptyProject:(id)sender;
- (IBAction) openExistingDocument:(id)sender;
- (IBAction) newArticleDocument:(id)sender;
- (void) show;

- (void) updateFilepathLabel;

#pragma mark -
#pragma File selection

- (IBAction)startFileQuery:(id)sender;
- (IBAction) fileSourceChanged:(id)sender;
- (void)loadFilesFromQueryResult:(NSNotification*)notif;

@end
