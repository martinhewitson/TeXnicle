//
//  TPProjectTemplateListViewer.m
//  TeXnicle
//
//  Created by Martin Hewitson on 6/3/12.
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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
