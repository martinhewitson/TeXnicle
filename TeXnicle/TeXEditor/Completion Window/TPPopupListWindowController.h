//
//  TPPopupListWindow.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/5/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MAAttachedWindow.h"
#import "TPPopuplistView.h"
#import "SBGradientView.h"

#define TPPopupListReplace 0
#define TPPopupListInsert 1
#define TPPopupListSpell 2


@interface TPPopupListWindowController : NSViewController <NSTextFieldDelegate> {
	id delegate;
	NSString *title;
	IBOutlet NSTextField *titleView;
	NSWindow *parentWindow;
	MAAttachedWindow *attachedWindow;
	NSMutableArray *entries;
	NSString *searchString;
	NSPoint point;
	NSUInteger mode;
	IBOutlet NSTableView *table;
	IBOutlet SBGradientView *gradientView;
	IBOutlet NSSearchField *searchField;
}

@property (nonatomic, copy) NSString *searchString;

@property (readwrite, retain) NSString *title;
@property (readwrite, assign) id delegate;

- (IBAction) searchFieldAction:(id)sender;

- (id) initWithEntries:(NSArray*)entries 
							 atPoint:(NSPoint)aPoint 
				inParentWindow:(NSWindow*)aWindow
								mode:(NSUInteger)aMode
								 title:(NSString*)aTitle;

- (void) userSelectedRow:(NSNumber*)aRow;
- (void) showPopup;
- (void) dismiss;
- (void) setupWindow;
- (NSArray*) filteredEntries;
-(NSWindow*)window;

@end
