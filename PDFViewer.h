//
//  PDFViewer.h
//  TeXnicle
//
//  Created by Martin Hewitson on 17/12/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFViewerController.h"

@class PDFViewer;

@protocol PDFViewerDelegate <NSObject>

- (NSString*)documentPathForViewer:(PDFViewer*)aPDFViewer;
- (void) findSourceOfText:(NSString*)string;

@end

@interface PDFViewer : NSWindowController <PDFViewerControllerDelegate, PDFViewerDelegate, NSWindowDelegate> {
@private
  PDFViewerController *pdfViewerController;
  id<PDFViewerDelegate> delegate;
  NSView *containerView;
}



@property (retain) PDFViewerController *pdfViewerController;
@property (assign) id<PDFViewerDelegate> delegate;
@property (assign) IBOutlet NSView *containerView;

- (id)initWithDelegate:(id<PDFViewerDelegate>)aDelegate;

- (IBAction)findSource:(id)sender;

@end
