//
//  NewProjectAssistantController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 28/1/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import "StartupScreenController.h"
#import "TeXProjectDocument.h"

@implementation StartupScreenController

@synthesize isOpen;
@synthesize recentFiles;

- (id) init
{
//	NSLog(@"Startup init");
	
	if (![super initWithWindowNibName:@"StartupScreen"]) 
		return nil;
  
	recentFiles = [[NSMutableArray alloc] init];
  query = [[NSMetadataQuery alloc] init];
  texnicleFiles = [[NSMutableArray alloc] init];
  
  // setup our Spotlight notifications 
  NSNotificationCenter *nf = [NSNotificationCenter defaultCenter];
  [nf addObserver:self selector:@selector(queryNotification:) name:nil object:query];
  
  // initialize our Spotlight query
//  [query setSortDescriptors:
//   [NSArray arrayWithObject:
//    [[[NSSortDescriptor alloc] initWithKey:(id)kMDItemFSName ascending:YES] autorelease]]];
//  
//  [query setDelegate: self];
	
//	[[self window] setAlphaValue:1.0];
	
	return self;
}

- (void) dealloc
{
  [texnicleFiles release];
	[recentFiles release];
	[super dealloc];
}



- (void) awakeFromNib
{
//	[[self window] setLevel:NSNormalWindowLevel];
//	[[[[recentFilesTable tableColumns] objectAtIndex:0] dataCell] setFont:[NSFont systemFontOfSize:14.0]];
	
	[recentFilesTable setDoubleAction:@selector(recentFilesTableDoubleClick)];

	openFrame = [[self window] frame];
	[[self window] setAlphaValue:0.0];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleRecentFilesSelectionChanged:)
                                               name:NSTableViewSelectionDidChangeNotification
                                             object:recentFilesTable];
  
  
  [self updateFilepathLabel];
  
//  [self startFileQuery:self];
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
  id doc = [TeXProjectDocument newTeXnicleProject];
  
	if (doc) {
		// Check if a document was opened
		if ([[NSDocumentController sharedDocumentController] currentDocument]) {
			[self displayOrCloseWindow:self];
		}
		[doc saveDocument:self];
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
    
    NSURL *url = [[recentFiles objectAtIndex:row] valueForKey:@"url"];
    
    // check if the document is already open
    NSArray *docs = [[NSDocumentController sharedDocumentController] documents];
    BOOL exists = NO;
    for (NSDocument *doc in docs) {
      if ([[doc fileURL] isEqualTo:url]) {
        [[doc windowForSheet] makeKeyAndOrderFront:self];
        exists = YES;
      }
    }
    
    if (!exists) {
      [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:url
                                                                             display:YES
                                                                               error:&error];
      if (error) {
        [NSApp presentError:error];
        return;
      }
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
  id doc = [TeXProjectDocument newTeXnicleProject];
  
	// Check if a document was opened
	if (doc) {
		// Add a new main TeX file to the doc
		if ([doc respondsToSelector:@selector(addNewArticleMainFile)]) {
			[doc performSelector:@selector(addNewArticleMainFile)];
      [doc performSelector:@selector(saveDocument:) withObject:self];
		}
		
		[self displayOrCloseWindow:self];
	}
}

#pragma mark -
#pragma File selection

- (IBAction) fileSourceChanged:(id)sender
{
  [self.recentFiles removeAllObjects];
  if (sender == recentBtn) {
    [allBtn setState:NSOffState];
    NSArray *recentURLs = [[NSDocumentController sharedDocumentController] recentDocumentURLs];
    for (NSURL *url in recentURLs) {
      NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:[[url path] lastPathComponent]
                                                                     forKey:@"path"];
      [dict setObject:url forKey:@"url"];
      [self.recentFiles addObject:dict];
    }
  } else {
    [recentBtn setState:NSOffState];
    [self.recentFiles addObjectsFromArray:texnicleFiles];
  }
  
  [recentFilesController setContent:recentFiles];
}



- (IBAction)startFileQuery:(id)sender
{
  // setup Spotlight query to look for image files and start it up
  [query setPredicate: [NSPredicate predicateWithFormat: @"(kMDItemContentType == 'com.bobsoft.texnicle.texnicle')"]];
  //  [query setSearchScopes: [NSArray arrayWithObjects: fromPath, nil]];
  [query startQuery]; 
}

- (void)queryNotification:(NSNotification*)note
{
  // the NSMetadataQuery will send back a note when updates are happening.
  
  // by looking at the [note name], we can tell what is happening
  if ([[note name] isEqualToString:NSMetadataQueryDidStartGatheringNotification])
  {
    // the query has just started
    NSLog(@"search: started gathering");
  }
  else if ([[note name] isEqualToString:NSMetadataQueryDidFinishGatheringNotification])
  {
    // at this point, the query will be done. You may recieve an update later on.
    NSLog(@"search: finished gathering");
    
    [self loadFilesFromQueryResult:note];
  }
  else if ([[note name] isEqualToString:NSMetadataQueryGatheringProgressNotification])
  {
    // the query is still gatherint results...
    NSLog(@"search: progressing...");
  }
  else if ([[note name] isEqualToString:NSMetadataQueryDidUpdateNotification])
  {
    // an update will happen when Spotlight notices that a file as added,
    // removed, or modified that affected the search results.
    NSLog(@"search: an update happened.");
    [self loadFilesFromQueryResult:note];
  }
}

- (void)loadFilesFromQueryResult:(NSNotification*)notif
{
  NSArray* results = [(NSMetadataQuery*)[notif object] results];
  
  // iterate through the array of results, and match to the existing stores
  NSInteger count = [results count];
  [texnicleFiles removeAllObjects];
  if (count == 0)
  {
    // no TeXnicle files were found
  }
  else
  {
    // use Spotlight's search query results and load the images
    
    int i;
    for (i = 0; i < count; i++)
    {
      // get the result item
      NSMetadataItem* item = [results objectAtIndex: i];
      
      NSString* storePath = [[item valueForAttribute:
                              (NSString *)kMDItemPath] stringByResolvingSymlinksInPath];
      
      if ((storePath != nil) && ([storePath length] > 0))
      {
        // create a URL for the represented path and look for an existing store
        NSURL* storeURL = [NSURL fileURLWithPath: storePath];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:[[storeURL path] lastPathComponent]
                                                                       forKey:@"path"];
        [dict setObject:storeURL forKey:@"url"];
        [texnicleFiles addObject:dict];
        NSLog(@"Found %@", storeURL);
      }
    }
  }
}

@end
