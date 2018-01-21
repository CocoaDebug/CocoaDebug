/***********************************************************************************
 * Copyright 2015 Capital One Services, LLC
 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 
 * http://www.apache.org/licenses/LICENSE-2.0
 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ***********************************************************************************/


////////////////////////////////////////////////////////////////////////////////

//  Created by Jinlian (Sunny) Wang on 8/23/15.

#import <Foundation/Foundation.h>

//! Project version number for SWHttpTrafficRecorder.
FOUNDATION_EXPORT double SWHttpTrafficRecorderVersionNumber;

//! Project version string for SWHttpTrafficRecorder.
FOUNDATION_EXPORT const unsigned char SWHttpTrafficRecorderVersionString[];

/**
 * Recording formats that is supported by SWHttpTrafficRecorder.
 */
typedef NS_ENUM(NSInteger, SWHTTPTrafficRecordingFormat) {
    /* Custom format when the recorder records a request through an optional createFileInCustomFormatBlock block. */
    SWHTTPTrafficRecordingFormatCustom = -1,
    
    /* For BodyOnly format, the recorder creates a recorded file for each request using only its response body. If it is a JSON response, the file uses .json extension. Otherwise, .txt extenion is used. */
    SWHTTPTrafficRecordingFormatBodyOnly = 1,
    
    /* For Mocktail format, the recorder creates a recorded file for each request and its response in format that is defined by Mocktail framework at https://github.com/puls/objc-mocktail. The file uses .tail extension. */
    SWHTTPTrafficRecordingFormatMocktail = 2,
    
    /* For HTTPMessage format, the recorder creates a recorded file for each request and its response in format can be deserialized into a CFHTTPMessageRef raw HTTP Message. 'curl -is' also outputs in this format. */
    SWHTTPTrafficRecordingFormatHTTPMessage = 3
};

/**
 * Error codes for SWHttpTrafficRecorder.
 */
typedef NS_ENUM(NSInteger, SWHttpTrafficRecorderError) {
    /** The specified path does not exist and cannot be created */
    SWHttpTrafficRecorderErrorPathFailedToCreate = 1,
    /** The specified path was not writable */
    SWHttpTrafficRecorderErrorPathNotWritable
};

/**
 * Recording progress that is reported by SWHttpTrafficRecorder at each phase of recording a request and its response.
 */
typedef NS_ENUM(NSInteger, SWHTTPTrafficRecordingProgressKind) {
    /* A HTTP Request is received by the recorder. */
    SWHTTPTrafficRecordingProgressReceived = 1,
    
    /* A HTTP Request is skipped by the recorder for recording. */
    SWHTTPTrafficRecordingProgressSkipped = 2,
    
    /* The recorder starts downloading the response for a request. */
    SWHTTPTrafficRecordingProgressStarted = 3,
    
    /* The recorder finishes downloading the response for a request. */
    SWHTTPTrafficRecordingProgressLoaded = 4,
    
    /* The recorder finishes recording the response for a request. */
    SWHTTPTrafficRecordingProgressRecorded = 5,
    
    /* The recorder fails to download the response for a request for whatever reason. */
    SWHTTPTrafficRecordingProgressFailedToLoad = 6,
    
    /* The recorder fails to record the response for a request for whatever reason. */
    SWHTTPTrafficRecordingProgressFailedToRecord = 7
};

/* The key in a recording progress info dictionary whose value indicates the current NSURLRequest that is being recorded.*/
FOUNDATION_EXPORT NSString * const SWHTTPTrafficRecordingProgressRequestKey;

/* The key in a recording progress info dictionary whose value indicates the current NSHTTPURLResponse that is being recorded.*/
FOUNDATION_EXPORT NSString * const SWHTTPTrafficRecordingProgressResponseKey;

/* The key in a recording progress info dictionary whose value indicates the current NSData response body that is being recorded.*/
FOUNDATION_EXPORT NSString * const SWHTTPTrafficRecordingProgressBodyDataKey;

/* The key in a recording progress info dictionary whose value indicates the current file path that is used for the recorded file.*/
FOUNDATION_EXPORT NSString * const SWHTTPTrafficRecordingProgressFilePathKey;

/* The key in a recording progress info dictionary whose value indicates the current recording format.*/
FOUNDATION_EXPORT NSString * const SWHTTPTrafficRecordingProgressFileFormatKey;

/* The key in a recording progress info dictionary whose value indicates the NSErrror which fails the recording.*/
FOUNDATION_EXPORT NSString * const SWHTTPTrafficRecordingProgressErrorKey;

/* The error domain for SWHttpTrafficRecorder. */
FOUNDATION_EXPORT NSString * const SWHttpTrafficRecorderErrorDomain;

/** An optional delegate SWHttpTrafficRecorder uses to report its recording progress.
 */
@protocol SWHttpTrafficRecordingProgressDelegate <NSObject>

/**
 * Delegate method to be called by the recorder to update its current progress.
 *  @param currentProgress The current progress of the recording.
 *  @param info A recording progress info dictionary where its values (including a request object, its response, response body data, file path, recording format and NSError) can be retrieved through different keys. The available values depend on the current progress.
 */
- (void)updateRecordingProgress:(SWHTTPTrafficRecordingProgressKind)currentProgress userInfo:(NSDictionary *)info;

@end

/**
 * An SWHttpTrafficRecorder lets you intercepts the http requests made by an application and records their responses in a specified format. There are three built-in formats supported: ResponseBodyOnly, Mocktail and HTTPMessage. These formats are widely used by various mocking/stubbing frameworks such as Mocktail(https://github.com/puls/objc-mocktail), OHHTTPStubs(https://github.com/AliSoftware/OHHTTPStubs/tree/master/OHHTTPStubs), Nocilla(https://github.com/luisobo/Nocilla), etc. You can also use it to monitor the traffic for debugging purpose.
 */
@interface SWHttpTrafficRecorder : NSObject

/**
 * Returns the shared recorder object.
 */
+ (instancetype)sharedRecorder;

/**
 *  Method to start recording using default path.
 */
- (BOOL)startRecording;

/**
 *  Method to start recording and saves recorded files at a specified location.
 *  @param recordingPath The path where recorded files are saved.
 *  @param error An out value that returns any error encountered while accessing the recordingPath. Returns an NSError object if any error; otherwise returns nil.
 */
- (BOOL)startRecordingAtPath:(NSString *)recordingPath error:(NSError **) error;

/**
 *  Method to start recording and saves recorded files at a specified location using given session configuration.
 *  @param recordingPath The path where recorded files are saved.
 *  @param sessionConfig The NSURLSessionConfiguration which will be modified.
 *  @param error An out value that returns any error encountered while accessing the recordingPath. Returns an NSError object if any error; otherwise returns nil.
 */
- (BOOL)startRecordingAtPath:(NSString *)recordingPath forSessionConfiguration:(NSURLSessionConfiguration *)sessionConfig error:(NSError **) error;

/**
 *  Method to stop recording.
 */
- (void)stopRecording;

/**
 * Method to enable the recorder for the specific session configuration
 */
- (void)setEnabled:(BOOL)enabled forConfig:(NSURLSessionConfiguration*)sessionConfig;

/**
 *  A Boolean value which indicates whether the recording is recording traffic.
 */
@property(nonatomic, readonly, assign) BOOL isRecording;

/**
 *  A Enum value which indicates the format the recording is using to record traffic.
 */
@property(nonatomic, assign) SWHTTPTrafficRecordingFormat recordingFormat;

/**
 *  A Dictionary containing Regex/Token pairs for replacement in response data
 */
@property(nonatomic, assign) NSMutableDictionary *replacementDict;

/**
 *  The delegate where the recording progress are reported. 
 */
@property(nonatomic, assign) id<SWHttpTrafficRecordingProgressDelegate> progressDelegate;

/**
 *  The optional block (if provided) to be applied to every request to determine whether the request shall be recorded by the recorder. It takes a NSURLRequest as parameter and returns a Boolean value that indicates whether the request shall be recorded.
 */
@property(nonatomic, copy) BOOL(^recordingTestBlock)(NSURLRequest *request);

/**
 *  The optional block (if provided) to be applied to every request to determine whether the response body shall be base64 encodes before recording. It takes a NSURLRequest as parameter and returns a Boolean value that indicates whether the response body shall be base64 encoded.
 */
@property(nonatomic, copy) BOOL(^base64TestBlock)(NSURLRequest *request, NSURLResponse *response);

/**
 *  The optional block (if provided) to be applied to every request to determine what file name is to be used while creating the recorded file. It takes a NSURLRequest and a default name that is generated by the recorder as parameters and returns a NSString value which is used as filename while creating the recorded file.
 */
@property(nonatomic, copy) NSString*(^fileNamingBlock)(NSURLRequest *request, NSURLResponse *response, NSString *defaultName);

/**
 *  The optional block (if provided) to be applied to every request to determine what regular expression is to be used while creating a recorded file of Mocktail format. It takes a NSURLRequest and a default regular expression pattern that is generated by the recorder as parameters and returns a NSString value which is used as the regular expression pattern while creating the recorded file.
 */
@property(nonatomic, copy) NSString*(^urlRegexPatternBlock)(NSURLRequest *request, NSString *defaultPattern);

/**
 *  The optional block (if provided) to be applied to every request to create the recorded file when the recording format is custom. It takes a NSURLRequest, its response, a body data and a filePath as parameters and be expected to create the recorded file at the filePath.
 */
@property(nonatomic, copy) NSString*(^createFileInCustomFormatBlock)(NSURLRequest *request, NSURLResponse *response, NSData *bodyData, NSString *filePath);

@end
