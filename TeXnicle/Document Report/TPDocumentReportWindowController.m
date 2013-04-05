//
//  TPDocumentReportWindowController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 17/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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

@property (assign) BOOL generating;

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
  if (self.generating) {
    return;
  }
  
  self.generating = YES;
  [self.includeAllFiles setEnabled:NO];
  [self.includeFreqs setEnabled:NO];
  [self.includeStats setEnabled:NO];
  [self.progressBar startAnimation:self];
  [self.generateButton setEnabled:NO];
  [self.texcount countWordsInTexFile:[self fileToReportOn]];
}

- (void) stopGeneration
{
  self.generating = NO;
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
