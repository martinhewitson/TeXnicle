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
- (id) focusFile;
- (NSArray*) allMetadataFiles;
- (NSString*) textForFile:(id)aFile;
- (NSNumber*) maxOutlineDepth;
- (void) didSetMaxOutlineDepthTo:(NSInteger)depth;
- (void) highlightSearchResult:(NSString*)result withRange:(NSRange)aRange inFile:(id)aFile;
- (void) syncPDFToRange:(NSRange)aRange;
- (BOOL) shouldGenerateOutline;

- (id) currentFile;
- (NSInteger) locationInCurrentEditor;

@end



@interface TPProjectOutlineViewController : NSViewController <NSTextViewDelegate, TPOutlineBuilderDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource>

@property (strong) TPOutlineBuilder *outlineBuilder;
@property (unsafe_unretained) id<TPProjectOutlineDelegate> delegate;

- (id) initWithDelegate:(id<TPProjectOutlineDelegate>)aDelegate;
- (IBAction) expandAllSections:(id) sender;
- (IBAction) collapseAllSections:(id) sender;
- (IBAction) maxOutlineDepthChanged:(id)sender;
- (void) setOutlineDepth:(NSInteger)depth;
- (void) start;
- (void) stop;
- (void) tearDown;

@end
