//
//  MHDocumentController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 26/10/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface MHDocumentController : NSDocumentController {
@private
  id appDelegate;
}

@property (assign) IBOutlet id appDelegate;

@end
