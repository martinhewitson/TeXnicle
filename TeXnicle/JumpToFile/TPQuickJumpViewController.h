//
//  TPQuickJumpViewController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 13/7/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TPQuickJumpViewController;

@protocol QuickJumpDelegate <NSObject>

- (NSArray*)quickjumpItemsForDisplay:(TPQuickJumpViewController*)quickjump;
- (void)quickjump:(TPQuickJumpViewController*)quickjump didSelectItem:(id)anItem;

@end

@interface TPQuickJumpViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate>

@property (assign) id<QuickJumpDelegate> delegate;
@property (assign) BOOL isVisible;

- (id)initWithDelegate:(id<QuickJumpDelegate>)aDelegate
							 atPoint:(NSPoint)aPoint
				inParentWindow:(NSWindow*)aWindow;

- (void) showPopup;

@end
