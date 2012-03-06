//
//  TPProjectTemplateListViewer.m
//  TeXnicle
//
//  Created by Martin Hewitson on 6/3/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPProjectTemplateListViewer.h"
#import "TPProjectTemplateViewer.h"

@implementation TPProjectTemplateListViewer

@synthesize listViewContainer;
@synthesize listViewController;

- (id)init
{
  self = [super initWithWindowNibName:@"TPProjectTemplateListViewer"];
  if (self) {
    // Initialization code here.
    
  }
  
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  
  // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
  
  self.listViewController = [[[TPProjectTemplateListViewController alloc] init] autorelease];
  [self.listViewController.view setFrame:[self.listViewContainer bounds]];
  [self.listViewContainer addSubview:self.listViewController.view];
  
}

- (void) dealloc
{
  self.listViewController = nil;
  [super dealloc];
}

- (IBAction)cancel:(id)sender
{
  [NSApp stopModal];
  [self close];
}

- (IBAction)createProjectFromSelectedTemplate:(id)sender
{
  TPProjectTemplate *selected = [self.listViewController selectedTemplate];
  NSURL *templateURL = [NSURL fileURLWithPath:selected.path];
  NSError *error = nil;
  TPProjectTemplateViewer *viewer = [[TPProjectTemplateViewer alloc] initWithContentsOfURL:templateURL ofType:@"tpt" error:&error];
  viewer.delegate = self;
  
  if (error) {
    [NSApp presentError:error];
    return;
  }
  
  [viewer makeWindowControllers];
  NSWindowController *wc = [[viewer windowControllers] objectAtIndex:0];
  [wc window];
  [viewer createNewProject:sender];
  
}

#pragma mark -
#pragma mark TPProjectTemplateViewer delegate

-(void)templateViewer:(TPProjectTemplateViewer*)viewer didCreateProject:(id)doc
{
  [NSApp stopModal];
  [self close];
}

-(void)templateViewerDidCancelProjectCreation:(TPProjectTemplateViewer*)viewer
{
  [NSApp stopModal];
  [self close];
}



@end
