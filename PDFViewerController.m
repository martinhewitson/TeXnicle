//
//  PDFViewerController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 3/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "PDFViewerController.h"

#define kToolbarFullHeight 64.0
#define kToolbarReducedHeight 44.0

@implementation PDFViewerController

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
    [self hideViewer];    
  }
  
  return self;
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
  
  return YES;
}

- (void) showViewer
{
  [pdfViewContainer setHidden:NO];
  [self.statusText setHidden:YES];
}

- (void) hideViewer
{
  [pdfViewContainer setHidden:YES];
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
  PDFSelection *selection = [self.searchResults objectAtIndex:_currentHighlightedPDFSearchResult];
  [self.pdfview setCurrentSelection:selection];
  [self.pdfview scrollSelectionToVisible:self];
  [self.pdfview setCurrentSelection:selection animate:YES];
  [self.searchStatusText setStringValue:[NSString stringWithFormat:@"Showing result %d of %d", _currentHighlightedPDFSearchResult+1, [self.searchResults count]]];
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
  PDFSelection *selection = [self.searchResults objectAtIndex:_currentHighlightedPDFSearchResult];
  [self.pdfview setCurrentSelection:selection];
  [self.pdfview scrollSelectionToVisible:self];
  [self.pdfview setCurrentSelection:selection animate:YES];
  [self.searchStatusText setStringValue:[NSString stringWithFormat:@"Showing result %d of %d", _currentHighlightedPDFSearchResult+1, [self.searchResults count]]];
}

- (IBAction) searchPDF:(id)sender
{
  NSString *searchText = [sender stringValue];
  if ([searchText length]==0) {
    [self.searchStatusText setStringValue:@""];
    [self.searchResults removeAllObjects];
    [self.pdfview clearSelection];
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
  }
}



@end
