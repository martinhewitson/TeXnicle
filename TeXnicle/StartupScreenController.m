//
//  NewProjectAssistantController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 28/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "StartupScreenController.h"
#import "TeXProjectDocument.h"
#import "TPProjectBuilder.h"
#import "TPDescriptionView.h"

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
  
  [[self window] center];
  
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
  
  NSRect frame = [containerView bounds];
  [startView setFrame:frame];
  [containerView addSubview:startView];
  [buildView setFrame:frame];
  NSPoint p = NSMakePoint(frame.origin.x+frame.size.width, frame.origin.y);
  [buildView setFrameOrigin:p];
  [containerView addSubview:buildView];
  
  
  [emptyProjectDescription setDescriptionText:@"Creates a new empty TeXnicle project ready to be populated with files."];
  [emptyProjectDescription setBackgroundColor:[NSColor colorWithDeviceWhite:1.0 alpha:0.7]];
  [newArticleDescription setDescriptionText:@"Creates a new TeXnicle project with a standard article main file and folders for additional TeX files and images."];
  [newArticleDescription setBackgroundColor:[NSColor colorWithDeviceWhite:1.0 alpha:0.7]];
  [buildProjectDescription setDescriptionText:@"Creates a new TeXnicle project containing the files referenced by a main file. Choose either a TeX file or a directory. If a directory is choosen, the main file used is the first file found that contains \\documentclass command."];  
  [buildProjectDescription setBackgroundColor:[NSColor colorWithDeviceWhite:1.0 alpha:0.7]];
  
  [fileLabel setBorderColor:[NSColor clearColor]];
  [fileLabel.descriptionCell setWraps:NO];
  [fileLabel.descriptionCell setLineBreakMode:NSLineBreakByTruncatingMiddle];
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
    [fileLabel setDescriptionText:path];
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
  // set back to start state
  [self cancelNewProject:self];
  
	//Fades in & out nicely
	if(isOpen) {
		[[[self window] animator] setAlphaValue:0.0];
		isOpen = NO;
		[self close];
	}
	else {
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
		[[self window] performSelector:@selector(makeKeyAndOrderFront:) withObject:self afterDelay:0];
    
    
		[[[self window] animator] setAlphaValue:1.0];
		isOpen = YES;
	}
}

-(IBAction)displayWindow:(id)sender 
{
  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  [[self window] performSelector:@selector(makeKeyAndOrderFront:) withObject:self afterDelay:0];
  [[[self window] animator] setAlphaValue:1.0];
  isOpen = YES;
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

- (IBAction)newProject:(id)sender
{
  NSRect frame = [containerView bounds];
  NSPoint buildViewOrigin = NSMakePoint(frame.origin.x, frame.origin.y);
  NSPoint startViewOrigin = NSMakePoint(frame.origin.x-frame.size.width, frame.origin.y);
  
  [fileLabel setHidden:YES];
  
  [bottomBarButton setTarget:self];
  [bottomBarButton setAction:@selector(cancelNewProject:)];
  [bottomBarButton setTitle:@"Cancel"];
  
  [[startView animator] setFrameOrigin:startViewOrigin];
  [[buildView animator] setFrameOrigin:buildViewOrigin];
}

- (IBAction)cancelNewProject:(id)sender
{
  [bottomBarButton setTarget:self];
  [bottomBarButton setAction:@selector(openRecentFile:)];
  [bottomBarButton setTitle:@"Open"];
  
  [fileLabel setHidden:NO];
  
  NSRect frame = [containerView bounds];
  NSPoint buildViewOrigin = NSMakePoint(frame.origin.x+frame.size.width, frame.origin.y);
  NSPoint startViewOrigin = NSMakePoint(frame.origin.x, frame.origin.y);
  
  [[startView animator] setFrameOrigin:startViewOrigin];
  [[buildView animator] setFrameOrigin:buildViewOrigin];
  
}

- (IBAction)buildProject:(id)sender 
{
  // get a project director or file from the user  
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setTitle:@"Build New Project..."];
  [panel setRequiredFileType:@"trip"];
  [panel setNameFieldLabel:@"Source:"];
  [panel setCanChooseFiles:YES];
  [panel setCanChooseDirectories:YES];
  [panel setCanCreateDirectories:NO];
  [panel setMessage:@"Choose a main TeX file (one containing \\documentclass) or a directory of TeX files. \nIf a directory is chosen, the first TeX file containing \\documentclass is taken as the main file."];
  [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"tex", NSFileTypeDirectory, nil]];
  
  BOOL result = [panel runModal];
  
  if (result == NSFileHandlingPanelCancelButton) {
    return;
  }
  
  
  NSString *path = [[[panel URLs] objectAtIndex:0] path];
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error =nil;
  NSDictionary *atts = [fm attributesOfItemAtPath:path error:&error];
  if (error) {
    [NSApp presentError:error];
    return;
  }
  TPProjectBuilder *pb = nil;
  if ([atts fileType] == NSFileTypeDirectory) {
    pb = [TPProjectBuilder builderWithDirectory:path];
  } else {
    pb = [TPProjectBuilder builderWithMainfile:path];
  }
  
  // check if the project already exists and ask the user if they want to overwrite it
  // Remove file if it is there
  NSString *docpath = [pb.projectFileURL path];
  if ([fm fileExistsAtPath:docpath]) {
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@".yyyy_MM_dd_HH_mm_ss"];
    NSString *movedPath = [docpath stringByAppendingFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
    
    NSAlert *alert = [NSAlert alertWithMessageText:@"A TeXnicle Project Already Exists"
                                     defaultButton:@"Continue"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@"A project file called %@ already exists in %@.\nIf you continue, the exiting project file will be moved to:\n%@.", [docpath lastPathComponent], [docpath stringByDeletingLastPathComponent], [movedPath lastPathComponent]];
    
    NSInteger result = [alert runModal];
    
    if (result == NSAlertAlternateReturn) {
      return;
    }
    
    NSError *moveError = nil;
    [fm moveItemAtPath:docpath toPath:movedPath error:&moveError];
    if (moveError) {
      [NSApp presentError:moveError];
      return;
    }
  }
  
  [TeXProjectDocument createTeXnicleProjectAtURL:pb.projectFileURL];
  NSError *openError = nil;
  TeXProjectDocument *doc = [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:pb.projectFileURL display:YES error:&openError];
  if (openError) {
    [NSApp presentError:openError];
    return;
  }  
  
  [pb populateDocument:doc];  
  [self displayOrCloseWindow:self];
}

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
