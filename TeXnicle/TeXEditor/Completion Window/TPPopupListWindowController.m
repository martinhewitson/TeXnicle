//
//  TPPopupListWindow.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/5/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "TPPopupListWindowController.h"

#define MAX_ENTRY_LENGTH 100

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
		for (NSString *entry in entryArray) {
			if ([entry length] > MAX_ENTRY_LENGTH) {
				[entries addObject:[entry substringToIndex:MAX_ENTRY_LENGTH]];
			} else {
				[entries addObject:entry];
			}
		}
//		[entries addObjectsFromArray:entryArray];
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
		CGFloat width = 100.0;
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
			for (NSString *entry in entries) {
				NSSize s = [entry sizeWithAttributes:f];
				if (s.width > maxWidth) {
					maxWidth = s.width;
				}
			}
		}
		if (maxWidth > 400)
			maxWidth = 400;
		
		
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
	NSString *selected = [[self filteredEntries] objectAtIndex:[aRow intValue]];
	if (mode == TPPopupListInsert) {
		if ([delegate respondsToSelector:@selector(insertWordAtCurrentLocation:)]) {
			[delegate performSelector:@selector(insertWordAtCurrentLocation:) withObject:selected];
		}
	} else if (mode == TPPopupListSpell) {
		if ([delegate respondsToSelector:@selector(replaceWordAtCurrentLocationWith:)]) {
			[delegate performSelector:@selector(replaceWordAtCurrentLocationWith:) withObject:selected];
		}
	} else if (mode == TPPopupListReplace) {
		if ([delegate respondsToSelector:@selector(replaceWordUpToCurrentLocationWith:)]) {
			[delegate performSelector:@selector(replaceWordUpToCurrentLocationWith:) withObject:selected];
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
		return [[self filteredEntries] objectAtIndex:row];
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
		return [entries filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@", self.searchString]];
	} else {
		return entries;
	}
}

-(NSWindow*)window
{
  return attachedWindow;
}


@end
