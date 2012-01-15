//
//  TPProjectBuilderReport.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TPProjectBuilderReport : NSWindowController {
@private
  NSAttributedString *reportString;
  NSTextView *textView;
}

@property (retain) NSAttributedString *reportString;
@property (assign) IBOutlet NSTextView *textView;

- (id)initWithReportString:(NSAttributedString*)str;

@end
