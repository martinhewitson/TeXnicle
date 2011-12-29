//
//  MHSlideViewController.h
//  SlidePanel
//
//  Created by Martin Hewitson on 31/10/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHSlideViewController : NSObject {
@private
  NSView *sidePanel;
  NSView *mainPanel;
  NSView *contentView;
  BOOL _sidePanelisVisible;
}

@property (assign) IBOutlet NSView *sidePanel;
@property (assign) IBOutlet NSView *mainPanel;
@property (assign) IBOutlet NSView *contentView;


- (IBAction)togglePanel:(id)sender;
- (void) slideInAnimate:(BOOL)animate;
- (void) slideOutAnimate:(BOOL)animate;

@end
