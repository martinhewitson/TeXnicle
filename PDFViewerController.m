//
//  PDFViewerController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 3/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "PDFViewerController.h"
#import "MHSlidingSplitViewController.h"

#define kToolbarFullHeight 64.0
#define kToolbarReducedHeight 44.0

@implementation PDFViewerController

@synthesize pdfThumbnailView;
@synthesize showSearchResultsButton;
@synthesize toggleThumbsButton;
@synthesize searchResultsTable;
@synthesize searchResultsSlideViewController;
@synthesize thumbSlideViewController;
@synthesize pdfview;
@synthesize delegate;
@synthesize searchField;
@synthesize prevButton;
@synthesize nextButton;
@synthesize searchResults;
@synthesize statusText;
@synthesize progressIndicator;
@synthesize searchStatusText;
@synthesize toolbarView;
@synthesize zoomInButton;
@synthesize zoomOutButton;
@synthesize zoomToFitButton;
@synthesize printButton;
@synthesize thumbSizeSlider;


- (id)initWithDelegate:(id<PDFViewerControllerDelegate>)aDelegate
{
  self = [self initWithNibName:@"PDFViewerController" bundle:nil];
  if (self) {
    self.delegate = aDelegate;
  }
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Initialization code here.
    self.searchResults = [NSMutableArray array];
  }
  
  return self;
}

- (void) awakeFromNib
{
  [self hideViewer];    
  [self.searchResultsSlideViewController setDelegate:self];
  [self.searchResultsSlideViewController slideOutAnimated:NO];
  [self.searchResultsTable setTarget:self];
  [self.searchResultsTable setDoubleAction:@selector(highlightSelectedSearchResult)];
  
  [self.thumbSlideViewController setRightSided:NO];
  [self.toggleThumbsButton setState:NSOnState];
  
  [self.thumbSlideViewController setDelegate:self];
  [self.thumbSlideViewController.splitView setNeedsLayout:YES];
  [self.thumbSizeSlider setFloatValue:64.0];
}

- (void) dealloc
{
  self.delegate = nil;
  self.searchResults = nil;
  [super dealloc];
}

- (IBAction)toggleResultsTable:(id)sender
{
  [self.searchResultsSlideViewController toggle:sender];
}

- (IBAction)toggleThumbsTable:(id)sender
{
  if ([self.toggleThumbsButton state] == NSOnState) {
    [self.thumbSizeSlider setEnabled:YES]; 
  } else {
    [self.thumbSizeSlider setEnabled:NO];
  }
  [self.thumbSlideViewController toggle:sender];
}


- (IBAction)setThumbSize:(id)sender
{
  CGFloat s = [sender floatValue];
  [self.pdfThumbnailView setThumbnailSize:NSMakeSize(s, s)];
}

- (IBAction)printPDF:(id)sender
{
  [self.pdfview print:self];
}


- (BOOL) validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
  if (anItem == self.prevButton) {
    if ([self.searchResults count]==0){
      return NO;
    }
  }
  if (anItem == self.nextButton) {
    if ([self.searchResults count]==0){
      return NO;
    }
  }
  if (anItem == self.zoomInButton) {
    if (![self hasDocument]){
      return NO;
    }
  }
  if (anItem == self.zoomOutButton) {
    if (![self hasDocument]){
      return NO;
    }
  }
  if (anItem == self.zoomToFitButton) {
    if (![self hasDocument]){
      return NO;
    }
  }
  if (anItem == self.printButton) {
    if (![self hasDocument]){
      return NO;
    }
  }
  if (anItem == self.toggleThumbsButton) {
    if (![self hasDocument]){
      return NO;
    }
  }
  
  if (anItem == self.showSearchResultsButton) {
    if ([self.searchResults count] == 0) {
      return NO;
    }
  }
  
  return YES;
}

- (void) showViewer
{
  [pdfViewContainer setHidden:NO];
  [self.searchField setEnabled:YES];
  [self.prevButton setEnabled:YES];
  [self.nextButton setEnabled:YES];
  [self.statusText setHidden:YES];
}

- (void) hideViewer
{
  [pdfViewContainer setHidden:YES];
  [self.searchField setEnabled:NO];
  [self.prevButton setEnabled:NO];
  [self.nextButton setEnabled:NO];
  [self.statusText setHidden:NO];
}


- (void) setSearchText:(NSString*)searchText
{
  [self.searchField setStringValue:searchText];
}

- (void) redisplayDocument
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(documentPathForViewer:)]) {
    NSString *path = [self.delegate documentPathForViewer:self];
    if (path) {
      PDFDocument *doc = [[[PDFDocument alloc] initWithURL: [NSURL fileURLWithPath:path]] autorelease];
      if (doc) {
        [doc setDelegate:self];
        [self.pdfview setDocument:doc];
        [self showViewer];
        return;
      }
    }
  }
  
  // else we hide the pdf view
  [self.pdfview setDocument:nil];
  [self hideViewer];  
}

- (void) searchForStringInPDF:(NSString*)searchText
{
  [self.searchResults removeAllObjects];
  [self.searchResultsTable reloadData];
  _currentHighlightedPDFSearchResult = -1;
  [[self.pdfview document] beginFindString:searchText withOptions:NSCaseInsensitiveSearch];
}

- (IBAction) showPreviousResult:(id)sender
{
  if ([self.searchResults count] == 0) {
    return;
  }
  _currentHighlightedPDFSearchResult--;
  if (_currentHighlightedPDFSearchResult < 0) {
    _currentHighlightedPDFSearchResult = [self.searchResults count]-1;
  }
  [self selectSearchResult:_currentHighlightedPDFSearchResult];
  [self.searchResultsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:_currentHighlightedPDFSearchResult] byExtendingSelection:NO];
  [self.searchResultsTable scrollRowToVisible:_currentHighlightedPDFSearchResult];
}

- (IBAction) showNextResult:(id)sender
{
  if ([self.searchResults count] == 0) {
    return;
  }
  _currentHighlightedPDFSearchResult++;
  if (_currentHighlightedPDFSearchResult >= [self.searchResults count]) {
    _currentHighlightedPDFSearchResult = 0;
  }
  [self selectSearchResult:_currentHighlightedPDFSearchResult];
  [self.searchResultsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:_currentHighlightedPDFSearchResult] byExtendingSelection:NO];
  [self.searchResultsTable scrollRowToVisible:_currentHighlightedPDFSearchResult];
}

- (void) selectSearchResult:(NSInteger)index
{
  PDFSelection *selection = [self.searchResults objectAtIndex:index];
  [self.pdfview setCurrentSelection:selection];
  [self.pdfview scrollSelectionToVisible:self];
  [self.pdfview setCurrentSelection:selection animate:YES];
  [self.searchStatusText setStringValue:[NSString stringWithFormat:@"Showing result %d of %d", index+1, [self.searchResults count]]];
}

- (IBAction) searchPDF:(id)sender
{
  NSString *searchText = [sender stringValue];
  if ([searchText length]==0) {
    [self.searchStatusText setStringValue:@""];
    [self.searchResults removeAllObjects];
    [self.pdfview clearSelection];
    [self.searchResultsSlideViewController slideOutAnimated:YES];
    [self.showSearchResultsButton setState:NSOffState];
  } else {
    [self searchForStringInPDF:searchText];
  }
}

- (BOOL) hasDocument
{
  return [self.pdfview document] != nil;
}

- (IBAction)zoomToFit:(id)sender
{
  [self.pdfview setAutoScales:YES];
}

- (IBAction)zoomIn:(id)sender
{
  [self.pdfview zoomIn:self];
}

- (IBAction)zoomOut:(id)sender
{
  [self.pdfview zoomOut:self];
}


#pragma mark -
#pragma mark PDFDocument delegate

- (void)documentDidBeginDocumentFind:(NSNotification *)notification
{
  [searchStatusText setStringValue:@"Searching..."];  
  [self.progressIndicator startAnimation:self];
  [self.prevButton setEnabled:NO];
  [self.nextButton setEnabled:NO];
}

- (void)documentDidEndDocumentFind:(NSNotification *)notification
{
  [self.progressIndicator stopAnimation:self];
  [self.prevButton setEnabled:YES];
  [self.nextButton setEnabled:YES];
  [searchStatusText setStringValue:[NSString stringWithFormat:@"Found %d matches.", [self.searchResults count]]];
  [self showNextResult:self];
}

- (void)documentDidFindMatch:(NSNotification *)notification
{
  PDFSelection *selection = [[notification userInfo] valueForKey:@"PDFDocumentFoundSelection"];
  [self.searchResults addObject:selection];
  [searchStatusText setStringValue:[NSString stringWithFormat:@"Found %d matches...", [self.searchResults count]]];
  if ([self.searchResults count] == 1) {
    [self.pdfview setCurrentSelection:selection];
    [self.pdfview scrollSelectionToVisible:self];
    [self.pdfview setCurrentSelection:selection animate:YES];
  } else if ([self.searchResults count] == 2) {
    [self.searchResultsSlideViewController slideInAnimated:YES];
    [self.showSearchResultsButton setState:NSOnState];
  }
  
  [self.searchResultsTable reloadData];
}

#pragma mark -
#pragma mark Search table delegate

- (void) highlightSelectedSearchResult
{
  NSInteger row = [self.searchResultsTable selectedRow];
  if (row >= 0 && row < [self.searchResults count]) {
    [self selectSearchResult:row];
  }  
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification
{
  [self highlightSelectedSearchResult];
}

#pragma mark -
#pragma mark Search table data source

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
  return [self.searchResults count];
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  if (row <0 || row >= [self.searchResults count]) {
    return nil;
  }
  PDFSelection *selection = [self.searchResults objectAtIndex:row];
  PDFPage *page =  [[selection pages] objectAtIndex:0];
  NSRect r = NSIntegralRect([selection boundsForPage:page]);
  PDFSelection *extendedSelection = [page selectionForRect:r];
  
//  PDFSelection *extendedSelection = [[[PDFSelection alloc] initWithDocument:self.pdfview.document] autorelease];
//  [extendedSelection addSelection:selection];
  [extendedSelection extendSelectionAtStart:10];
  [extendedSelection extendSelectionAtEnd:10];
  NSString *string = [[[extendedSelection string] stringByReplacingOccurrencesOfString:@"\n" withString:@" "] stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
//  NSLog(@"Selection %@", string);
  
  NSMutableAttributedString *att = [[[NSMutableAttributedString alloc] init] autorelease];
  
  NSMutableAttributedString *pageNo = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Page %@", [page label]]] autorelease];
  [pageNo addAttribute:NSForegroundColorAttributeName value:[NSColor lightGrayColor] range:NSMakeRange(0, [pageNo length])];
  
  [att appendAttributedString:pageNo];
  
  NSMutableAttributedString *text = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" ... %@ ...", string]] autorelease];
  [text addAttribute:NSBackgroundColorAttributeName value:[NSColor yellowColor] range:NSMakeRange(15, [[selection string] length])];
  [att appendAttributedString:text];
  

  
//  NSRange selectedRange = [self rangeOfSelection:selection];
//  NSString *selectedString = [page selectionForRange:selectedRange];

  return att;
}

- (NSRange)rangeOfSelection:(PDFSelection*)selection
{
  PDFPage *page =  [[selection pages] objectAtIndex:0];  
  NSRect bounds = [selection boundsForPage:page];
  NSString *selectedString = [selection string];
  NSString *pageString = [page string];
  NSRange startRange = NSMakeRange(0, [pageString length]);
  NSRange r = [pageString rangeOfString:selectedString options:NSLiteralSearch range:startRange];
  while (r.location != NSNotFound) {
    PDFSelection *testSelection = [page selectionForRange:r];
    NSRect testBounds = [testSelection boundsForPage:page];
    if (NSEqualRects(bounds, testBounds)) {
      return r;
    }
    
    r = [pageString rangeOfString:selectedString options:NSLiteralSearch range:NSMakeRange(r.location+1, [pageString length]-r.location-1)];
  }
  
  return NSMakeRange(NSNotFound, 0);
}

#pragma mark -
#pragma mark Sliding splitview delegate

- (void)splitView:(NSSplitView *)aSplitView didCollapseSubview:(NSView *)aView
{
  if (aSplitView == self.thumbSlideViewController.splitView) {
    [self.toggleThumbsButton setState:NSOffState];
  }
  if (aSplitView == self.searchResultsSlideViewController.splitView) {
    [self.showSearchResultsButton setState:NSOffState];
  }
}

- (void)splitView:(NSSplitView *)aSplitView didUncollapseSubview:(NSView *)aView
{
  if (aSplitView == self.thumbSlideViewController.splitView) {
    [self.toggleThumbsButton setState:NSOnState];
  }
  if (aSplitView == self.searchResultsSlideViewController.splitView) {
    [self.showSearchResultsButton setState:NSOnState];
  }
  
}
@end
