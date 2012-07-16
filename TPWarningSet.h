//
//  TPWarningSet.h
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FileEntity;

@interface TPWarningSet : NSObject {
  id file;
  NSArray *errors;
}

@property (retain) NSArray *errors;
@property (assign) id file;
@property (readonly) NSString *name;

- (id) initWithFile:(FileEntity*)aFile errors:(NSArray*)someErrors;

@end
