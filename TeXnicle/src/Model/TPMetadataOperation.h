//
//  TPMetadataOperation.h
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPFileEntityMetadata.h"
#import "FileEntity.h"

@interface TPMetadataOperation : NSOperation  {

  NSString *text;
  
  // inputs
  FileEntity *file;
  
  // metadata
  NSArray *commands;
  NSArray *citations;
  NSArray *syntaxErrors;
}

@property (copy) NSString *text;

// inputs
@property (retain) FileEntity *file;

// metadata
@property (retain) NSArray *commands;
@property (retain) NSArray *citations;
@property (retain) NSArray *syntaxErrors;

- (id) initWithFile:(FileEntity*)aFile;

@end
