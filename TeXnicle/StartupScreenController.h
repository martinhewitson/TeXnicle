//
//  NewProjectAssistantController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 28/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Cocoa/Cocoa.h>
#import "TPProjectTemplateListViewController.h"
#import "HHValidatedButton.h"

@class TPDescriptionView;

@interface StartupScreenController : NSWindowController <NSUserInterfaceValidations, NSMetadataQueryDelegate> {
  
@private
  IBOutlet TPDescriptionView *emptyProjectDescription;
  IBOutlet TPDescriptionView *newArticleDescription;
  IBOutlet TPDescriptionView *fromTemplateDescription;
  IBOutlet TPDescriptionView *buildProjectDescription;
  
  IBOutlet NSView *containerView;
  IBOutlet NSView *startView;
  IBOutlet NSView *buildView;
  IBOutlet NSView *templateView;
  IBOutlet NSButton *bottomBarButton;
	
	IBOutlet NSTableView *recentFilesTable;
		
	IBOutlet NSArrayController *recentFilesController;
  
  IBOutlet TPDescriptionView *fileLabel;
  IBOutlet NSTextField *dateLabel;
  
  IBOutlet NSButton *recentBtn;
  IBOutlet NSButton *allBtn;
  
  IBOutlet HHValidatedButton *createBtn;
  
	NSMetadataQuery* query;
  NSMutableArray *texnicleFiles;
  
	NSRect openFrame;
}


@property (readwrite) NSMutableArray *recentFiles;


-(IBAction)displayOrCloseWindow:(id)sender;
-(IBAction)displayWindow:(id)sender;

- (IBAction) openRecentFile:(id)sender;

- (IBAction) newProject:(id)sender;
- (IBAction) cancelNewProject:(id)sender;

- (IBAction) buildNewProject:(id)sender;
- (IBAction) newEmptyProject:(id)sender;
- (IBAction) openExistingDocument:(id)sender;
- (IBAction) newArticleDocument:(id)sender;
- (void) show;

- (IBAction) createProjectFromSelectedTemplate:(id)sender;
- (IBAction) newProjectFromTemplate:(id)sender;
- (IBAction) cancelTemplateProject:(id)sender;

- (void) updateFilepathLabel;

#pragma mark -
#pragma File selection

- (IBAction)startFileQuery:(id)sender;
- (IBAction) fileSourceChanged:(id)sender;
- (void)loadFilesFromQueryResult:(NSNotification*)notif;

@end
