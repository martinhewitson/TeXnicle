//
//  MHProjectTemplate.h
//  TeXnicle
//
//  Created by Martin Hewitson on 19/02/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPProjectTemplate : NSObject {
@private
  NSString *name;
  NSString *path;
  BOOL isBuiltIn;
  NSString *desc;
}

@property (copy) NSString *name;
@property (copy) NSString *path;
@property (assign) BOOL isBuiltIn;
@property (copy) NSString *desc;

- (id) initWithPath:(NSString*)aPath;

@end
