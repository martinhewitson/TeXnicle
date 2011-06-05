//
//  NewProjectAssistantController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 28/1/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import "StartupScreenController.h"


@implementation StartupScreenController

@synthesize isOpen;
@synthesize recentFiles;

- (id) init
{
//	NSLog(@"Startup init");
	
	if (![super initWithWindowNibName:@"StartupScreen"]) 
		return nil;
	
	recentFiles = [[NSMutableArray alloc] init];
//	[[self window] setAlphaValue:1.0];
	
	return self;
}

- (void) dealloc
{
	[recentFiles release];
	[super dealloc];
}

- (void) awakeFromNib
{
	[[self window] setLevel:NSNormalWindowLevel];
	[[[[recentFilesTable tableColumns] objectAtIndex:0] dataCell] setFont:[NSFont systemFontOfSize:14.0]];
	
	[recentFilesTable setDoubleAction:@selector(recentFilesTableDoubleClick)];

	openFrame = [[self window] frame];
	[[self window] setAlphaValue:0.0];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleRecentFilesSelectionChanged:)
                                               name:NSTableViewSelectionDidChangeNotification
                                             object:recentFilesTable];
  
  
  [self updateFilepathLabel];
}

- (void) handleRecentFilesSelectionChanged:(NSNotification*)aNote
{	
  [self updateFilepathLabel];
}

- (void) updateFilepathLabel
{
  NSInteger row = [recentFilesTable selectedRow];
	if (row>=0) {
    NSString *path = [[[recentFiles objectAtIndex:row] valueForKey:@"url"] path];
    [fileLabel setStringValue:path];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *atts = [fm attributesOfItemAtPath:path error:&error];  
    NSDate *date = [atts valueForKey:NSFileModificationDate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [dateLabel setStringValue:[formatter stringFromDate:date]];
  }
  
  
}

- (void) recentFilesTableDoubleClick
{
	[self openRecentFile:self];
}


- (void)windowDidBecomeKey:(NSNotification *)notification
{
	[[[self window] animator] setAlphaValue:1.0];
}


-(IBAction)displayOrCloseWindow:(id)sender 
{
//	NSLog(@"Display or close");
	//Fades in & out nicely
	if(isOpen) {
		[[[self window] animator] setAlphaValue:0.0];
		isOpen = NO;
		[self close];
	}
	else {
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
//		id window = [self window];
//		NSLog(@"Got window: %@", window);
		[[self window] performSelector:@selector(makeKeyAndOrderFront:) withObject:self afterDelay:0];
//		[[self window] makeKeyAndOrderFront:self];
		//[window setAlphaValue:1.0];
		[[[self window] animator] setAlphaValue:1.0];
		isOpen = YES;
	}
}

-(IBAction)displayWindow:(id)sender 
{
  //	NSLog(@"Display or close");
	//Fades in & out nicely
//	if(isOpen) {
//		[[[self window] animator] setAlphaValue:0.0];
//		isOpen = NO;
//		[self close];
//	}
//	else {
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    //		id window = [self window];
    //		NSLog(@"Got window: %@", window);
		[[self window] performSelector:@selector(makeKeyAndOrderFront:) withObject:self afterDelay:0];
    //		[[self window] makeKeyAndOrderFront:self];
		//[window setAlphaValue:1.0];
		[[[self window] animator] setAlphaValue:1.0];
		isOpen = YES;
//	}
}

#pragma mark -
#pragma mark Recent Files Table Delegate

- (void)tableView:(NSTableView *)aTableView 
	willDisplayCell:(id)aCell 
	 forTableColumn:(NSTableColumn *)aTableColumn 
							row:(NSInteger)rowIndex
{
	NSDictionary *dict = [recentFiles objectAtIndex:rowIndex];
  NSString *path = [[dict valueForKey:@"url"] path];
	NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error = nil;
  NSDictionary *atts = [fm attributesOfItemAtPath:path error:&error];  
	if ([fm fileExistsAtPath:path]) {
		[aCell setTextColor:[NSColor blackColor]];
	} else {
		[aCell setTextColor:[NSColor redColor]];
	}
	
}

- (NSString *)tableView:(NSTableView *)aTableView 
				 toolTipForCell:(NSCell *)aCell 
									 rect:(NSRectPointer)rect 
						tableColumn:(NSTableColumn *)aTableColumn 
										row:(NSInteger)row 
					mouseLocation:(NSPoint)mouseLocation
{
	NSDictionary *dict = [recentFiles objectAtIndex:row];
	return [[dict valueForKey:@"url"] path];
}


#pragma mark -
#pragma mark Project controls

- (IBAction) newEmptyProject:(id)sender
{
	[[NSDocumentController sharedDocumentController] newDocument:self];
	id doc = [[NSDocumentController sharedDocumentController] currentDocument];

	if (doc) {
		// Check if a document was opened
		if ([[NSDocumentController sharedDocumentController] currentDocument]) {
			[self displayOrCloseWindow:self];
		}
//		[doc saveDocument:self];
	}
}

- (void) show 
{
	[self showWindow:self];
	[[self window] makeKeyAndOrderFront:self];
}

- (IBAction) openRecentFile:(id)sender
{
	NSInteger row = [recentFilesTable selectedRow];
	if (row>=0) {
		NSError *error = nil;
		[[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[[recentFiles objectAtIndex:row] valueForKey:@"url"]
																																					 display:YES
																																						 error:&error];
		if (error) {
			[NSApp presentError:error];
			return;
		}
		[self displayOrCloseWindow:self];
	}
}


- (IBAction) openExistingDocument:(id)sender
{
	[[NSDocumentController sharedDocumentController] openDocument:self];
	// Check if a document was opened
	if ([[NSDocumentController sharedDocumentController] currentDocument]) {
		[self displayOrCloseWindow:self];
	}
}

- (IBAction) newArticleDocument:(id)sender
{
	[[NSDocumentController sharedDocumentController] newDocument:self];

	id doc = [[NSDocumentController sharedDocumentController] currentDocument];
	
	// Check if a document was opened
	if (doc) {
		// Add a new main TeX file to the doc
		if ([doc respondsToSelector:@selector(addNewArticleMainFile)]) {
			[doc performSelector:@selector(addNewArticleMainFile)];
		}
		
		[self displayOrCloseWindow:self];
	}
}



@end
