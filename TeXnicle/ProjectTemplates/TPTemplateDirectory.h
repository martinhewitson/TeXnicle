//
//  TPTemplateDirectory.h
//  TeXnicle
//
//  Created by Martin Hewitson on 16/2/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPTemplateItem.h"

@interface TPTemplateDirectory : TPTemplateItem {
@private
  NSArray *children;
}

@property (retain) NSArray *children;



- (void) populateChildren;
- (void) saveContents;



@end
