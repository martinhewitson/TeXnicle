//
//  MHTableConfigureController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 07/02/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol MHTableConfigureDelegate <NSObject>

- (void)tableConfigureDidAcceptConfiguration;
- (void)tableConfigureDidCancelConfiguration;

@end

@interface MHTableConfigureController : NSWindowController {
@private
  NSUInteger numberOfRows;
  NSUInteger numberOfColumns;
  id<MHTableConfigureDelegate> delegate;
  NSTextField *numRowsField;
  NSTextField *numColsField;
}

@property (assign) id<MHTableConfigureDelegate> delegate;
@property (assign) IBOutlet NSTextField *numRowsField;
@property (assign) IBOutlet NSTextField *numColsField;
@property (assign) NSUInteger numberOfRows;
@property (assign) NSUInteger numberOfColumns;

- (id)initWithDelegate:(id<MHTableConfigureDelegate>)aDelegate;

- (IBAction)cancelClicked:(id)sender;
- (IBAction)okClicked:(id)sender;

@end
