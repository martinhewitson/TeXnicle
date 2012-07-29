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
- (NSNumber*) maxOutlineDepth;
- (void) didSetMaxOutlineDepthTo:(NSInteger)depth;
- (void) highlightSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(id)aFile;
- (BOOL) shouldGenerateOutline;

- (id) currentFile;
- (NSInteger) locationInCurrentEditor;

@end



@interface TPProjectOutlineViewController : NSViewController <NSTextViewDelegate, TPOutlineBuilderDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource> {
  TPOutlineBuilder *outlineBuilder;
  id<TPProjectOutlineDelegate> __unsafe_unretained delegate;
  NSOutlineView *__unsafe_unretained outlineView;
  NSButton *__unsafe_unretained showDetailsButton;
  NSSlider *__unsafe_unretained depthSlider;
  
  TPSection *__unsafe_unretained currentSection;
}

@property (unsafe_unretained) TPSection *currentSection;
@property (unsafe_unretained) IBOutlet NSSlider *depthSlider;
@property (unsafe_unretained) IBOutlet NSButton *showDetailsButton;
@property (unsafe_unretained) IBOutlet NSOutlineView *outlineView;
@property (strong) TPOutlineBuilder *outlineBuilder;
@property (unsafe_unretained) id<TPProjectOutlineDelegate> delegate;

- (id) initWithDelegate:(id<TPProjectOutlineDelegate>)aDelegate;
- (IBAction) expandAllSections:(id) sender;
- (IBAction) collapseAllSections:(id) sender;
- (IBAction) maxOutlineDepthChanged:(id)sender;
- (void) setOutlineDepth:(NSInteger)depth;
- (void) stop;

@end
