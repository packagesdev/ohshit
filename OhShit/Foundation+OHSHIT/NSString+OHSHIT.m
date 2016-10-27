/*
 Copyright (c) 2016, Stephane Sudre
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 - Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSString+OHSHIT.h"

#import "NSObject+OHSHIT.h"

#import "OHSHITManager+Private.h"

@interface NSString (OHSHIT_Private)

- (BOOL)OHSHIT_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
- (BOOL)OHSHIT_writeToURL:(NSURL *)url atomically:(BOOL)atomically;

- (BOOL)OHSHIT_writeToURL:(NSURL *)url atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error;
- (BOOL)OHSHIT_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error;

@end

@implementation NSString (OHSHIT)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSString OHSHIT_start];
	});
}

#pragma mark -

- (BOOL)OHSHIT_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile
{
	if ([[OHSHITManager sharedManager] failureTypeForPath:path matchingFailuresTypes:[OHSHITManager writeFailureTypes]]!=OHSHIT_StorageNoSimulatedFailure)
		return NO;
	
	return [self OHSHIT_writeToFile:path atomically:useAuxiliaryFile];
}

- (BOOL)OHSHIT_writeToURL:(NSURL *)url atomically:(BOOL)atomically
{
	if ([[OHSHITManager sharedManager] failureTypeForURL:url matchingFailuresTypes:[OHSHITManager writeFailureTypes]]!=OHSHIT_StorageNoSimulatedFailure)
		return NO;
	
	return [self OHSHIT_writeToURL:url atomically:atomically];
}

- (BOOL)OHSHIT_writeToURL:(NSURL *)url atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)errorPtr
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
																													 OHSHITUserStringVariantKey:@"Folder",
																													 NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileWritePermissionDenied:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EACCES userInfo:nil];
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteNoPermissionError userInfo:@{NSFilePathErrorKey:[url path],
																												   OHSHITUserStringVariantKey:@"Folder",
																												   NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileMissingIntermediaryDirectory:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
			
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:@{NSFilePathErrorKey:[url path],
																											OHSHITUserStringVariantKey:@"Folder",
																											NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		default:
			
			return NO;
	}
	
	return [self OHSHIT_writeToURL:url atomically:useAuxiliaryFile encoding:enc error:errorPtr];
}

- (BOOL)OHSHIT_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)errorPtr
{
	OHSHITStorageFailureType tMatchingFailureType=[[OHSHITManager sharedManager] failureTypeForPath:path matchingFailuresTypes:[OHSHITManager writeFailureTypes]];
	
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
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteOutOfSpaceError userInfo:@{NSFilePathErrorKey:path,
																												 NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateReadOnly:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EROFS userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteVolumeReadOnlyError userInfo:@{NSFilePathErrorKey:path,
																													 OHSHITUserStringVariantKey:@"Folder",
																													 NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileWritePermissionDenied:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:EACCES userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteNoPermissionError userInfo:@{NSFilePathErrorKey:path,
																												   OHSHITUserStringVariantKey:@"Folder",
																												   NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		case OHSHIT_StorageSimulateFileMissingIntermediaryDirectory:
			
			if (errorPtr!=NULL)
			{
				NSError * tUnderlyingError=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
				
				*errorPtr=[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:@{NSFilePathErrorKey:path,
																											OHSHITUserStringVariantKey:@"Folder",
																											NSUnderlyingErrorKey:tUnderlyingError}];
			}
			
			return NO;
			
		default:
			
			return NO;
	}
	
	return [self OHSHIT_writeToFile:path atomically:useAuxiliaryFile encoding:enc error:errorPtr];
}

@end
