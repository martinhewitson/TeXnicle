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

@property (nonatomic, strong) NSNumber *sortIndex;
@property (nonatomic, strong) NSString * command;
@property (nonatomic, strong) NSNumber * imageIsValid;
@property (nonatomic, strong) NSNumber * isBuiltIn;
@property (nonatomic, strong) NSString * uuid;
@property (nonatomic, strong) NSString * code;
@property (nonatomic, strong) NSData * image;
@property (nonatomic, strong) TPLibraryCategory *category;

@end
