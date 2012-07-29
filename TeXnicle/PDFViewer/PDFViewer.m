//
//  PDFViewer.m
//  TeXnicle
//
//  Created by Martin Hewitson on 17/12/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
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

#import "PDFViewer.h"
#import "TPEngineManager.h"

@interface PDFViewer ()

@property (unsafe_unretained) IBOutlet NSView *containerView;

@end

@implementation PDFViewer

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
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  self.delegate = nil;
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

- (void) redisplayDocument
{
  NSView *view = [self.pdfViewerController.pdfview documentView];    
  NSRect r = [view visibleRect];
  BOOL hasDoc = [self.pdfViewerController hasDocument];
  [self.pdfViewerController redisplayDocument];
  if (hasDoc) {
    [view scrollRectToVisible:r];
  }  
}

- (void) windowDidBecomeKey:(NSNotification *)notification
{
  [self redisplayDocument];
}

- (void) handleCompileDidFinishNotification:(NSNotification*)aNote
{
  [self redisplayDocument];
}

- (void) handleDidTrashFilesNotification:(NSNotification*)aNote
{
  [self redisplayDocument];
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
  self.pdfViewerController = [[PDFViewerController alloc] initWithDelegate:self];
  [self.pdfViewerController.view setFrame:[self.containerView bounds]];
  [self.containerView addSubview:self.pdfViewerController.view];
  [self.pdfViewerController showViewer];
  [self redisplayDocument];
  
  [self.pdfViewerController.liveUpdateButton setHidden:YES];
}

- (IBAction)buildProject:(id)sender
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(buildProject:)]) {
    [self.delegate performSelector:@selector(buildProject:) withObject:self];
  }
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

#pragma mark -
#pragma mark MHPDFView delegate

- (void)pdfview:(MHPDFView*)pdfView didCommandClickOnPage:(NSInteger)pageIndex inRect:(NSRect)aRect atPoint:(NSPoint)aPoint
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(pdfview:didCommandClickOnPage:inRect:atPoint:)]) {
    [self.delegate pdfview:pdfView didCommandClickOnPage:pageIndex inRect:aRect atPoint:aPoint];
  }
}

@end
