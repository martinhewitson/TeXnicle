//
//  TPLogItem.h
//  TeXnicle
//
//  Created by Martin Hewitson on 23/6/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  TPLogUnknown,
  TPLogInfo,
  TPLogWarning,
  TPLogError
} TPLogItemType;

@interface TPLogItem : NSObject

@property (assign) id parent;
@property (copy) NSString *file;
@property (copy) NSString *filepath;
@property (copy) NSString *line;
@property (assign) TPLogItemType type;
@property (copy) NSString *message;
@property (copy) NSString *matchedPhrase;
@property (assign) NSInteger linenumber;
@property (readonly) NSString *typeName;

- (id) initWithFileName:(NSString*)aFile;
- (id) initWithFileName:(NSString*)aFile type:(TPLogItemType)itemType;
- (id) initWithFileName:(NSString*)aFile type:(TPLogItemType)itemType message:(NSString*)aMessage;
- (id) initWithFileName:(NSString*)aFile type:(TPLogItemType)itemType message:(NSString*)aMessage line:(NSInteger)number;
- (id) initWithFileName:(NSString*)aFile type:(TPLogItemType)itemType message:(NSString*)aMessage line:(NSInteger)number matchedPhrase:(NSString*)aPhrase;

@end
