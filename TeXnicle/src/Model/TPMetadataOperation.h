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
  NSArray *labels;
}

@property (copy, nonatomic) NSString *text;

// inputs
@property (strong, nonatomic) FileEntity *file;

// metadata
@property (strong, nonatomic) NSArray *commands;
@property (strong, nonatomic) NSArray *citations;
@property (strong, nonatomic) NSArray *syntaxErrors;
@property (strong, nonatomic) NSArray *labels;

- (id) initWithFile:(FileEntity*)aFile;

@end
