//
//  TPSectionListController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol TPSectionListControllerDelegate <NSObject>

- (NSArray*)bookmarksForCurrentFile;

@end

@interface TPSectionListController : NSObject {

	NSMutableArray *sections;
	
	NSTimer *timer;
	
	IBOutlet NSTextView *textView;
	
	IBOutlet NSPopUpButton *popupMenu;
	
	NSMenu *addMarkerActionMenu;
	
}

@property (nonatomic, retain) NSTimer *timer;
@property (assign) IBOutlet id<TPSectionListControllerDelegate> delegate;

- (void) deactivate;
- (IBAction)calculateSections:(id)sender;
- (IBAction) gotoSection:(id)sender;
- (void)fillSectionMenu;

- (void) createMarkerMenu;
- (void) addSelectedMarker:(id)sender;
- (IBAction) addMarkAction:(id)sender;
- (void) addTitle;

@end

