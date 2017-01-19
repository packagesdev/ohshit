/*
 Copyright (c) 2016, Stephane Sudre
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 - Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSFileManager+OHSHIT.h"

#import "OHSHITManager+Private.h"

@interface NSFileManager (OHSHIT_Private)

- (BOOL)OHSHIT_createDirectoryAtURL:(NSURL *)url withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes error:(NSError **)errorPtr;
- (BOOL)OHSHIT_createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes error:(NSError **)errorPtr;
- (BOOL)OHSHIT_createDirectoryAtPath:(NSString *)path attributes:(NSDictionary *)attributes;

- (BOOL)OHSHIT_createSymbolicLinkAtURL:(NSURL *)url withDestinationURL:(NSURL *)destURL error:(NSError **)errorPtr;
- (BOOL)OHSHIT_createSymbolicLinkAtPath:(NSString *)path withDestinationPath:(NSString *)destPath error:(NSError **)errorPtr;
- (BOOL)OHSHIT_createSymbolicLinkAtPath:(NSString *)path pathContent:(NSString *)otherpath;

- (NSDictionary *)OHSHIT_attributesOfItemAtPath:(NSString *)path error:(NSError **)errorPtr;

- (BOOL)OHSHIT_copyPath:(NSString *)src toPath:(NSString *)dest handler:(id)handler;
//- (BOOL)OHSHIT_copyItemAtPath:(NSString *)src toPath:(NSString *)dest error:(NSError **)errorPtr;

- (BOOL)OHSHIT_movePath:(NSString *)src toPath:(NSString *)dest handler:(id)handler;
//- (BOOL)OHSHIT_moveItemAtPath:(NSString *)src toPath:(NSString *)dest error:(NSError **)errorPtr;

- (BOOL)OHSHIT_removeItemAtPath:(NSString *)path error:(NSError **)errorPtr;
- (BOOL)OHSHIT_removeFileAtPath:(NSString *)path handler:(id)handler;

- (BOOL)OHSHIT_createFileAtPath:(NSString *)path contents:(NSData *)data attributes:(NSDictionary *)attr;

@end

@implementation NSFileManager (OHSHIT)

- (BOOL)OHSHIT_createDirectoryAtURL:(NSURL *)url withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes error:(NSError **)errorPtr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForURL:url matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	if (tMatchingFailureType==OHSHIT_StorageNoSimulatedFailure)
		return [self OHSHIT_createDirectoryAtURL:url withIntermediateDirectories:createIntermediates attributes:attributes error:errorPtr];
	
	if (errorPtr==NULL)
		return NO;
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageSimulateNoMoreSpace:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOSPC userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteOutOfSpaceError userInfo:@{NSFilePathErrorKey:[url path],
																												 NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			break;
			
		case OHSHIT_StorageSimulateReadOnly:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EROFS userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteVolumeReadOnlyError userInfo:@{NSFilePathErrorKey:[url path],
																													 NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileWritePermissionDenied:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EACCES userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteNoPermissionError userInfo:@{NSFilePathErrorKey:[url path],
																												   NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileMissingIntermediaryDirectory:
			
			if (createIntermediates==YES)
				break;
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:@{NSFilePathErrorKey:[url path],
																											NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		default:
			break;
	}
	
	return NO;
}

- (BOOL)OHSHIT_createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes error:(NSError **)errorPtr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:path matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	if (tMatchingFailureType==OHSHIT_StorageNoSimulatedFailure)
		return [self OHSHIT_createDirectoryAtPath:path withIntermediateDirectories:createIntermediates attributes:attributes error:errorPtr];
	
	if (errorPtr==NULL)
		return NO;
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageSimulateNoMoreSpace:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOSPC userInfo:nil];
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteOutOfSpaceError userInfo:@{NSFilePathErrorKey:path,
																												 NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			break;
			
		case OHSHIT_StorageSimulateReadOnly:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EROFS userInfo:nil];
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteVolumeReadOnlyError userInfo:@{NSFilePathErrorKey:path,
																													 NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileWritePermissionDenied:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EACCES userInfo:nil];
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteNoPermissionError userInfo:@{NSFilePathErrorKey:path,
																												   NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileMissingIntermediaryDirectory:
			
			if (createIntermediates==YES)
				break;
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:@{NSFilePathErrorKey:path,
																											NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		default:
			break;
	}
	
	return NO;
}

- (BOOL)OHSHIT_createDirectoryAtPath:(NSString *)path attributes:(NSDictionary *)attributes
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:path matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	if (tMatchingFailureType!=OHSHIT_StorageNoSimulatedFailure)
		return NO;
	
	return [self OHSHIT_createDirectoryAtPath:path attributes:attributes];
}

#pragma mark -

- (BOOL)OHSHIT_createSymbolicLinkAtURL:(NSURL *)url withDestinationURL:(NSURL *)destURL error:(NSError **)errorPtr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForURL:url matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	if (tMatchingFailureType==OHSHIT_StorageNoSimulatedFailure)
		return [self OHSHIT_createSymbolicLinkAtURL:url withDestinationURL:destURL error:errorPtr];
	
	if (errorPtr==NULL)
		return NO;
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageSimulateNoMoreSpace:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOSPC userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteOutOfSpaceError userInfo:@{NSFilePathErrorKey:[url path],
																												 NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			break;
			
		case OHSHIT_StorageSimulateReadOnly:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EROFS userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteVolumeReadOnlyError userInfo:@{NSFilePathErrorKey:[url path],
																													 NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileWritePermissionDenied:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EACCES userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteNoPermissionError userInfo:@{NSFilePathErrorKey:[url path],
																												   NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileMissingIntermediaryDirectory:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:@{NSFilePathErrorKey:[url path],
																											NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		default:
			break;
	}
	
	return NO;
}

- (BOOL)OHSHIT_createSymbolicLinkAtPath:(NSString *)path withDestinationPath:(NSString *)destPath error:(NSError **)errorPtr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:path matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	if (tMatchingFailureType==OHSHIT_StorageNoSimulatedFailure)
	{
		tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:destPath matchingFailuresTypes:@[@(OHSHIT_StorageSimulateFileNotFound)]];
		
		if (tMatchingFailureType==OHSHIT_StorageNoSimulatedFailure)
			return [self OHSHIT_createSymbolicLinkAtPath:path withDestinationPath:destPath error:errorPtr];
		
		if (errorPtr!=NULL)
		{
			NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
			
			*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:@{NSFilePathErrorKey:destPath,
																										NSUnderlyingErrorKey:tUnderlyingError}];
		}
		
		return NO;
	}
	
	if (errorPtr==NULL)
		return NO;
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageSimulateNoMoreSpace:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOSPC userInfo:nil];
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteOutOfSpaceError userInfo:@{NSFilePathErrorKey:path,
																												 NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			break;
			
		case OHSHIT_StorageSimulateReadOnly:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EROFS userInfo:nil];
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteVolumeReadOnlyError userInfo:@{NSFilePathErrorKey:path,
																													 NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileWritePermissionDenied:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EACCES userInfo:nil];
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteNoPermissionError userInfo:@{NSFilePathErrorKey:path,
																												   NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
		
		case OHSHIT_StorageSimulateFileMissingIntermediaryDirectory:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:@{NSFilePathErrorKey:path,
																											NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		default:
			break;
	}
	
	return NO;
}

- (BOOL)OHSHIT_createSymbolicLinkAtPath:(NSString *)path pathContent:(NSString *)otherpath
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:path matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	if (tMatchingFailureType!=OHSHIT_StorageNoSimulatedFailure)
		return NO;
	
	tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:otherpath matchingFailuresTypes:@[@(OHSHIT_StorageSimulateFileNotFound)]];
	
	if (tMatchingFailureType!=OHSHIT_StorageNoSimulatedFailure)
		return NO;
	
	return [self OHSHIT_createSymbolicLinkAtPath:path pathContent:otherpath];
}

#pragma mark -

- (NSDictionary *)OHSHIT_attributesOfItemAtPath:(NSString *)path error:(NSError **)errorPtr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:path matchingFailuresTypes:[OHSHITManager readFailureTypes]];
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageSimulateFileNotFound:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadNoSuchFileError userInfo:@{NSFilePathErrorKey:path,
																												NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return nil;
			
		case OHSHIT_StorageSimulateFileMissingIntermediaryDirectory:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadNoSuchFileError userInfo:@{NSFilePathErrorKey:path,
																												NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return nil;
			
		case OHSHIT_StorageSimulateFileReadPermissionDenied:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EACCES userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadNoPermissionError userInfo:@{NSFilePathErrorKey:path,
							  NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return nil;
			
		default:
			break;
	}
	
	return [self OHSHIT_attributesOfItemAtPath:path error:errorPtr];
}

#pragma mark -

- (BOOL)OHSHIT_copyPath:(NSString *)src toPath:(NSString *)dest handler:(id)handler
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:src matchingFailuresTypes:[OHSHITManager readFailureTypes]];
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageNoSimulatedFailure:
		case OHSHITStorageSimulateEmptyFile:
		case OHSHITStorageSimulateRandomContents:
			break;
			
		default:
			
			return NO;
	}
	
	tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:src matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	if (tMatchingFailureType!=OHSHIT_StorageNoSimulatedFailure)
		return NO;
	
	return [self OHSHIT_copyPath:src toPath:dest handler:handler];
}

/*- (BOOL)OHSHIT_copyItemAtPath:(NSString *)src toPath:(NSString *)dest error:(NSError **)errorPtr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:src matchingFailuresTypes:[OHSHITManager readFailureTypes]];
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageSimulateFileMissingIntermediaryDirectory:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadNoSuchFileError userInfo:@{NSFilePathErrorKey:src,
																												NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileNotFound:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadNoSuchFileError userInfo:@{NSFilePathErrorKey:src,
																												NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileReadPermissionDenied:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EACCES userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteNoPermissionError userInfo:@{NSFilePathErrorKey:src,
																												  @"NSUserStringVariant":@[@"Copy"],
																												  @"NSDestinationFilePath":dest,
																												  NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		default:
			
			break;
	}
	
	tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:src matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	if (tMatchingFailureType!=OHSHIT_StorageNoSimulatedFailure)
	{
		// To be completed
 
		return NO;
	}
	
	return [self OHSHIT_copyItemAtPath:src toPath:dest error:errorPtr];
}*/

- (BOOL)OHSHIT_movePath:(NSString *)src toPath:(NSString *)dest handler:(id)handler
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:src matchingFailuresTypes:[OHSHITManager readFailureTypes]];
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageNoSimulatedFailure:
		case OHSHITStorageSimulateEmptyFile:
		case OHSHITStorageSimulateRandomContents:
			break;
			
		default:
			
			return NO;
	}
	
	tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:src matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	if (tMatchingFailureType!=OHSHIT_StorageNoSimulatedFailure)
		return NO;
	
	return [self OHSHIT_movePath:src toPath:dest handler:handler];
}

#pragma mark -

- (BOOL)OHSHIT_removeItemAtPath:(NSString *)path error:(NSError **)errorPtr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:path matchingFailuresTypes:@[@(OHSHIT_StorageSimulateFileMissingIntermediaryDirectory),@(OHSHIT_StorageSimulateReadOnly),@(OHSHIT_StorageSimulateFileNotFound)]];
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageSimulateReadOnly:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EROFS userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteVolumeReadOnlyError userInfo:@{NSFilePathErrorKey:path,
																													 NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileMissingIntermediaryDirectory:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:@{NSFilePathErrorKey:path,
																											NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileNotFound:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:@{NSFilePathErrorKey:path,
																											NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
		default:
			break;
	}
	
	tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:[path stringByDeletingLastPathComponent] matchingFailuresTypes:@[@(OHSHIT_StorageSimulateFileWritePermissionDenied)]];
	
	if (tMatchingFailureType!=OHSHIT_StorageNoSimulatedFailure)
	{
		switch(tMatchingFailureType)
		{
			case OHSHIT_StorageSimulateFileWritePermissionDenied:
				
				if (errorPtr!=NULL)
				{
					NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EACCES userInfo:nil];
					
					*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteNoPermissionError userInfo:@{NSFilePathErrorKey:path,
																													   NSUnderlyingErrorKey:tUnderlyingError}];
				}
				
				return NO;
				
			default:
				break;
		}
	}
	
	return [self OHSHIT_removeItemAtPath:path error:errorPtr];
}

- (BOOL)OHSHIT_removeFileAtPath:(NSString *)path handler:(id)handler
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:path matchingFailuresTypes:@[@(OHSHIT_StorageSimulateFileMissingIntermediaryDirectory),@(OHSHIT_StorageSimulateReadOnly),@(OHSHIT_StorageSimulateFileNotFound)]];
	
	if (tMatchingFailureType!=OHSHIT_StorageNoSimulatedFailure)
		return NO;
	
	tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:[path stringByDeletingLastPathComponent] matchingFailuresTypes:@[@(OHSHIT_StorageSimulateFileWritePermissionDenied)]];
	
	if (tMatchingFailureType!=OHSHIT_StorageNoSimulatedFailure)
		return NO;
	
	return [self OHSHIT_removeFileAtPath:path handler:handler];
}

#pragma mark -

- (BOOL)OHSHIT_createFileAtPath:(NSString *)path contents:(NSData *)data attributes:(NSDictionary *)attr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:path matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageNoSimulatedFailure:
			
			break;
			
		case OHSHIT_StorageSimulateNoMoreSpace:
			
			if ([data length]==0)
				break;
			
		default:
			
			return NO;
	}
	
	return [self OHSHIT_createFileAtPath:path contents:data attributes:attr];
}

@end
