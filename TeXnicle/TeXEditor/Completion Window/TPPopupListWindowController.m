//
//  TPPopupListWindow.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/5/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "TPPopupListWindowController.h"
#import "BibliographyEntry.h"

#define MAX_ENTRY_LENGTH 200

@implementation TPPopupListWindowController

@synthesize delegate;
@synthesize title;
@synthesize searchString;

- (id) initWithEntries:(NSArray*)entryArray 
							 atPoint:(NSPoint)aPoint 
				inParentWindow:(NSWindow*)aWindow
								mode:(NSUInteger)aMode
								 title:(NSString*)aTitle
{
	self = [super initWithNibName:@"TPPopuplistView" bundle:nil];
	
	if (self) {
		
		[self setTitle:aTitle];
		mode = aMode;
		parentWindow = aWindow;
		entries = [[NSMutableArray alloc] initWithCapacity:[entryArray count]];
		for (id entry in entryArray) {
      [entries addObject:entry];
		}
		point = aPoint;
		self.searchString = nil;
		
		TPPopuplistView *view = (TPPopuplistView*)[self view];
		[view setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismiss)
                                                 name:NSWindowDidResignKeyNotification
                                               object:[self window]];
    
	}
	
	return self;
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
		
		if (height > 500)
			height = 500;
		
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
    
		
//		NSLog(@"Setting table bounds: %f x %f", width , height);
//		NSLog(@"Attaching window at: %f x %f", point.x , point.y);
		
		[view setFrame:NSMakeRect(0, 0, width+20.0, height)];
		attachedWindow = [[MAAttachedWindow alloc] initWithView:view
																						attachedToPoint:point 
																									 inWindow:parentWindow 
																										 onSide:MAPositionAutomatic 
																								 atDistance:0.0];
		[attachedWindow setBorderColor:[NSColor clearColor]];
		[attachedWindow setBackgroundColor:[NSColor lightGrayColor]];
		[attachedWindow setViewMargin:0.0];
		[attachedWindow setBorderWidth:3.0];
		[attachedWindow setCornerRadius:10.0];
		[attachedWindow setHasArrow:NO];
		[attachedWindow setDrawsRoundCornerBesideArrow:YES];	
		
		[titleView setStringValue:self.title];
		[gradientView setStartingColor:[NSColor whiteColor]];
		[gradientView setEndingColor:[NSColor lightGrayColor]];
		[gradientView setAngle:270.0];
    
    [attachedWindow setInitialFirstResponder:table];
    [searchField setNextKeyView:table];
    [table setNextKeyView:searchField];
    
	}
}

- (void) dealloc
{
  self.delegate = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
	[entries release];
	[self dismiss];
	[super dealloc];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command
{
  if (command == @selector(cancelOperation:)) {
    if ([[textView string] length]==0) {
      [self dismiss];
    } 
  }
  return NO;
}


- (void) showPopup
{
	[self setupWindow];
	[parentWindow addChildWindow:attachedWindow ordered:NSWindowAbove];	
	[attachedWindow makeKeyAndOrderFront:self];
	[attachedWindow makeFirstResponder:table];
	[table selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

- (void) dismiss
{
//	[attachedWindow resignKeyWindow];
//	[table resignFirstResponder];
	if ([[parentWindow childWindows] containsObject:attachedWindow]) {
		[parentWindow removeChildWindow:attachedWindow];
	}
	if (attachedWindow) {
		[attachedWindow close];
		attachedWindow = nil;
	}
  if (self.delegate && [self.delegate respondsToSelector:@selector(didDismissPopupList)]) {
    [self.delegate performSelector:@selector(didDismissPopupList)];
  }
}


#pragma mark -
#pragma mark List View delegate

- (void) userSelectedRow:(NSNumber*)aRow
{
	id value = [[self filteredEntries] objectAtIndex:[aRow intValue]];
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
#pragma mark SearchField delegate

- (IBAction) searchFieldAction:(id)sender
{
	NSString *searchFieldText = [searchField stringValue];
	searchFieldText = [searchFieldText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	if ([searchFieldText isEqual:@""]) {
		self.searchString = nil;
	} else {
		self.searchString = searchFieldText;
	}
	
	[table reloadData];
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
	if (self.searchString) {
    NSMutableArray *filteredArray = [NSMutableArray array];
    for (id entry in entries) {
      NSString *test = entry;
      if ([entry isKindOfClass:[NSAttributedString class]]) {
        test = [entry string];
      } else if ([entry isKindOfClass:[BibliographyEntry class]]) {
        test = [[entry attributedString] string];
      } else {
        test = entry;
      }
      NSRange r = [[test lowercaseString] rangeOfString:[self.searchString lowercaseString]];
      if (r.location != NSNotFound) {
        [filteredArray addObject:entry];
      }
    }
		return filteredArray; 
	} else {
		return entries;
	}
}

-(NSWindow*)window
{
  return attachedWindow;
}


@end
