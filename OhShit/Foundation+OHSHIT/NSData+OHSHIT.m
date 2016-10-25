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

#import "NSObject+OHSHIT.h"

#import "OHSHITManager+Private.h"

@interface NSData (OHSHIT_Private)

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

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSData OHSHIT_start];
	});
}

#pragma mark -

- (instancetype)OHSHIT_initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager defaultManager] failureTypeForPath:path matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageNoSimulatedFailure:
			
			break;
			
		case OHSHIT_StorageSimulateFileNotFound:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:@{}];
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadNoSuchFileError userInfo:@{OHSHITFilePathKey:path,
																												OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return nil;
			
		case OHSHITStorageSimulateEmptyFile:
			
			return [[self class] data];
			
		case OHSHIT_StorageSimulateFileMissingIntermediaryDirectory:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:@{}];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadNoSuchFileError userInfo:@{OHSHITFilePathKey:path,
																												OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return nil;
			
		default:
			
			return nil;
	}
	
	return [self OHSHIT_initWithContentsOfFile:path options:readOptionsMask error:errorPtr];
}

- (instancetype)OHSHIT_initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager defaultManager] failureTypeForURL:url matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	switch(tMatchingFailureType)
	{
	case OHSHIT_StorageNoSimulatedFailure:
		
		break;
		
	case OHSHIT_StorageSimulateFileNotFound:
		
		if (errorPtr!=NULL)
		{
			NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:@{}];
			
			*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadNoSuchFileError userInfo:@{OHSHITFilePathKey:[url path],
																											OHSHITUnderlyingErrorKey:tUnderlyingError}];
		}
		
		return nil;
		
	case OHSHITStorageSimulateEmptyFile:
		
		return [[self class] data];
			
	case OHSHIT_StorageSimulateFileMissingIntermediaryDirectory:
			
		if (errorPtr!=NULL)
		{
			NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:@{}];
			
			*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadNoSuchFileError userInfo:@{OHSHITFilePathKey:[url path],
																											OHSHITUnderlyingErrorKey:tUnderlyingError}];
		}
		
		return nil;
		
	default:
		
		return nil;
	}
	
	return [self OHSHIT_initWithContentsOfURL:url options:readOptionsMask error:errorPtr];
}

- (instancetype)OHSHIT_initWithContentsOfFile:(NSString *)path
{
	if ([[OHSHITManager defaultManager] failureTypeForPath:path matchingFailuresTypes:[OHSHITManager readFailureTypes]]!=OHSHIT_StorageNoSimulatedFailure)
		return NO;
	
	return [self OHSHIT_initWithContentsOfFile:path];
}

- (instancetype)OHSHIT_initWithContentsOfURL:(NSURL *)url
{
	if ([[OHSHITManager defaultManager] failureTypeForURL:url matchingFailuresTypes:[OHSHITManager readFailureTypes]]!=OHSHIT_StorageNoSimulatedFailure)
		return NO;
	
	return [self OHSHIT_initWithContentsOfURL:url];
}

#pragma mark -

- (BOOL)OHSHIT_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager defaultManager] failureTypeForPath:path matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageNoSimulatedFailure:
			
			break;
			
		case OHSHIT_StorageSimulateNoMoreSpace:
			
			if ([self length]==0)
				break;
		
		case OHSHIT_StorageSimulateReadOnly:
			
		default:
			
			return NO;
	}
	
	return [self OHSHIT_writeToFile:path atomically:useAuxiliaryFile];
}


- (BOOL)OHSHIT_writeToURL:(NSURL *)url atomically:(BOOL)atomically
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager defaultManager] failureTypeForURL:url matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
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
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager defaultManager] failureTypeForPath:path matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
	NSError * tUnderlyingError;
	
	switch(tMatchingFailureType)
	{
		case OHSHIT_StorageNoSimulatedFailure:
			
			break;
			
		case OHSHIT_StorageSimulateNoMoreSpace:
			
			if ([self length]==0)
				break;
			
			tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOSPC userInfo:nil];
			
			*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteOutOfSpaceError userInfo:@{OHSHITFilePathKey:path,OHSHITUnderlyingErrorKey:tUnderlyingError}];
			
			return NO;
		
		case OHSHIT_StorageSimulateReadOnly:
			
			tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EROFS userInfo:nil];
			
			*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteVolumeReadOnlyError userInfo:@{OHSHITFilePathKey:path,OHSHITUnderlyingErrorKey:tUnderlyingError}];
			
			return NO;
			
		case OHSHIT_StorageSimulateFileWritePermissionDenied:
			
			tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EACCES userInfo:nil];
			
			*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteNoPermissionError userInfo:@{OHSHITFilePathKey:path,OHSHITUnderlyingErrorKey:tUnderlyingError}];
			
			return NO;
			
		case OHSHIT_StorageSimulateFileMissingIntermediaryDirectory:
			
			tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
			
			*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:@{OHSHITFilePathKey:path,OHSHITUnderlyingErrorKey:tUnderlyingError}];
			
			return NO;
			
		default:
			
			return NO;
	}
	
	return [self OHSHIT_writeToFile:path options:writeOptionsMask error:errorPtr];
}

- (BOOL)OHSHIT_writeToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager defaultManager] failureTypeForURL:url matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
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
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteOutOfSpaceError userInfo:@{OHSHITFilePathKey:[url path],
																												 OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateReadOnly:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EROFS userInfo:nil];
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteVolumeReadOnlyError userInfo:@{OHSHITFilePathKey:[url path],
																													 OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileWritePermissionDenied:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EACCES userInfo:nil];
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteNoPermissionError userInfo:@{OHSHITFilePathKey:[url path],
																												   OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileMissingIntermediaryDirectory:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:@{OHSHITFilePathKey:[url path],
																											OHSHITUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		default:
			
			return NO;
	}
	
	return [self OHSHIT_writeToURL:url options:writeOptionsMask error:errorPtr];
}

@end
