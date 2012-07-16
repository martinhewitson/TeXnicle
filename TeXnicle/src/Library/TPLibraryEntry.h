//
//  TPLibraryEntry.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TPLibraryCategory;

@interface TPLibraryEntry : NSManagedObject

@property (nonatomic, retain) NSNumber *sortIndex;
@property (nonatomic, retain) NSString * command;
@property (nonatomic, retain) NSNumber * imageIsValid;
@property (nonatomic, retain) NSNumber * isBuiltIn;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) TPLibraryCategory *category;

@end
