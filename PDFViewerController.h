//
//  PDFViewerController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 3/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "HHValidatedButton.h"
#import "MHSlideViewController.h"

@class PDFViewerController;

@protocol PDFViewerControllerDelegate <NSObject>

- (NSString*)documentPathForViewer:(PDFViewerController*)aPDFViewer;

@end


@interface PDFViewerController : NSViewController <NSUserInterfaceValidations, NSTableViewDelegate, NSTableViewDataSource> {
@private
  IBOutlet NSView *pdfViewContainer;
  PDFView *pdfview;
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
  
  MHSlideViewController *slideViewController;
  MHSlideViewController *thumbSlideViewController;
  NSTableView *searchResultsTable;
  NSMutableArray *searchResults;
  
  HHValidatedButton *showSearchResultsButton;
  HHValidatedButton *toggleThumbsButton;
}


@property (retain) NSMutableArray *searchResults;

@property (assign) IBOutlet HHValidatedButton *showSearchResultsButton;
@property (assign) IBOutlet HHValidatedButton *toggleThumbsButton;
@property (assign) IBOutlet NSTableView *searchResultsTable;
@property (assign) IBOutlet MHSlideViewController *slideViewController;
@property (assign) IBOutlet MHSlideViewController *thumbSlideViewController;
@property (assign) IBOutlet PDFView *pdfview;
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

- (IBAction) searchPDF:(id)sender;
- (IBAction) showPreviousResult:(id)sender;
- (IBAction) showNextResult:(id)sender;
- (IBAction)toggleResultsTable:(id)sender;
- (IBAction)toggleThumbsTable:(id)sender;

- (void) selectSearchResult:(NSInteger)index;
- (NSRange)rangeOfSelection:(PDFSelection*)selection;
- (void) highlightSelectedSearchResult;


@end
