//
//  MHSlideViewController.h
//  SlidePanel
//
//  Created by Martin Hewitson on 31/10/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHStrokedFiledView.h"

@interface MHSlideViewController : NSObject {
@private
  MHStrokedFiledView *sidePanel;
  NSView *mainPanel;
  NSView *contentView;
}

@property (assign) IBOutlet MHStrokedFiledView *sidePanel;
@property (assign) IBOutlet NSView *mainPanel;
@property (assign) IBOutlet NSView *contentView;


- (IBAction)togglePanel:(id)sender;
- (void) slideInAnimate:(BOOL)animate;
- (void) slideOutAnimate:(BOOL)animate;

@end
