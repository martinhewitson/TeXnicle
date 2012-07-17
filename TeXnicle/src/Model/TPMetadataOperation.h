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
@property (retain, nonatomic) FileEntity *file;

// metadata
@property (retain, nonatomic) NSArray *commands;
@property (retain, nonatomic) NSArray *citations;
@property (retain, nonatomic) NSArray *syntaxErrors;
@property (retain, nonatomic) NSArray *labels;

- (id) initWithFile:(FileEntity*)aFile;

@end
