//
//  NewProjectAssistantController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 28/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TPProjectTemplateListViewController.h"
#import "HHValidatedButton.h"

@class TPDescriptionView;

@interface StartupScreenController : NSWindowController <NSUserInterfaceValidations, NSMetadataQueryDelegate> {
  
  IBOutlet TPDescriptionView *emptyProjectDescription;
  IBOutlet TPDescriptionView *newArticleDescription;
  IBOutlet TPDescriptionView *fromTemplateDescription;
  IBOutlet TPDescriptionView *buildProjectDescription;
  
  IBOutlet NSView *containerView;
  IBOutlet NSView *startView;
  IBOutlet NSView *buildView;
  IBOutlet NSView *templateView;
  IBOutlet NSButton *bottomBarButton;
  
	NSMutableArray *recentFiles;
	
	IBOutlet NSTableView *recentFilesTable;
		
	IBOutlet NSArrayController *recentFilesController;
  
  IBOutlet TPDescriptionView *fileLabel;
  IBOutlet NSTextField *dateLabel;
  
  IBOutlet NSButton *recentBtn;
  IBOutlet NSButton *allBtn;
  
  IBOutlet HHValidatedButton *createBtn;
  
	NSMetadataQuery* query;
  NSMutableArray *texnicleFiles;
  
	BOOL isOpen;
	
	NSRect openFrame;
  
  TPProjectTemplateListViewController *templateListViewController;
  NSView *templateListContainer;
}

-(IBAction)displayOrCloseWindow:(id)sender;
-(IBAction)displayWindow:(id)sender;

@property (readwrite, assign) BOOL isOpen;
@property (readwrite, assign) NSMutableArray *recentFiles;

@property (retain) TPProjectTemplateListViewController *templateListViewController;
@property (assign) IBOutlet NSView *templateListContainer;

- (IBAction) openRecentFile:(id)sender;

- (IBAction) newProject:(id)sender;
- (IBAction)cancelNewProject:(id)sender;

- (IBAction) buildProject:(id)sender;
- (IBAction) newEmptyProject:(id)sender;
- (IBAction) openExistingDocument:(id)sender;
- (IBAction) newArticleDocument:(id)sender;
- (void) show;

- (IBAction)createProjectFromSelectedTemplate:(id)sender;
- (IBAction)newProjectFromTemplate:(id)sender;
- (IBAction)cancelTemplateProject:(id)sender;

- (void) updateFilepathLabel;

#pragma mark -
#pragma File selection

- (IBAction)startFileQuery:(id)sender;
- (IBAction) fileSourceChanged:(id)sender;
- (void)loadFilesFromQueryResult:(NSNotification*)notif;

@end
