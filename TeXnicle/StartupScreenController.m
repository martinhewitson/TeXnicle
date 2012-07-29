//
//  NewProjectAssistantController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 28/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
//
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

#import "StartupScreenController.h"
#import "TeXProjectDocument.h"
#import "TPDescriptionView.h"
#import "TPProjectTemplateViewer.h"
#import "TPProjectTemplate.h"

@interface StartupScreenController ()

@property (readwrite, assign) BOOL isOpen;

@property (strong) TPProjectTemplateListViewController *templateListViewController;
@property (unsafe_unretained) IBOutlet NSView *templateListContainer;

@end

@implementation StartupScreenController


- (id) init
{
  //	NSLog(@"Startup init");
	self =  [super initWithWindowNibName:@"StartupScreen"];
  if (self) {
    
    _recentFiles = [[NSMutableArray alloc] init];
    query = [[NSMetadataQuery alloc] init];
    texnicleFiles = [[NSMutableArray alloc] init];
    
    // setup our Spotlight notifications 
    NSNotificationCenter *nf = [NSNotificationCenter defaultCenter];
    [nf addObserver:self selector:@selector(queryNotification:) name:nil object:query];    
	}
	return self;
}




- (void) awakeFromNib
{
    
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
  [templateView setFrameOrigin:p];
  [containerView addSubview:templateView];
  
  
  NSColor *backgroundColor = [NSColor colorWithDeviceWhite:1.0 alpha:0.8];
  [emptyProjectDescription setDescriptionText:@"Creates a new empty TeXnicle project ready to be populated with files."];
  [emptyProjectDescription setBackgroundColor:backgroundColor];
  [newArticleDescription setDescriptionText:@"Creates a new TeXnicle project with a standard article main file and folders for additional TeX files and images."];
  [newArticleDescription setBackgroundColor:backgroundColor];
  [fromTemplateDescription setDescriptionText:@"Create a new TeXnicle project from one of your project templates."];
  [fromTemplateDescription setBackgroundColor:backgroundColor];
  [buildProjectDescription setDescriptionText:@"Creates a new TeXnicle project containing the files referenced by a main file. Choose either a TeX file or a directory. If a directory is choosen, the main file used is the first file found that contains \\documentclass command."];  
  [buildProjectDescription setBackgroundColor:backgroundColor];
  
  [fileLabel setBorderColor:[NSColor clearColor]];
  [fileLabel.descriptionCell setWraps:NO];
  [fileLabel.descriptionCell setLineBreakMode:NSLineBreakByTruncatingMiddle];
  
  self.templateListViewController = [[TPProjectTemplateListViewController alloc] init];
  [self.templateListViewController.view setFrame:self.templateListContainer.bounds];
  [self.templateListContainer addSubview:self.templateListViewController.view];
}

- (void) handleRecentFilesSelectionChanged:(NSNotification*)aNote
{	
  [self updateFilepathLabel];
}

- (BOOL) validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
  if (anItem == createBtn) {
    if ([self.templateListViewController selectedTemplate] == nil) {
      return NO;
    }
  }
  
  return YES;
}

- (void) updateFilepathLabel
{
  NSInteger row = [recentFilesTable selectedRow];
	if (row>=0) {
    NSString *path = [[self.recentFiles[row] valueForKey:@"url"] path];
    [fileLabel setDescriptionText:path];
    [fileLabel setNeedsDisplay:YES];
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
	if(self.isOpen) {
		[[[self window] animator] setAlphaValue:0.0];
		self.isOpen = NO;
		[self close];
	}
	else {
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
		[[self window] performSelector:@selector(makeKeyAndOrderFront:) withObject:self afterDelay:0];
    
    
		[[[self window] animator] setAlphaValue:1.0];
		self.isOpen = YES;
	}
}

-(IBAction)displayWindow:(id)sender 
{
  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  [[self window] performSelector:@selector(makeKeyAndOrderFront:) withObject:self afterDelay:0];
  [[[self window] animator] setAlphaValue:1.0];
  self.isOpen = YES;
}

#pragma mark -
#pragma mark Recent Files Table Delegate

- (void)tableView:(NSTableView *)aTableView 
	willDisplayCell:(id)aCell 
	 forTableColumn:(NSTableColumn *)aTableColumn 
							row:(NSInteger)rowIndex
{
  if (self.recentFiles != nil) {
    NSDictionary *dict = self.recentFiles[rowIndex];
    NSString *path = [[dict valueForKey:@"url"] path];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
      [aCell setTextColor:[NSColor blackColor]];
    } else {
      [aCell setTextColor:[NSColor redColor]];
    }
  }	
}

- (NSString *)tableView:(NSTableView *)aTableView 
				 toolTipForCell:(NSCell *)aCell 
									 rect:(NSRectPointer)rect 
						tableColumn:(NSTableColumn *)aTableColumn 
										row:(NSInteger)row 
					mouseLocation:(NSPoint)mouseLocation
{
	NSDictionary *dict = self.recentFiles[row];
	return [[dict valueForKey:@"url"] path];
}


#pragma mark -
#pragma mark Project controls

- (IBAction)createProjectFromSelectedTemplate:(id)sender
{
  TPProjectTemplate *selected = [self.templateListViewController selectedTemplate];
  NSURL *templateURL = [NSURL fileURLWithPath:selected.path];
  NSError *error = nil;
  TPProjectTemplateViewer *viewer = [[TPProjectTemplateViewer alloc] initWithContentsOfURL:templateURL ofType:@"tpt" error:&error];
  if (viewer == nil) {
    [NSApp presentError:error];
    return;
  }
  
  [viewer makeWindowControllers];
  NSWindowController *wc = [viewer windowControllers][0];
  [wc window];
  [viewer createNewProject:sender];
  [self displayOrCloseWindow:self];
}

- (IBAction)newProjectFromTemplate:(id)sender
{
  [self.templateListViewController refreshList];
  
  NSRect frame = [containerView bounds];
  NSPoint templateViewOrigin = NSMakePoint(frame.origin.x, frame.origin.y);
  NSPoint buildViewOrigin = NSMakePoint(frame.origin.x-frame.size.width, frame.origin.y);
  
  [fileLabel setHidden:YES];
  [createBtn setHidden:NO];
  
  [bottomBarButton setTarget:self];
  [bottomBarButton setAction:@selector(cancelTemplateProject:)];
  [bottomBarButton setTitle:@"Cancel"];
  
  [[buildView animator] setFrameOrigin:buildViewOrigin];
  [[templateView animator] setFrameOrigin:templateViewOrigin];
}

- (IBAction)cancelTemplateProject:(id)sender
{
  [bottomBarButton setTarget:self];
  [bottomBarButton setAction:@selector(cancelNewProject:)];
  [bottomBarButton setTitle:@"Cancel"];
  
  [fileLabel setHidden:YES];
  [createBtn setHidden:YES];
  
  NSRect frame = [containerView bounds];
  NSPoint templateViewOrigin = NSMakePoint(frame.origin.x+frame.size.width, frame.origin.y);
  NSPoint buildViewOrigin = NSMakePoint(frame.origin.x, frame.origin.y);
  
  [[buildView animator] setFrameOrigin:buildViewOrigin];
  [[templateView animator] setFrameOrigin:templateViewOrigin];
  
}

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

- (IBAction)buildNewProject:(id)sender
{
  id delegate = [[NSApplication sharedApplication] delegate];
  if (delegate && [delegate respondsToSelector:@selector(buildNewProject:)]) {
    [delegate buildNewProject:sender];
    if ([[[NSDocumentController sharedDocumentController] documents] count]>0) {
      [self displayOrCloseWindow:self];
    }
  }
}

- (IBAction) newEmptyProject:(id)sender
{
  id delegate = [NSApp delegate];
  if (delegate && [delegate respondsToSelector:@selector(newEmptyProject:)]) {
    [delegate newEmptyProject:sender];
    if ([[[NSDocumentController sharedDocumentController] documents] count]>0) {
      [self displayOrCloseWindow:self];
    }
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
    
    NSURL *url = [self.recentFiles[row] valueForKey:@"url"];
    
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
      id doc = [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:url
                                                                                      display:YES
                                                                                        error:&error];
      if (doc == nil) {
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
  id delegate = [NSApp delegate];
  if (delegate && [delegate respondsToSelector:@selector(newArticleDocument:)]) {
    [delegate newArticleDocument:sender];
    if ([[[NSDocumentController sharedDocumentController] documents] count]>0) {
      [self displayOrCloseWindow:self];
    }
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
      dict[@"url"] = url;
      [self.recentFiles addObject:dict];
    }
  } else {
    [recentBtn setState:NSOffState];
    [self.recentFiles addObjectsFromArray:texnicleFiles];
  }
  
  [recentFilesController setContent:self.recentFiles];
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
      NSMetadataItem* item = results[i];
      
      NSString* storePath = [[item valueForAttribute:
                              (NSString *)kMDItemPath] stringByResolvingSymlinksInPath];
      
      if ((storePath != nil) && ([storePath length] > 0))
      {
        // create a URL for the represented path and look for an existing store
        NSURL* storeURL = [NSURL fileURLWithPath: storePath];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:[[storeURL path] lastPathComponent]
                                                                       forKey:@"path"];
        dict[@"url"] = storeURL;
        [texnicleFiles addObject:dict];
        NSLog(@"Found %@", storeURL);
      }
    }
  }
}

@end
