//
//  TPProjectTemplateListViewer.h
//  TeXnicle
//
//  Created by Martin Hewitson on 6/3/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TPProjectTemplateListViewController.h"
#import "TPProjectTemplateViewer.h"

@interface TPProjectTemplateListViewer : NSWindowController <TPProjectTemplateViewerDelegate>{
@private
  TPProjectTemplateListViewController *listViewController;
  NSView *listViewContainer;
}

@property (retain) TPProjectTemplateListViewController *listViewController;
@property (assign) IBOutlet NSView *listViewContainer;


- (IBAction)cancel:(id)sender;
- (IBAction)createProjectFromSelectedTemplate:(id)sender;
@end
