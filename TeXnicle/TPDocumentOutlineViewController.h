//
//  TPDocumentOutlineViewController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 04/01/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TPDocumentSection.h"
#import "TPDocumentOutlineBuilder.h"
#import "TPDocumentOutlineView.h"

@class ProjectEntity;


@protocol DocumentOutlineDelegate <NSObject>
@optional
- (ProjectEntity*)project;
- (NSURL*)fileURL;
- (NSAttributedString*)documentString;
- (void) highlightSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(id)aFile;
- (BOOL) shouldGenerateOutline;

@end

@interface TPDocumentOutlineViewController : NSViewController <DocumentOutlineViewDataSource, DocumentOutlineViewDelegate, DocumentOutlineDelegate, DocumentOutlineBuilderDelegate> {
@private
  IBOutlet id<DocumentOutlineDelegate> delegate;
  TPDocumentSection *section;
  NSTimer *timer;
  TPDocumentOutlineBuilder *builder;
  IBOutlet TPDocumentOutlineView *outlineView;
}

@property (assign) IBOutlet id<DocumentOutlineDelegate> delegate;
@property (retain) TPDocumentSection *section;
@property (retain) NSTimer *timer;
@property (retain) TPDocumentOutlineBuilder *builder;
@property (assign) IBOutlet TPDocumentOutlineView *outlineView;

- (id)initWithDelegate:(id<DocumentOutlineDelegate>)aDelegate;



@end
