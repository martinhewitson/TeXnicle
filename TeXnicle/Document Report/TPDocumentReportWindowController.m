//
//  TPDocumentReportWindowController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 18/2/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "TPDocumentReportWindowController.h"
#import <WebKit/WebKit.h>

@interface TPDocumentReportWindowController ()

@property (strong) TPTexcountDriver *texcount;

@property (assign) IBOutlet WebView *webView;
@property (assign) IBOutlet NSButton *generateButton;
@property (assign) IBOutlet NSProgressIndicator *progressBar;
@property (assign) IBOutlet NSButton *includeAllFiles;
@property (assign) IBOutlet NSButton *includeStats;
@property (assign) IBOutlet NSButton *includeFreqs;

@end

@implementation TPDocumentReportWindowController

- (id) initWithDelegate:(id<TPDocumentReporterDelegate>)aDelegate
{
  self = [super initWithWindowNibName:@"TPDocumentReportWindowController"];
  if (self) {
    self.delegate = aDelegate;
    self.texcount = [[TPTexcountDriver alloc] initWithDelegate:self];
  }
  
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  
  [self.window setTitle:[NSString stringWithFormat:@"Report for %@", [self documentName]]];
  [self startGeneration];
}

- (IBAction) printReport:(id)sender
{
  [[[[self.webView mainFrame] frameView] documentView]  print:self];
}

- (IBAction)generateReport:(id)sender
{
  [self startGeneration];
}

- (IBAction)includeAllFilesChanged:(id)sender
{
  [self startGeneration];
}

- (IBAction)includeStatsChanged:(id)sender
{
  [self startGeneration];
}

- (IBAction)includeFreqsChanged:(id)sender
{
  [self startGeneration];
}

- (void) startGeneration
{
  [self.includeAllFiles setEnabled:NO];
  [self.includeFreqs setEnabled:NO];
  [self.includeStats setEnabled:NO];
  [self.progressBar startAnimation:self];
  [self.generateButton setEnabled:NO];
  [self.texcount countWordsInTexFile:[self fileToReportOn]];
}

- (void) stopGeneration
{
  [self.includeAllFiles setEnabled:YES];
  [self.includeFreqs setEnabled:YES];
  [self.includeStats setEnabled:YES];
  [self.progressBar stopAnimation:self];
  [self.generateButton setEnabled:YES];
}

- (NSString*)fileToReportOn
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(fileToReportOn)]) {
    return [self.delegate fileToReportOn];
  }
  
  return nil;
}

- (NSString*)documentName
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(documentName)]) {
    return [self.delegate documentName];
  }
  
  return @"Unknown";
}

- (BOOL)texcountShouldGenerateWordFreq:(TPTexcountDriver*)texcount
{
  return [self.includeFreqs state];
}

- (BOOL)texcountShouldGenerateStats:(TPTexcountDriver*)texcount
{
  return [self.includeStats state];
}

- (BOOL)texcountShouldIncludeAllFiles:(TPTexcountDriver*)texcount
{
  return [self.includeAllFiles state];
}


- (void) texcountRunFailed:(TPTexcountDriver *)texcount
{
  [self stopGeneration];
}

- (void) texcountRunDidFinish:(TPTexcountDriver *)texcount
{
  NSString *html = [NSString stringWithFormat:@"%@", texcount.output];
  
  [[self.webView mainFrame] loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
  
  [self stopGeneration];
}

@end
