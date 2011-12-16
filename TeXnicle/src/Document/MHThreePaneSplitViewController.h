//
//  MHThreePaneSplitViewController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 25/11/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHThreePaneSplitViewController : NSObject <NSSplitViewDelegate, NSWindowDelegate>

@property (assign) IBOutlet NSView *leftView;
@property (assign) IBOutlet NSView *rightView;
@property (assign) IBOutlet NSView *centerView;
@property (assign) IBOutlet NSSplitView *mainSplitView;

@end
