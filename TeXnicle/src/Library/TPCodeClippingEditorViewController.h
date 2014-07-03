//
//  TPCodeClippingEditorViewController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 03/07/14.
//  Copyright (c) 2014 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TPLibraryEntry.h"


@interface TPCodeClippingEditorViewController : NSViewController

@property (strong, nonatomic) TPLibraryEntry *clip;

- (id)initWithPopover:(NSPopover*)aPopover;

@end
