//
//  TPTemplateFile.h
//  TeXnicle
//
//  Created by Martin Hewitson on 16/2/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPTemplateItem.h"

@interface TPTemplateFile : TPTemplateItem {
@private
  NSString *stringContent;
  NSData   *dataContent;
}

@property (copy) NSString *stringContent;
@property (retain) NSData *dataContent;

- (void) readContent;
- (void) saveContent;

@end
