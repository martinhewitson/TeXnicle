//
//  BookmarkManager.m
//  TeXnicle
//
//  Created by Martin Hewitson on 7/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "BookmarkManager.h"
#import "Bookmark.h"

@implementation BookmarkManager

@synthesize delegate;

- (id)initWithDelegate:(id<BookmarkManagerDelegate>)aDelegate
{
  self = [self initWithNibName:@"BookmarkManager" bundle:nil];
  if (self) {
    self.delegate = aDelegate;
  }
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}


@end
