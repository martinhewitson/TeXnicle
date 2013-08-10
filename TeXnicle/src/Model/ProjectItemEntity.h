//
//  ProjectItemEntity.h
//  TeXnicle
//
//  Created by Martin Hewitson on 26/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Cocoa/Cocoa.h>
#import "ProjectEntity.h"

@interface ProjectItemEntity : NSManagedObject {

	BOOL isLeaf;
	BOOL isManaged;
	BOOL isUnderProject;
	BOOL hasEdits;
  BOOL _isSelected;
}

// core data properties
@property (nonatomic, copy) NSString * filepath;
@property (nonatomic, strong) NSNumber * isExpanded;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, strong) NSNumber * sortIndex;
@property (nonatomic, strong) NSSet *children;
@property (nonatomic, unsafe_unretained) ProjectItemEntity *parent;
@property (nonatomic, unsafe_unretained) ProjectEntity *project;

// other properties
@property (nonatomic, assign) BOOL isSelected;
@property (unsafe_unretained, readonly) NSString *pathRelativeToProject;
@property (unsafe_unretained, readonly) NSString *projectPath;
@property (unsafe_unretained, readonly) NSString *pathOnDisk;
@property (unsafe_unretained, readonly) NSString *shortName;
@property (readonly) NSAttributedString *displayName;
@property (readonly) BOOL existsOnDisk;
@property (readonly) BOOL isLeaf;
@property (readonly) BOOL isManaged;
@property (readonly) BOOL isUnderProject;
@property (nonatomic, readwrite) BOOL hasEdits;

- (BOOL) isUnderPath:(NSString*)aPath;
//- (BOOL) hasEdits;
- (void) resetFilePath;

@end
