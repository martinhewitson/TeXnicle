//
//  TPProjectTemplateViewer.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/2/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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

#import "TPProjectTemplateViewer.h"
#import "TPProjectTemplateCreator.h"
#import "ProjectItemEntity+ProjectTemplate.h"
#import "Settings+ProjectTemplate.h"
#import "ImageAndTextCell.h"
#import "TPSupportedFilesManager.h"
#import "TPProjectBuilder.h"
#import "TeXProjectDocument.h"

#define kTemplateViewerSplitViewLeftMinSize 200.0
#define kTemplateViewerSplitViewRightMinSize 300.0

@interface TPProjectTemplateViewer ()

@property (strong) ProjectEntity *project;
@property (strong) NSManagedObjectContext *managedObjectContext;
@property (strong) TPTemplateDirectory *root;
@property (unsafe_unretained) IBOutlet NSTextField *templateDescriptionDisplay;
@property (unsafe_unretained) IBOutlet NSOutlineView *outlineView;
@property (unsafe_unretained) IBOutlet NSView *projectNameView;
@property (unsafe_unretained) IBOutlet NSTextField *projectNameField;
@property (copy) NSString *templateName;
@property (copy) NSString *templateDescription;

@property (unsafe_unretained) IBOutlet NSView *leftView;
@property (unsafe_unretained) IBOutlet NSView *rightView;

@property (strong) TeXEditorViewController *texEditorViewController;
@property (unsafe_unretained) IBOutlet NSView *texEditorContainer;


@end

@implementation TPProjectTemplateViewer

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithProject:(ProjectEntity*)aProject name:(NSString*)aName description:(NSString*)aDescription
{
  self = [super init];
  if (self) {
    self.project = aProject;
    self.managedObjectContext = aProject.managedObjectContext;
    self.templateName = aName;
    self.templateDescription = aDescription;
  }
  return self;
}

- (NSString *)windowNibName
{
  // Override returning the nib file name of the document
  // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
  return @"TPProjectTemplateViewer";
}

- (void)windowWillClose:(NSNotification *)notification 
{		
  // stop filemonitor from reaching us
  self.texEditorViewController.delegate = nil;
  
  if ([[[NSDocumentController sharedDocumentController] documents] count] == 0) {
    if ([[NSApp delegate] respondsToSelector:@selector(showStartupScreen:)]) {
      [[NSApp delegate] performSelector:@selector(showStartupScreen:) withObject:self];
    }
  }
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
  [super windowControllerDidLoadNib:aController];
  // Add any code here that needs to be executed once the windowController has loaded the document's window.
  if (self.templateDescription) {
    [self.templateDescriptionDisplay setStringValue:self.templateDescription];
  }  
}


- (void) awakeFromNib
{
  // apply our custom ImageAndTextCell for rendering the first column's cells
	NSTableColumn *tableColumn = [self.outlineView tableColumnWithIdentifier:@"NameColumn"];
	ImageAndTextCell *imageAndTextCell = [[ImageAndTextCell alloc] init];
	[imageAndTextCell setEditable:YES];
	[imageAndTextCell setImage:[NSImage imageNamed:NSImageNameFolderBurnable]];
	[tableColumn setDataCell:imageAndTextCell];
  
  // set up text editor
  self.texEditorViewController = [[TeXEditorViewController alloc] init];
  self.texEditorViewController.delegate = self;
  [self.texEditorViewController.view setFrame:[self.texEditorContainer bounds]];
  [self.texEditorContainer addSubview:self.texEditorViewController.view];
  [self.texEditorViewController disableEditor];
  [self.texEditorViewController disableJumpBar];
  [self.texEditorViewController performSelector:@selector(setString:) withObject:@"" afterDelay:0.0];
  
  
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self
         selector:@selector(handleProjectTemplateOutlineViewSelectionChange:)
             name:NSOutlineViewSelectionDidChangeNotification
           object:self.outlineView];
  
  [nc addObserver:self
         selector:@selector(handleProjectTemplateOutlineViewSelectionIsChanging:)
             name:NSOutlineViewSelectionIsChangingNotification
           object:self.outlineView];
  
  
}

- (void) handleProjectTemplateOutlineViewSelectionIsChanging:(NSNotification*)aNote
{
  // cache the contents
  [self commitCurrentTextViewContents];
}

- (void) commitCurrentTextViewContents
{
  if (selectedItem && [selectedItem isMemberOfClass:[TPTemplateFile class]]) {
    TPTemplateFile *file = (TPTemplateFile*)selectedItem;
    [file setStringContent:[self.texEditorViewController.textView string]];
  }
}

- (void) handleProjectTemplateOutlineViewSelectionChange:(NSNotification*)aNote
{
  TPTemplateFile *file = [self selectedFile];
  if (file) {
    selectedItem = file;
    if (file.stringContent && [file.stringContent length]>0) {
      self.texEditorViewController.delegate = nil; 
      [self.texEditorViewController.textView setSelectedRange:NSMakeRange(0, 1)];
      [self.texEditorViewController setString:file.stringContent];
      [self.texEditorViewController.textView setUpRuler];
      [self.texEditorViewController enableEditor];
      self.texEditorViewController.delegate = self; 
      return;
    }
  }
  
  [self.texEditorViewController disableEditor];
  [self.texEditorViewController setString:@""];
}

- (BOOL)writeSafelyToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError **)outError
{
  [self commitCurrentTextViewContents];
  
  NSFileManager *fm = [NSFileManager defaultManager];
  // make directory
  NSError *error = nil;
  BOOL success = [fm createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
  if (success == NO) {
    [NSApp presentError:error];
    return NO;
  }
  [self.root saveContents];
  return YES;
}

- (BOOL) savePackageContentsFromProject
{
  
  if (!self.project) {
    if (self.managedObjectContext) {
      NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Project"];
      NSError *error = nil;
      NSArray *projects = [self.managedObjectContext executeFetchRequest:request error:&error];
      if ([projects count] > 0) {
        self.project = projects[0];
      }
    }
  }
  
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error = nil;
  BOOL success = [fm createDirectoryAtURL:[self fileURL] withIntermediateDirectories:YES attributes:nil error:&error];
  if (success == NO) {
    [NSApp presentError:error];
    return NO;
  }
  
  // write each included item
  for (ProjectItemEntity *item in self.project.items) {
    if ([[item valueForKey:@"isSelected"] boolValue] && [item valueForKey:@"parent"] == nil) {
      [item writeContentsAndChildrenToURL:[self fileURL]];
    }
  }
  
  // write a settings dictionary
  NSDictionary *settings = [self.project.settings dictionary];
  NSURL *settingsPlist = [[self fileURL] URLByAppendingPathComponent:@"settings.plist"];
  [settings writeToURL:settingsPlist atomically:YES];
  
  // write info dictionary
  NSDictionary *info = @{@"name": self.templateName, @"description": self.templateDescription};
  NSURL *infoPlist = [[self fileURL] URLByAppendingPathComponent:@"info.plist"];
  [info writeToURL:infoPlist atomically:YES];
  
  return YES;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
  // read the file tree
  [self readFileTreeFromURL:absoluteURL];
  
  return YES;
}

- (void) readFileTreeFromURL:(NSURL*)absoluteURL
{
  self.root = [[TPTemplateDirectory alloc] initWithPath:[absoluteURL path]];
  // read info
  NSDictionary *info = [NSDictionary dictionaryWithContentsOfURL:[absoluteURL URLByAppendingPathComponent:@"info.plist"]];
  if (info) {
    self.templateName = [info valueForKey:@"name"];
    self.templateDescription = [info valueForKey:@"description"];
  }
  [self.outlineView reloadData];
}


#pragma mark -
#pragma Control


- (IBAction)createNewProject:(id)sender
{
  // set suggested project name
  NSString *suggestedProjectName = [[[self fileURL] lastPathComponent] stringByDeletingPathExtension];
  [self.projectNameField setStringValue:suggestedProjectName];
  [self.projectNameField setNeedsDisplay:YES];
  
  // get a project directory or file from the user  
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setTitle:@"Location of New Project..."];
  [panel setNameFieldLabel:@"Directory:"];
  [panel setCanChooseFiles:NO];
  [panel setCanChooseDirectories:YES];
  [panel setCanCreateDirectories:YES];
  [panel setAllowsMultipleSelection:NO];
  [panel setMessage:@"Choose a directory where the TeXnicle project will be created."];
  [panel setAccessoryView:self.projectNameView];
  [panel beginSheetModalForWindow:[NSApp keyWindow] completionHandler:^(NSInteger result) {
    
    if (result == NSFileHandlingPanelCancelButton) {
      if (self.delegate && [self.delegate respondsToSelector:@selector(templateViewerDidCancelProjectCreation:)]) {
        [self.delegate performSelector:@selector(templateViewerDidCancelProjectCreation:) withObject:self];
      }
      return;
    }  
    
    // check the project name
    NSString *projectName = self.projectNameField.stringValue;
    if (projectName == nil || [projectName length] == 0) {
      NSAlert *alert = [NSAlert alertWithMessageText:@"Project Name Empty"
                                       defaultButton:@"OK"
                                     alternateButton:nil
                                         otherButton:nil
                           informativeTextWithFormat:@"A project needs a name that isn't empty"];
      [alert runModal];
      
      [self performSelector:@selector(createNewProject:) withObject:self afterDelay:0];
      return;
    }
    
    // create project directory
    NSURL *projectURL = [[panel URL] URLByAppendingPathComponent:self.projectNameField.stringValue isDirectory:YES];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    
    // check there isn't a directory with that name already there
    if ([fm fileExistsAtPath:[projectURL path]]) {
      NSAlert *alert = [NSAlert alertWithMessageText:@"Project Exists"
                                       defaultButton:@"Cancel"
                                     alternateButton:@"Overwrite"
                                         otherButton:nil
                           informativeTextWithFormat:@"A project already exists at the chosen directory. Overwrite?"];
      
      NSInteger result = [alert runModal];
      // if the user said cancel
      if (result == NSAlertDefaultReturn) {
        [self performSelector:@selector(createNewProject:) withObject:self afterDelay:0];
        return;
      }
      
      // remove destination
      error = nil;
      BOOL success = [fm removeItemAtURL:projectURL error:&error];
      if (success == NO) {
        [NSApp presentError:error];
        return;
      }
    }
        
    // copy the files from the template
    BOOL success = [fm copyItemAtPath:[[self fileURL] path] toPath:[projectURL path] error:&error];
    if (success == NO) {
      [NSApp presentError:error];
      return;
    }
    
    // use the project builder to build a project in that directory
    TeXProjectDocument *doc = [TPProjectBuilder buildProjectInDirectory:[projectURL path]];
    
    // read settings and set to project
    NSURL *settingsURL = [projectURL URLByAppendingPathComponent:@"settings.plist"];
    NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfURL:settingsURL];
    Settings *settings = doc.project.settings;
    if (settingsDict) {
      settings.engineName = [settingsDict valueForKey:@"engineName"];
      settings.doBibtex = [settingsDict valueForKey:@"doBibtex"];
      settings.doPS2PDF = [settingsDict valueForKey:@"doPS2PDF"];
      settings.nCompile = [settingsDict valueForKey:@"nCompile"];
      settings.openConsole = [settingsDict valueForKey:@"openConsole"];
      settings.showStatusBar = [settingsDict valueForKey:@"showStatusBar"];
      error = nil;
      BOOL success = [fm removeItemAtURL:settingsURL error:&error];
      if (success == NO) {
        [NSApp presentError:error];
      }
    }
    
    // save the project
    [doc saveDocument:self];
    
    // inform delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(templateViewer:didCreateProject:)]) {
      [self.delegate performSelector:@selector(templateViewer:didCreateProject:) withObject:self withObject:doc];
    }
    
    
  }];
  
}




#pragma mark -
#pragma mark Outline view data source

- (id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  if (item == nil) {
    return (self.root.children)[index];
  }
  
  if ([item isMemberOfClass:[TPTemplateFile class]]) {
    return nil;
  }
  
  TPTemplateDirectory *dir = (TPTemplateDirectory*)item;
  
  return (dir.children)[index];
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  if ([item isMemberOfClass:[TPTemplateFile class]]) {
    return NO;
  }
  TPTemplateDirectory *dir = (TPTemplateDirectory*)item;
  if ([dir.children count] == 0) {
    return NO;
  }
  
  return YES;
}

- (NSInteger) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  if (item == nil) {
    return [self.root.children count];
  }
  
  if ([item isMemberOfClass:[TPTemplateFile class]]) {
    return 0;
  }
  TPTemplateDirectory *dir = (TPTemplateDirectory*)item;
  return [dir.children count]; 
}

- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  NSString *path = [item valueForKey:@"path"];
  return [[path lastPathComponent] stringByDeletingPathExtension];
}

#pragma mark -
#pragma mark Outline view delegate

- (void)outlineView:(NSOutlineView *)anOutlineView 
		willDisplayCell:(id)cell 
		 forTableColumn:(NSTableColumn *)tableColumn 
							 item:(id)item
{
	if ([[tableColumn identifier] isEqualToString:@"NameColumn"]) {
    CGFloat imageSize = 20.0;
    [anOutlineView setRowHeight:imageSize+2.0];
    
    [cell setImageSize:imageSize];
    [cell setTextColor:[NSColor blackColor]];
    
    if ([item isMemberOfClass:[TPTemplateDirectory class]]) {
      if ([[item valueForKey:@"isExpanded"] boolValue]) {
        NSString *folderFileType = NSFileTypeForHFSTypeCode(kOpenFolderIcon);
        [cell setImage:[[NSWorkspace sharedWorkspace] iconForFileType:folderFileType]];		
      } else {
        NSString *folderFileType = NSFileTypeForHFSTypeCode(kGenericFolderIcon);
        [cell setImage:[[NSWorkspace sharedWorkspace] iconForFileType:folderFileType]];		
      }      
    } else {
      NSString *path = [item valueForKey:@"path"];
      NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFileType:[path pathExtension]];				
      [cell setImage:icon];						      
    }
  }	
}

- (void) outlineViewItemDidCollapse:(NSNotification *)notification
{
  id object = [[notification userInfo] valueForKey:@"NSObject"];  
  [object setValue:@NO forKey:@"isExpanded"];
}

- (void) outlineViewItemDidExpand:(NSNotification *)notification
{
  id object = [[notification userInfo] valueForKey:@"NSObject"];  
  [object setValue:@YES forKey:@"isExpanded"];
}

#pragma mark -
#pragma mark TeXEditorController delegate


-(NSString*)fileExtension
{
  return [[[self selectedFile] path] pathExtension];
}

- (BOOL) shouldSyntaxHighlightDocument
{
  if ([self selectedFile] == nil) {
    return YES;
  }
  
	NSString *ext = [[[self selectedFile] path] pathExtension];
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  for (NSString *lext in [sfm supportedExtensionsForHighlighting]) {
    if ([ext isEqual:lext]) {
      return YES;
    }
  }
  return NO;
}

- (TPTemplateFile*)selectedFile
{
  id item = [self.outlineView itemAtRow:[self.outlineView selectedRow]];
  if ([item isMemberOfClass:[TPTemplateFile class]]) {
    return item;
  }
  return nil;
}


#pragma mark -
#pragma mark Split view delegate

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
  //  NSLog(@"Resize with old size %@", NSStringFromSize(oldSize));
  
  NSSize splitViewSize = [sender frame].size;  
  NSSize leftSize = [self.leftView frame].size;
  leftSize.height = splitViewSize.height;
  
  NSSize rightSize;
  rightSize.width = splitViewSize.width;
  rightSize.width -= [sender dividerThickness];
  
  if (![sender isSubviewCollapsed:self.leftView]) {
    rightSize.width -= leftSize.width;
  }
  
  rightSize.height = splitViewSize.height;
  
  if (![sender isSubviewCollapsed:self.leftView]) {
    [self.leftView setFrameSize:leftSize];
  }
  if (![sender isSubviewCollapsed:self.rightView]) {
    [self.rightView setFrameSize:rightSize];
  }
  
  [sender adjustSubviews];
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
  
  if (subview == self.leftView)
    return NO;
  
  
  if (subview == self.rightView) {
    NSRect b = [self.rightView bounds];
    if (b.size.width < kTemplateViewerSplitViewRightMinSize) {
      return NO;
    }
  }
  
  return YES;
}


- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{  
  return NO;
}

- (CGFloat)splitView:(NSSplitView *)aSplitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
  if (dividerIndex == 0) {
    NSRect b = [aSplitView bounds];
    CGFloat max =  b.size.width - kTemplateViewerSplitViewRightMinSize;
    return max;
  }
  
  
  return proposedMax;
}


- (CGFloat)splitView:(NSSplitView *)aSplitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
  if (dividerIndex == 0) {
    return kTemplateViewerSplitViewLeftMinSize;
  }
    
  return proposedMin;
}

@end
