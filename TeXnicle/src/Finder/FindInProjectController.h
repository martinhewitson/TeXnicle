//
//  FindInProjectController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 20/3/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TeXProjectDocument;
@class ProjectEntity;
@class FileEntity;

@protocol FindInProjectControllerDelegate <NSObject>

- (ProjectEntity*)project;
- (void) highlightSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(FileEntity*)aFile;

@end

@interface FindInProjectController : NSWindowController {

	IBOutlet NSTableView *resultsView;
//	IBOutlet NSTextField *searchText;
//	IBOutlet NSButton *findButton;
	
	IBOutlet NSArrayController *searchResults;
	
  id<FindInProjectControllerDelegate> delegate;
}
@property (assign) IBOutlet id<FindInProjectControllerDelegate> delegate;

- (IBAction) performSearch:(id)sender;
- (IBAction)handleTableDoubleClick:(id)sender;

@end
