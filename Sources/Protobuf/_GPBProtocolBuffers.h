//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_GPBBootstrap.h"

#import "_GPBArray.h"
#import "_GPBCodedInputStream.h"
#import "_GPBCodedOutputStream.h"
#import "_GPBDescriptor.h"
#import "_GPBDictionary.h"
#import "_GPBExtensionRegistry.h"
#import "_GPBMessage.h"
#import "_GPBRootObject.h"
#import "_GPBUnknownField.h"
#import "_GPBUnknownFieldSet.h"
#import "_GPBUtilities.h"
#import "_GPBWellKnownTypes.h"
#import "_GPBWireFormat.h"

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(_GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define _GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

// Well-known proto types
#if _GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <protobuf/Any.pbobjc.h>
 #import <protobuf/Api.pbobjc.h>
 #import <protobuf/Duration.pbobjc.h>
 #import <protobuf/Empty.pbobjc.h>
 #import <protobuf/FieldMask.pbobjc.h>
 #import <protobuf/SourceContext.pbobjc.h>
 #import <protobuf/Struct.pbobjc.h>
 #import <protobuf/Timestamp.pbobjc.h>
 #import <protobuf/Type.pbobjc.h>
 #import <protobuf/Wrappers.pbobjc.h>
#else
 #import "_Any.pbobjc.h"
 #import "_Api.pbobjc.h"
 #import "_Duration.pbobjc.h"
 #import "_Empty.pbobjc.h"
 #import "_FieldMask.pbobjc.h"
 #import "_SourceContext.pbobjc.h"
 #import "_Struct.pbobjc.h"
 #import "_Timestamp.pbobjc.h"
 #import "_Type.pbobjc.h"
 #import "_Wrappers.pbobjc.h"
#endif
