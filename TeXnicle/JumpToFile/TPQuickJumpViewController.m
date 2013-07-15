//
//  TPQuickJumpViewController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 13/7/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "TPQuickJumpViewController.h"
#import "MAAttachedWindow.h"
#import "TPPopuplistView.h"
#import "ImageAndTextCell.h"
#import "FileEntity.h"

#define kQuickJumpMaxHeight 400.0

@interface TPQuickJumpViewController ()

@property (strong) MAAttachedWindow *attachedWindow;
@property (assign) NSWindow *parentWindow;
@property (assign) NSPoint point;
@property (assign) IBOutlet NSSearchField *searchField;
@property (assign) IBOutlet NSTableView *tableview;
@property (strong) NSPredicate *predicate;
@property (strong) NSSortDescriptor *sortDescriptor;

@end

@implementation TPQuickJumpViewController

- (id)initWithDelegate:(id<QuickJumpDelegate>)aDelegate
							 atPoint:(NSPoint)aPoint
				inParentWindow:(NSWindow*)aWindow
{
  self = [super initWithNibName:@"TPQuickJumpViewController" bundle:nil];
  if (self) {
    self.delegate = aDelegate;
    
    self.isVisible = NO;
    self.attachedWindow = nil;
		self.parentWindow = aWindow;
		self.point = aPoint;
    
    self.sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pathRelativeToProject" ascending:YES];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWindowDidResignKeyNotification)
                                                 name:NSWindowDidResignKeyNotification
                                               object:self.attachedWindow];

  }
  
  return self;
}

- (void) handleWindowDidResignKeyNotification
{
  //NSLog(@"Window did resign key");
  [self dismiss];
}


- (void) awakeFromNib
{
	[self setupWindow];
  
  
	// apply our custom ImageAndTextCell for rendering the first column's cells
	NSTableColumn *tableColumn = [self.tableview tableColumnWithIdentifier:@"NameColumn"];
	ImageAndTextCell *imageAndTextCell = [[ImageAndTextCell alloc] init];
	[imageAndTextCell setEditable:YES];
	[imageAndTextCell setImage:[NSImage imageNamed:NSImageNameFolderBurnable]];
	[tableColumn setDataCell:imageAndTextCell];
 
  

}

- (void) setupWindow
{
	if (self.attachedWindow == nil) {
		NSView *view = [self view];
		CGFloat width = 400.0;
		
//    NSArray *items = [self items];
    CGFloat height = kQuickJumpMaxHeight; //[items count] * [self.tableview rowHeight];
//    if (height > kQuickJumpMaxHeight) {
//      height = kQuickJumpMaxHeight;
//    }
    
		// get max width of entries
		// NSDictionary *f = @{NSFontAttributeName: [NSFont systemFontOfSize:12.0]};
    //		NSLog(@"Font atts: %@", f);
		  
    //NSLog(@"Making window height %f", height);
    
    MAWindowPosition pos = MAPositionTop;
		
    // compare point on screen coordinates to check if the
    // window will be off the bottom of the screen
    NSPoint screenPoint = [self.parentWindow convertBaseToScreen:self.point];
    CGFloat y = screenPoint.y;// - height;
    if (y<0) {
      pos = MAPositionTopRight;
    }
    
    //		NSLog(@"Setting table bounds: %f x %f", width , height);
    //		NSLog(@"Attaching window at: %f x %f", point.x , point.y);
		
		[view setFrame:NSMakeRect(0, 0, width+20.0, height)];
    if (self.attachedWindow == nil) {
      self.attachedWindow = [[MAAttachedWindow alloc] initWithView:view
                                              attachedToPoint:self.point
                                                     inWindow:self.parentWindow
                                                       onSide:pos
                                                   atDistance:0.0];
    }
		[self.attachedWindow setBorderColor:[NSColor clearColor]];
		[self.attachedWindow setBackgroundColor:[NSColor whiteColor]];
		[self.attachedWindow setViewMargin:5.0];
		[self.attachedWindow setBorderWidth:3.0];
		[self.attachedWindow setCornerRadius:5.0];
		[self.attachedWindow setHasArrow:NO];
		[self.attachedWindow setDrawsRoundCornerBesideArrow:YES];
		  
    
	} // end if !attachedWindow
}

- (void) resizeWindow
{
  return;
  
  NSArray *items = [self items];
  CGFloat height = [items count] * [self.tableview rowHeight];
  if (height > kQuickJumpMaxHeight) {
    height = kQuickJumpMaxHeight;
  }
  
  if (height < 100.0) {
    height = 100.0;
  }
  
  NSLog(@"Resizing to height %f", height);

  NSRect fr = self.attachedWindow.frame;
  CGFloat offset = fr.size.height - height;
  CGFloat newY = fr.origin.y + offset;
  NSRect newFrame = NSMakeRect(fr.origin.x, newY, fr.size.width, height);
  NSLog(@"Offset %f", offset);
  NSLog(@"Old frame %@", NSStringFromRect(fr));
  NSLog(@"New frame %@", NSStringFromRect(newFrame));
  
  NSRect bounds = self.view.bounds;
  bounds.size.height -= offset;
  [self.view setBounds:bounds];
  
//  [self.view setFrame:newFrame];
//  [self.attachedWindow.animator setFrame:newFrame display:YES];
}

//- (void)keyDown:(NSEvent *)theEvent
//{
//  [self.delegate keyDown:theEvent];
//}

- (void) dealloc
{
  self.delegate = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self dismiss];
}

- (void) moveToPoint:(NSPoint)aPoint
{
  self.point = aPoint;
  [self.attachedWindow moveToPoint:aPoint];
  [self.attachedWindow displayIfNeeded];
}

- (NSPoint)currentPoint
{
  return [self.attachedWindow currentPoint];
}


- (void) showPopup
{
	[self setupWindow];
	[self.parentWindow addChildWindow:self.attachedWindow ordered:NSWindowAbove];
  [self.attachedWindow makeKeyWindow];
  self.isVisible = YES;
  [self.attachedWindow performSelector:@selector(makeFirstResponder:) withObject:self.searchField afterDelay:0];
//	[self.attachedWindow makeFirstResponder:self.searchField];
}


- (void) dismiss
{
  if (self.isVisible == NO || self.attachedWindow == nil || self.parentWindow == nil) {
    return;
  }
  
	if ([[self.parentWindow childWindows] containsObject:self.attachedWindow]) {
		[self.parentWindow removeChildWindow:self.attachedWindow];
	}
	if (self.attachedWindow) {
		[self.attachedWindow close];
		self.attachedWindow = nil;
    self.isVisible = NO;
	}
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(didDismissPopupList)]) {
    [self.delegate performSelector:@selector(didDismissPopupList)];
  }
}

- (IBAction)filterItems:(id)sender
{
  NSString *searchString = self.searchField.stringValue;
  if ([searchString length] == 0) {
    self.predicate = nil;
  } else {
    self.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self.pathRelativeToProject contains[cd] '%@'", self.searchField.stringValue]];
  }
  
  [self resizeWindow];
  [self.tableview reloadData];
  [self performSelector:@selector(selectRow) withObject:nil afterDelay:0.1];
}

- (void) selectRow
{
  NSInteger row = [self.tableview selectedRow];
  if (row == NSNotFound || row < 0) {
    row = 0;
  }
  NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:row];
  [self.tableview selectRowIndexes:indexSet byExtendingSelection:NO];
}

#pragma mark -
#pragma mark Text Field Delegate


- (void) cancelOperation:(id)sender
{
  [self dismiss];
}

//- (void) controlTextDidBeginEditing:(NSNotification *)obj
//{
//  NSLog(@"%@", NSStringFromSelector(_cmd));
//}

//- (void)controlTextDidEndEditing:(NSNotification *)obj
//{
//  NSLog(@"%@", NSStringFromSelector(_cmd));
//  NSLog(@"Popup is visible? %d", self.isVisible);
//  [self dismiss];
//}

//- (BOOL) control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
//{
//  NSLog(@"%@", NSStringFromSelector(_cmd));
//  [self dismiss];
//  return self.isVisible;
//}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command
{
//  NSLog(@"%@", NSStringFromSelector(_cmd));
  if ([NSStringFromSelector(command) isEqualToString:@"cancelOperation:"]) {
    [self dismiss];
    return YES;
  }
  
  if ([NSStringFromSelector(command) isEqualToString:@"moveUp:"]) {
    
    NSInteger row = [self.tableview selectedRow];
    if (row == NSNotFound) {
      row = 0;
    } else {
      row--;
    }
    
    if (row < 0) {
      row = [[self items] count]-1;
    }
    
    [self.tableview selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    
    return YES;
  }
  
  if ([NSStringFromSelector(command) isEqualToString:@"moveDown:"]) {
    NSInteger row = [self.tableview selectedRow];
    if (row == NSNotFound) {
      row = 0;
    } else {
      row++;
    }
    
    if (row >= [[self items] count]) {
      row = 0;
    }
    
    [self.tableview selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    
    return YES;
  }
  
  if ([NSStringFromSelector(command) isEqualToString:@"insertNewline:"]) {
    
    NSArray *items = [self items];
    NSInteger row = [self.tableview selectedRow];
    id item = items[0];
    if (row >= 0 && row < [items count]) {
      item = items[row];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(quickjump:didSelectItem:)]) {
      [self.delegate quickjump:self didSelectItem:item];
    }
    
    [self dismiss];
    
    return YES;
  }
  
//  NSLog(@"Command %@", NSStringFromSelector(command));
  
  return NO;
}

- (NSArray*)items
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(quickjumpItemsForDisplay:)]) {
    NSArray *allitems = [self.delegate quickjumpItemsForDisplay:self];
    
    if (self.predicate == nil) {
      return [allitems sortedArrayUsingDescriptors:@[self.sortDescriptor]];
    }
    
    return [[allitems filteredArrayUsingPredicate:self.predicate] sortedArrayUsingDescriptors:@[self.sortDescriptor]];
  }
  
  return @[];
}

#pragma mark NSTableView Delegate/DataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return [[self items] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  NSArray *items = [self items];
  if (row >= 0 && row < [items count]) {
    return [items[row] valueForKey:@"pathRelativeToProject"];
  }
  
  return nil;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  NSArray *items = [self items];
  
  if (row >= 0 && row < [items count]) {
    
    CGFloat imageSize = 20.0;
    [tableView setRowHeight:imageSize+2.0];
    [cell setImageSize:imageSize];
    
    FileEntity *file = items[row];
    
    if ([file icon] == nil) {
      [file loadIcon];
    }
    [cell setImage:[file icon]];
  }
}

@end
