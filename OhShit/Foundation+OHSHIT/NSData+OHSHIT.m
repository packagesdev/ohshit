/*
 Copyright (c) 2016, Stephane Sudre
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 - Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSData+OHSHIT.h"

#include <Security/Security.h>

#import "OHSHITManager+Private.h"

@interface NSData (OHSHIT_Private)

+ (instancetype)OHSHIT_randomData;

- (instancetype)OHSHIT_initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr;
- (instancetype)OHSHIT_initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr;
- (instancetype)OHSHIT_initWithContentsOfFile:(NSString *)path;
- (instancetype)OHSHIT_initWithContentsOfURL:(NSURL *)url;

- (BOOL)OHSHIT_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
- (BOOL)OHSHIT_writeToURL:(NSURL *)url atomically:(BOOL)atomically;
- (BOOL)OHSHIT_writeToFile:(NSString *)path options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr;
- (BOOL)OHSHIT_writeToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr;

@end

@implementation NSData (OHSHIT)

+ (instancetype)OHSHIT_randomData
{
	// Generate a NSData with random contents whose length is between 1 byte and 512 KB.
	
	size_t tBufferLength=arc4random_uniform(512*1024-1)+1;
	
	uint8_t * tBuffer=malloc(tBufferLength*sizeof(uint8_t));
	
	if (tBuffer==NULL)
		return nil;
	
	if (SecRandomCopyBytes(kSecRandomDefault, tBufferLength, tBuffer)!=0)
	{
		free(tBuffer);
		return nil;
	}
	
	return [[self class] dataWithBytesNoCopy:tBuffer length:tBufferLength];
}

#pragma mark -

- (instancetype)OHSHIT_initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:path matchingFailuresTypes:[OHSHITManager readFailureTypes]];
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageNoSimulatedFailure:
			
			break;
			
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
		
		case OHSHITStorageSimulateEmptyFile:
			
			return [[self class] data];
			
		
		case OHSHITStorageSimulateRandomContents:
			
			return [[self class] OHSHIT_randomData];
			
		default:
			
			return nil;
	}
	
	return [self OHSHIT_initWithContentsOfFile:path options:readOptionsMask error:errorPtr];
}

- (instancetype)OHSHIT_initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForURL:url matchingFailuresTypes:[OHSHITManager readFailureTypes]];
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageNoSimulatedFailure:
			
			break;
			
		case OHSHIT_StorageSimulateFileNotFound:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadNoSuchFileError userInfo:@{NSFilePathErrorKey:[url path],
																												NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return nil;
				
		case OHSHIT_StorageSimulateFileMissingIntermediaryDirectory:
				
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadNoSuchFileError userInfo:@{NSFilePathErrorKey:[url path],
																												NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return nil;
				
		case OHSHITStorageSimulateEmptyFile:
				
			return [[self class] data];
				
				
		case OHSHITStorageSimulateRandomContents:
				
			return [[self class] OHSHIT_randomData];
			
		default:
			
			return nil;
	}
	
	return [self OHSHIT_initWithContentsOfURL:url options:readOptionsMask error:errorPtr];
}

- (instancetype)OHSHIT_initWithContentsOfFile:(NSString *)path
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:path matchingFailuresTypes:[OHSHITManager readFailureTypes]];
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageNoSimulatedFailure:
			
			break;
			
		case OHSHITStorageSimulateEmptyFile:
			
			return [[self class] data];
			
			
		case OHSHITStorageSimulateRandomContents:
			
			return [[self class] OHSHIT_randomData];
			
		default:
			
			return nil;
	}
	
	return [self OHSHIT_initWithContentsOfFile:path];
}

- (instancetype)OHSHIT_initWithContentsOfURL:(NSURL *)url
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForURL:url matchingFailuresTypes:[OHSHITManager readFailureTypes]];
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageNoSimulatedFailure:
			
			break;
			
		case OHSHITStorageSimulateEmptyFile:
			
			return [[self class] data];
			
			
		case OHSHITStorageSimulateRandomContents:
			
			return [[self class] OHSHIT_randomData];
			
		default:
			
			return nil;
	}
	
	return [self OHSHIT_initWithContentsOfURL:url];
}

#pragma mark -

- (BOOL)OHSHIT_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:path matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageNoSimulatedFailure:
			
			break;
			
		case OHSHIT_StorageSimulateNoMoreSpace:
			
			if ([self length]==0)
				break;
			
		default:
			
			return NO;
	}
	
	return [self OHSHIT_writeToFile:path atomically:useAuxiliaryFile];
}


- (BOOL)OHSHIT_writeToURL:(NSURL *)url atomically:(BOOL)atomically
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForURL:url matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageNoSimulatedFailure:
			
			break;
			
		case OHSHIT_StorageSimulateNoMoreSpace:
			
			if ([self length]==0)
				break;
			
		default:
			
			return NO;
	}
	
	return [self OHSHIT_writeToURL:url atomically:atomically];
}

- (BOOL)OHSHIT_writeToFile:(NSString *)path options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:path matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	NSError * tUnderlyingError;
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageNoSimulatedFailure:
			
			break;
			
		case OHSHIT_StorageSimulateNoMoreSpace:
			
			if ([self length]==0)
				break;
			
			tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOSPC userInfo:nil];
			
			*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteOutOfSpaceError userInfo:@{NSFilePathErrorKey:path,
																											 NSUnderlyingErrorKey:tUnderlyingError}];
			
			return NO;
		
		case OHSHIT_StorageSimulateReadOnly:
			
			tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EROFS userInfo:nil];
			
			*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteVolumeReadOnlyError userInfo:@{NSFilePathErrorKey:path,
																												 NSUnderlyingErrorKey:tUnderlyingError}];
			
			return NO;
			
		case OHSHIT_StorageSimulateFileWritePermissionDenied:
			
			tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EACCES userInfo:nil];
			
			*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteNoPermissionError userInfo:@{NSFilePathErrorKey:path,
																											   NSUnderlyingErrorKey:tUnderlyingError}];
			
			return NO;
			
		case OHSHIT_StorageSimulateFileMissingIntermediaryDirectory:
			
			tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
			
			*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:@{NSFilePathErrorKey:path,
																										NSUnderlyingErrorKey:tUnderlyingError}];
			
			return NO;
			
		default:
			
			return NO;
	}
	
	return [self OHSHIT_writeToFile:path options:writeOptionsMask error:errorPtr];
}

- (BOOL)OHSHIT_writeToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForURL:url matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageNoSimulatedFailure:
			
			break;
			
		case OHSHIT_StorageSimulateNoMoreSpace:
			
			if ([self length]==0)
				break;
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOSPC userInfo:nil];
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteOutOfSpaceError userInfo:@{NSFilePathErrorKey:[url path],
																												 NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
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
			
			return NO;
	}
	
	return [self OHSHIT_writeToURL:url options:writeOptionsMask error:errorPtr];
}

@end
