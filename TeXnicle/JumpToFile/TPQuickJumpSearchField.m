//
//  TPQuickJumpSearchField.m
//  TeXnicle
//
//  Created by Martin Hewitson on 13/7/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "TPQuickJumpSearchField.h"
#import "TPQuickJumpViewController.h"

@implementation TPQuickJumpSearchField

- (BOOL) acceptsFirstResponder
{
  //NSLog(@"Accepts first responder?");
  if (self.delegate && [self.delegate respondsToSelector:@selector(isVisible)]) {
    TPQuickJumpViewController *controller = (TPQuickJumpViewController*)self.delegate;
    //NSLog(@"  is visible? %d", controller.isVisible);
    return controller.isVisible;
  }
  
  //NSLog(@"  no");
  return NO;
}

- (BOOL) resignFirstResponder
{
  //NSLog(@"Resign");
//  if (self.delegate && [self.delegate respondsToSelector:@selector(dismiss)]) {
//    [self.delegate performSelector:@selector(dismiss)];
//  }
  return [super resignFirstResponder];
}

@end
