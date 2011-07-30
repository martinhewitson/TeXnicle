//
//  TPOutlineView.h
//  TeXnicle
//
//  Created by Martin Hewitson on 30/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProjectItemTreeController.h"
#import "ESOutlineView.h"

@interface TPOutlineView : ESOutlineView {

	IBOutlet TeXProjectDocument *mainDocument;
	IBOutlet ProjectItemTreeController *treeController;
	ProjectItemEntity *selectedItem;
	NSUInteger selectedRow;
  BOOL dragLeftView;
}

@property (assign) BOOL dragLeftView;

-(NSMenu*)defaultMenuForRow:(NSInteger)row;
- (NSMenu*)defaultMenu;

- (IBAction) addExistingFile:(id)sender;
- (IBAction) addExistingFileToSelectedFolder:(id)sender;

- (IBAction) revealItem:(id)sender;
- (IBAction) renameItem:(id)sender;
- (IBAction) removeItem:(id)sender;

@end
