//
//  TPPopupListWindow.m
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

#import "TPPopupListWindowController.h"
#import "BibliographyEntry.h"

#define MAX_ENTRY_LENGTH 200

@implementation TPPopupListWindowController

@synthesize delegate;
@synthesize title;
@synthesize isVisible;

- (id) initWithEntries:(NSArray*)entryArray 
							 atPoint:(NSPoint)aPoint 
				inParentWindow:(NSWindow*)aWindow
								mode:(NSUInteger)aMode
								 title:(NSString*)aTitle
{
  NSLog(@"Init popup list");
	self = [super initWithNibName:@"TPPopuplistView" bundle:nil];
	
	if (self) {
		self.isVisible = NO;
		[self setTitle:aTitle];
		mode = aMode;
		parentWindow = aWindow;
		entries = [[NSMutableArray alloc] initWithCapacity:[entryArray count]];
		for (id entry in entryArray) {
      [entries addObject:entry];
		}
		point = aPoint;
		
		TPPopuplistView *view = (TPPopuplistView*)[self view];
		[view setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWindowDidResignKeyNotification)
                                                 name:NSWindowDidResignKeyNotification
                                               object:[self window]];
    
	}
	
	return self;
}

- (void) handleWindowDidResignKeyNotification
{
  [self dismiss];
}

- (void)setList:(NSArray*)aList
{
  [entries removeAllObjects];
  [entries addObjectsFromArray:aList];
  [table reloadData];
}

- (void) awakeFromNib
{
	[self setupWindow];
}

- (void) setupWindow
{
	if (!attachedWindow) {
		NSView *view = [self view];
		CGFloat rowHeight = [table rowHeight];
		CGFloat width = 200.0;
		CGFloat height = MAX(150.0, 20.0 + rowHeight*(1+[entries count]));
		
		if (height > 200)
			height = 200;
		
//    NSLog(@"Row height: %f", rowHeight);
//    NSLog(@"Table height: %f", 20.0 + rowHeight*(1+[entries count]));
//    NSLog(@"Setting height %f", height);
    
		// get max width of entries
		NSDictionary *f = [NSDictionary dictionaryWithObject:[NSFont systemFontOfSize:12.0] forKey:NSFontAttributeName];		
//		NSLog(@"Font atts: %@", f);
		CGFloat maxWidth = 0;
		if (f) {
			for (id entry in entries) {
        NSSize s = NSZeroSize;
        if ([entry isKindOfClass:[NSAttributedString class]]) {
          s = [entry size];
        } else if ([entry isKindOfClass:[BibliographyEntry class]]) {
          s = [[entry attributedString] size];
        } else {
          s = [entry sizeWithAttributes:f];
        }
				if (s.width > maxWidth) {
					maxWidth = s.width;
				}
			}
		}
		if (maxWidth > 600)
			maxWidth = 600;
		
		
		width = MAX(width, maxWidth);
    
    MAWindowPosition pos = MAPositionBottomRight;
		
    // compare point on screen coordinates to check if the 
    // window will be off the bottom of the screen
    NSPoint screenPoint = [parentWindow convertBaseToScreen:point]; 
    CGFloat y = screenPoint.y - height;
    if (y<0) {
      pos = MAPositionTopRight;
    }
    
//		NSLog(@"Setting table bounds: %f x %f", width , height);
//		NSLog(@"Attaching window at: %f x %f", point.x , point.y);
		
		[view setFrame:NSMakeRect(0, 0, width+20.0, height)];
		attachedWindow = [[MAAttachedWindow alloc] initWithView:view
																						attachedToPoint:point 
																									 inWindow:parentWindow 
																										 onSide:pos 
																								 atDistance:5.0];
		[attachedWindow setBorderColor:[NSColor clearColor]];
		[attachedWindow setBackgroundColor:[NSColor whiteColor]];
		[attachedWindow setViewMargin:5.0];
		[attachedWindow setBorderWidth:3.0];
		[attachedWindow setCornerRadius:5.0];
		[attachedWindow setHasArrow:NO];
		[attachedWindow setDrawsRoundCornerBesideArrow:YES];
		
		[titleView setStringValue:self.title];
		[gradientView setStartingColor:[NSColor whiteColor]];
		[gradientView setEndingColor:[NSColor lightGrayColor]];
		[gradientView setAngle:270.0];
    
    
	} // end if !attachedWindow
}

//- (void)keyDown:(NSEvent *)theEvent
//{
//  [self.delegate keyDown:theEvent];
//}

- (void) dealloc
{
  self.delegate = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
	[entries release];
  [self dismiss];
	[super dealloc];
}

- (void) moveToPoint:(NSPoint)aPoint
{
  point = aPoint;
  [attachedWindow moveToPoint:aPoint];
  [attachedWindow displayIfNeeded];
}

- (NSPoint)currentPoint
{
  return [attachedWindow currentPoint];
}


- (void) showPopup
{
	[self setupWindow];
	[parentWindow addChildWindow:attachedWindow ordered:NSWindowAbove];	
//	[attachedWindow makeKeyAndOrderFront:self];
	[attachedWindow makeFirstResponder:table];
	[table selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
  self.isVisible = YES;
}

- (IBAction)moveUp:(id)sender
{
  [table moveUp:sender];
}

- (IBAction)moveDown:(id)sender
{
  [table moveDown:sender];
}

- (void) dismiss
{
//  NSLog(@"Dismiss");
  
	if ([[parentWindow childWindows] containsObject:attachedWindow]) {
		[parentWindow removeChildWindow:attachedWindow];
	}
	if (attachedWindow) {
		[attachedWindow close];
		attachedWindow = nil;
	}
  self.isVisible = NO;
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(didDismissPopupList)]) {
    [self.delegate performSelector:@selector(didDismissPopupList)];
  }
}


#pragma mark -
#pragma mark List View delegate

- (IBAction)selectSelectedItem:(id)sender
{
  NSInteger row = [table selectedRow];
  [self userSelectedRow:[NSNumber numberWithInteger:row]];
}

- (void) userSelectedRow:(NSNumber*)aRow
{
  NSInteger row = [aRow integerValue];
  if (row<0) {
    row = 0;
  }
  if ([[self filteredEntries] count] == 0) {
    return;
  }
  
	id value = [[self filteredEntries] objectAtIndex:row];
  NSString *tag = @"";
  if ([value isKindOfClass:[BibliographyEntry class]]) {
    tag = [value valueForKey:@"tag"];
  } else if ([value isKindOfClass:[NSAttributedString class]]) {    
    tag = [value string];    
  } else {
    tag = value;
  }
  
	if (mode == TPPopupListInsert) {
		if ([delegate respondsToSelector:@selector(insertWordAtCurrentLocation:)]) {
			[delegate performSelector:@selector(insertWordAtCurrentLocation:) withObject:tag];
		}
	} else if (mode == TPPopupListSpell) {
		if ([delegate respondsToSelector:@selector(replaceWordAtCurrentLocationWith:)]) {
			[delegate performSelector:@selector(replaceWordAtCurrentLocationWith:) withObject:tag];
		}
	} else if (mode == TPPopupListReplace) {
		if ([delegate respondsToSelector:@selector(replaceWordUpToCurrentLocationWith:)]) {
			[delegate performSelector:@selector(replaceWordUpToCurrentLocationWith:) withObject:tag];
		}
	}
  
  if ([delegate respondsToSelector:@selector(didSelectPopupListItem)]) {
    [delegate performSelector:@selector(didSelectPopupListItem)];
  }
  
  
}

#pragma mark -
#pragma mark Table delegate

- (void)tableView:(NSTableView *)tableView 
	willDisplayCell:(id)cell 
	 forTableColumn:(NSTableColumn *)tableColumn 
							row:(NSInteger)row
{
	if (tableView == table) {
	}
}

- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
						row:(NSInteger)row;
{
	if (tableView == table) {
    
		id value = [[self filteredEntries] objectAtIndex:row];
    
    if ([value isKindOfClass:[BibliographyEntry class]]) {
      return [value attributedString];
    } else {
      return value;
    }
    
	}	
	return nil;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
	if (tableView == table) {
		return [[self filteredEntries] count];
	}		
	
	return 0;
}

- (NSArray*) filteredEntries
{
  return entries;
}

-(NSWindow*)window
{
  return attachedWindow;
}


@end
