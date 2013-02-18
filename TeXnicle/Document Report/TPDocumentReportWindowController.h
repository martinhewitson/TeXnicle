//
//  TPDocumentReportWindowController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 18/2/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TPTexcountDriver.h"

@protocol TPDocumentReporterDelegate <NSObject>

- (NSString*)fileToCheck;
- (NSString*)documentName;

@end

@interface TPDocumentReportWindowController : NSWindowController <TexcountDriverDelegate, TPDocumentReporterDelegate, NSWindowDelegate>

@property (strong) id<TPDocumentReporterDelegate> delegate;

- (id) initWithDelegate:(id<TPDocumentReporterDelegate>)aDelegate;

@end
