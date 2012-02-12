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
@optional
- (NSString*)documentPathForViewer:(PDFViewer*)aPDFViewer;
- (void) findSourceOfText:(NSString*)string;
- (void)pdfview:(MHPDFView*)pdfView didCommandClickOnPage:(NSInteger)pageIndex inRect:(NSRect)aRect atPoint:(NSPoint)aPoint;

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
- (void) redisplayDocument;

- (IBAction)findSource:(id)sender;

@end
