//
//  TPProjectBuilderReport.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPProjectBuilderReport.h"

@implementation TPProjectBuilderReport

@synthesize reportString;
@synthesize textView;

- (id)initWithReportString:(NSAttributedString*)str
{
  self = [super initWithWindowNibName:@"TPProjectBuilderReport" owner:self];
  if (self) {
    self.reportString = str;
  }
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
    
  [[self.textView textStorage] setAttributedString:self.reportString];
}

@end
