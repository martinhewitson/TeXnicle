//
//  TPSpellCheckedFile.h
//  TeXnicle
//
//  Created by Martin Hewitson on 07/07/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileEntity.h"

@interface TPSpellCheckedFile : NSObject {
  
  id file;
  NSDate *lastCheck;
  NSArray *words;
  BOOL needsUpdate;
}

@property (retain) id file;
@property (retain) NSDate *lastCheck;
@property (retain) NSArray *words;
@property (assign) BOOL needsUpdate;

- (id) initWithFile:(id)aFile;
- (NSString*)displayString;

@end
