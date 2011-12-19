//
//  PDFViewer.m
//  TeXnicle
//
//  Created by Martin Hewitson on 17/12/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import "PDFViewer.h"
#import "TPEngineManager.h"

@implementation PDFViewer

@synthesize pdfViewerController;
@synthesize delegate;
@synthesize containerView;

- (id)initWithDelegate:(id<PDFViewerDelegate>)aDelegate
{
  self = [super initWithWindowNibName:@"PDFViewer"];
  if (self) {
    self.delegate = aDelegate;
  }
  
  return self;
}

- (void) dealloc
{
  self.pdfViewerController = nil;
  [super dealloc];
}

- (void) awakeFromNib
{
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  
  [nc addObserver:self
         selector:@selector(handleCompileDidFinishNotification:)
             name:TPEngineCompilingCompletedNotification
           object:nil];
  
  [nc addObserver:self
         selector:@selector(handleDidTrashFilesNotification:)
             name:TPEngineDidTrashFilesNotification
           object:nil];
  
  
}

- (void) windowDidBecomeKey:(NSNotification *)notification
{
  [self.pdfViewerController redisplayDocument];
}

- (void) handleCompileDidFinishNotification:(NSNotification*)aNote
{
  [self.pdfViewerController redisplayDocument];
}

- (void) handleDidTrashFilesNotification:(NSNotification*)aNote
{
  [self.pdfViewerController redisplayDocument];
}


- (IBAction)findSource:(id)sender
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(findSourceOfText:)]) {
    NSString *string = [[self.pdfViewerController.pdfview currentSelection] string];
    [self.delegate findSourceOfText:string];
 }
}


- (void)windowDidLoad
{
  [super windowDidLoad];
  
  // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
  self.pdfViewerController = [[[PDFViewerController alloc] initWithDelegate:self] autorelease];
  [self.pdfViewerController.view setFrame:[self.containerView bounds]];
  [self.containerView addSubview:self.pdfViewerController.view];
  [self.pdfViewerController showViewer];
  [self.pdfViewerController redisplayDocument];
}

- (NSString*)documentPathForViewer:(PDFViewerController *)aPDFViewer
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(documentPathForViewer:)]) {    
    NSString *path = [self.delegate documentPathForViewer:self];
    if (path == nil) {
      [self.pdfViewerController hideViewer];
      [self.window setTitle:@"No PDF"];
      return nil;
    }
    
    [self.window setTitle:[path lastPathComponent]];
    
    return path;
  }
  return nil;
}

@end