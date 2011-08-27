//
//  Settings.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/08/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ProjectEntity;

@interface Settings : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * engineName;
@property (nonatomic, retain) NSNumber * doBibtex;
@property (nonatomic, retain) NSNumber * doPS2PDF;
@property (nonatomic, retain) NSNumber * nCompile;
@property (nonatomic, retain) NSNumber * openConsole;
@property (nonatomic, retain) ProjectEntity *project;

@end
