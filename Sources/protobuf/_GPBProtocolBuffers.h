// Protocol Buffers - Google's data interchange format
// Copyright 2008 Google Inc.  All rights reserved.
// https://developers.google.com/protocol-buffers/
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
// copyright notice, this list of conditions and the following disclaimer
// in the documentation and/or other materials provided with the
// distribution.
//     * Neither the name of Google Inc. nor the names of its
// contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
 #import <Protobuf/_Any.pbobjc.h>
 #import <Protobuf/_Api.pbobjc.h>
 #import <Protobuf/_Duration.pbobjc.h>
 #import <Protobuf/_Empty.pbobjc.h>
 #import <Protobuf/_FieldMask.pbobjc.h>
 #import <Protobuf/_SourceContext.pbobjc.h>
 #import <Protobuf/_Struct.pbobjc.h>
 #import <Protobuf/_Timestamp.pbobjc.h>
 #import <Protobuf/_Type.pbobjc.h>
 #import <Protobuf/_Wrappers.pbobjc.h>
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
