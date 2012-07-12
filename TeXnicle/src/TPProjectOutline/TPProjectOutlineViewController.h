//
//  TPProjectOutlineViewControllerViewController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 11/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TPOutlineBuilder.h"

@protocol TPProjectOutlineDelegate <NSObject>

- (id) mainFile;
- (NSString*) textForFile:(id)aFile;
- (id) fileWithPath:(NSString*)path;
- (NSNumber*) maxOutlineDepth;
- (void) didSetMaxOutlineDepthTo:(NSInteger)depth;
- (void) highlightSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(FileEntity*)aFile;

@end


@interface TPProjectOutlineViewController : NSViewController <NSTextViewDelegate, TPOutlineBuilderDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource> {
  TPOutlineBuilder *outlineBuilder;
  id<TPProjectOutlineDelegate> delegate;
  NSOutlineView *outlineView;
  NSButton *showDetailsButton;
  NSSlider *depthSlider;
}

@property (assign) IBOutlet NSSlider *depthSlider;
@property (assign) IBOutlet NSButton *showDetailsButton;
@property (assign) IBOutlet NSOutlineView *outlineView;
@property (retain) TPOutlineBuilder *outlineBuilder;
@property (assign) id<TPProjectOutlineDelegate> delegate;

- (id) initWithDelegate:(id<TPProjectOutlineDelegate>)aDelegate;
- (IBAction) expandAllSections:(id) sender;
- (IBAction) collapseAllSections:(id) sender;
- (IBAction) maxOutlineDepthChanged:(id)sender;

@end
