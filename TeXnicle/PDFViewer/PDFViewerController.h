//
//  PDFViewerController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 3/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
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

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "HHValidatedButton.h"
#import "MHSlideViewController.h"
#import "MHSlidingSplitViewController.h"
#import "MHPDFView.h"

@class PDFViewerController;

@protocol PDFViewerControllerDelegate <NSObject>

- (NSString*)documentPathForViewer:(PDFViewerController*)aPDFViewer;
- (void)pdfview:(MHPDFView*)pdfView didCommandClickOnPage:(NSInteger)pageIndex inRect:(NSRect)aRect atPoint:(NSPoint)aPoint;

@end


@interface PDFViewerController : NSViewController <MHPDFViewDelegate, MHSlidingSplitViewDelegate, NSUserInterfaceValidations, NSTableViewDelegate, NSTableViewDataSource> {
@private
  IBOutlet NSView *pdfViewContainer;
  MHPDFView *pdfview;
  PDFThumbnailView *pdfThumbnailView;
  id<PDFViewerControllerDelegate> delegate;
  NSInteger _currentHighlightedPDFSearchResult;
  
  NSSearchField *searchField;
  NSTextField *statusText;
  NSProgressIndicator *progressIndicator;
  NSTextField *searchStatusText;
  NSView *toolbarView;
  HHValidatedButton *nextButton;
  HHValidatedButton *prevButton;
  HHValidatedButton *zoomInButton;
  HHValidatedButton *zoomOutButton;
  HHValidatedButton *zoomToFitButton;
  HHValidatedButton *printButton;
  
  MHSlidingSplitViewController *searchResultsSlideViewController;
  MHSlidingSplitViewController *thumbSlideViewController;
  NSTableView *searchResultsTable;
  NSMutableArray *searchResults;
  
  HHValidatedButton *showSearchResultsButton;
  HHValidatedButton *toggleThumbsButton;
}


@property (retain) NSMutableArray *searchResults;

@property (assign) IBOutlet HHValidatedButton *showSearchResultsButton;
@property (assign) IBOutlet HHValidatedButton *toggleThumbsButton;
@property (assign) IBOutlet NSTableView *searchResultsTable;
@property (assign) IBOutlet MHSlidingSplitViewController *searchResultsSlideViewController;
@property (assign) IBOutlet MHSlidingSplitViewController *thumbSlideViewController;
@property (assign) IBOutlet MHPDFView *pdfview;
@property (assign) IBOutlet PDFThumbnailView *pdfThumbnailView;
@property (assign) IBOutlet NSSearchField *searchField;
@property (assign) IBOutlet NSTextField *statusText;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) IBOutlet NSTextField *searchStatusText;
@property (assign) IBOutlet NSView *toolbarView;

@property (assign) IBOutlet HHValidatedButton *printButton;
@property (assign) IBOutlet HHValidatedButton *nextButton;
@property (assign) IBOutlet HHValidatedButton *prevButton;
@property (assign) IBOutlet HHValidatedButton *zoomInButton;
@property (assign) IBOutlet HHValidatedButton *zoomOutButton;
@property (assign) IBOutlet HHValidatedButton *zoomToFitButton;

@property (assign) id<PDFViewerControllerDelegate> delegate;

- (id)initWithDelegate:(id<PDFViewerControllerDelegate>)aDelegate;

- (void) setSearchText:(NSString*)searchText;
- (void) redisplayDocument;

- (void) showViewer;
- (void) hideViewer;

- (void) searchForStringInPDF:(NSString*)searchText;
- (BOOL) hasDocument;

- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;
- (IBAction)zoomToFit:(id)sender;

- (IBAction)printPDF:(id)sender;

- (IBAction)findInPDF:(id)sender;
- (IBAction) searchPDF:(id)sender;
- (IBAction) showPreviousResult:(id)sender;
- (IBAction) showNextResult:(id)sender;
- (IBAction)toggleResultsTable:(id)sender;
- (IBAction)toggleThumbsTable:(id)sender;

- (void) selectSearchResult:(NSInteger)index;
- (NSRange)rangeOfSelection:(PDFSelection*)selection;
- (void) highlightSelectedSearchResult;

- (void)restoreVisibleRectFromPersistentString:(NSString*)aString;
- (NSString*)visibleRectForPersisting;


@end
