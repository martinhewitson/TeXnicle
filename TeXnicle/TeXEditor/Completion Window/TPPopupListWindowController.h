//
//  TPPopupListWindow.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/5/10.
//  Copyright 2010 bobsoft. All rights reserved.
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

#import "MAAttachedWindow.h"
#import "TPPopuplistView.h"
#import "SBGradientView.h"

#define TPPopupListReplace 0
#define TPPopupListInsert 1
#define TPPopupListSpell 2


@interface TPPopupListWindowController : NSViewController <NSTextFieldDelegate, NSTableViewDelegate> {
@private
	IBOutlet NSTextField *titleView;
	NSWindow *parentWindow;
	MAAttachedWindow *attachedWindow;
	NSMutableArray *entries;
	NSPoint point;
	IBOutlet NSTableView *table;
	IBOutlet SBGradientView *gradientView;
}

@property (assign) BOOL isVisible;
@property (readwrite, unsafe_unretained) id delegate;
@property (assign) NSUInteger mode;

- (id) initWithEntries:(NSArray*)entries 
							 atPoint:(NSPoint)aPoint 
				inParentWindow:(NSWindow*)aWindow
								mode:(NSUInteger)aMode
								 title:(NSString*)aTitle;

- (void) handleWindowDidResignKeyNotification;
- (void) userSelectedRow:(NSNumber*)aRow;
- (void) showPopup;
- (void) dismiss;
- (void) setupWindow;
- (NSArray*) filteredEntries;
- (NSWindow*)window;
- (void)setList:(NSArray*)aList;

- (IBAction)moveUp:(id)sender;
- (IBAction)moveDown:(id)sender;
- (IBAction)selectSelectedItem:(id)sender;
- (NSString*)selectedValue;
- (void) moveToPoint:(NSPoint)aPoint;
- (NSPoint)currentPoint;

@end
