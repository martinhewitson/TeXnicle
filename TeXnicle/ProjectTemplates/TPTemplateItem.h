//
//  TPTemplateItem.h
//  TeXnicle
//
//  Created by Martin Hewitson on 18/02/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPTemplateItem : NSObject {
@private
  NSString *path;
  NSNumber *isExpanded;
}

@property (copy) NSString *path;
@property (retain) NSNumber *isExpanded;

- (id) initWithPath:(NSString*)aPath;


- (id) representedObject;

@end
