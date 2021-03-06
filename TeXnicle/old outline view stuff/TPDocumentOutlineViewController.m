//
//  TPDocumentOutlineViewController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 04/01/12.
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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "TPDocumentOutlineViewController.h"
#import "FileEntity.h"
#import "TPDocumentSectionTemplate.h"
#import "NSArray+DocumentTemplates.h"

@implementation TPDocumentOutlineViewController

@synthesize delegate;
@synthesize section;
@synthesize timer;
@synthesize outlineView;
@synthesize builder;

- (id)initWithDelegate:(id<DocumentOutlineDelegate>)aDelegate
{
  self = [super initWithNibName:@"TPDocumentOutlineViewController" bundle:nil];
  if (self) {
    // Initialization code here.
    self.delegate = aDelegate;
    self.builder = [TPDocumentOutlineBuilder outlineBuilderWithDelegate:self];    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(reloadData)
                                                userInfo:nil
                                                 repeats:YES];
  }
  
  return self;
}

- (void) dealloc
{
  [self.timer invalidate];
  self.timer = nil;
  self.delegate = nil;
  self.builder = nil;
  self.section = nil;
  [super dealloc];
}


- (void) awakeFromNib
{
  NSLog(@"TPDocumentOutlineViewController awake from nib");

}

#pragma mark -
#pragma mark outline view data source

- (void) reloadData
{
	// start from the main doc
	if (self.delegate == nil) {
    self.section = nil;
		return;
  }
  
  if (![self.delegate respondsToSelector:@selector(shouldGenerateOutline)]) {
    self.section = nil;
    return;
  }
  
  BOOL shouldGenerate = [self.delegate shouldGenerateOutline];
  
  if (self.delegate == nil || !shouldGenerate) {
    self.section = nil;
    return;
  }
  
  if (self.section == nil) { // just for testing...
    self.section = [self.builder buildDocumentOutline];
//    NSLog(@"Section %@", self.section);
  }
  
  [outlineView setNeedsDisplay:YES];
  
  //	generating = NO;
}



- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
//  NSLog(@"Getting child %ld of %@", index, item);
  if (item == nil) {
//    NSLog(@"  returning %@", self.section);
    return self.section;
  }
  
  return [[item valueForKey:@"subsections"] objectAtIndex:index];
}

-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
//  NSLog(@"Getting number of children of %@", item);
  if (item == nil) {
    return 1;
  }
  
  return [[item valueForKey:@"subsections"] count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForItem:(id)item
{
//  NSLog(@"Getting value for item %@", item);
  NSString *name = [item valueForKey:@"name"];
  NSMutableAttributedString *attStr = [[[NSMutableAttributedString alloc] initWithString:name] autorelease];
  NSRange strRange = NSMakeRange(0, [name length]);
  [attStr addAttribute:NSFontAttributeName 
                 value:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]
                 range:strRange];

  
  return attStr;
}

- (NSUInteger)outlineView:(TPDocumentOutlineView*)outlineView indentLevelForItem:(id)item
{
  if ([item isKindOfClass:[TPDocumentSection class]]) {
    TPDocumentSection *sectionItem = (TPDocumentSection*)item;
    return sectionItem.type.order;
  }
  
  return 0;
}


#pragma mark -
#pragma mark Delegate


- (ProjectEntity*)project
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(project)]) {
    return [self.delegate project];
  }
  return nil;
}

- (NSURL*)fileURL
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(fileURL)]) {
    return [self.delegate fileURL];
  }
  return nil;
}

- (NSAttributedString*)documentString
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(documentString)]) {
    return [self.delegate documentString];
  }
  return nil;
}

- (void) highlightSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(id)aFile
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(highlightSearchResult:withRange:inFile:)]) {
    [self.delegate highlightSearchResult:result withRange:aRange inFile:aFile];
  }
}

- (BOOL) shouldGenerateOutline
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(shouldGenerateOutline)]) {
    return [self.delegate shouldGenerateOutline];
  }
  return NO;
}

@end
