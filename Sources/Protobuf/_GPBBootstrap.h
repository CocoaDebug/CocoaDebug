//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

/**
 * The Objective C runtime has complete enough info that most protos don’t end
 * up using this, so leaving it on is no cost or very little cost.  If you
 * happen to see it causing bloat, this is the way to disable it. If you do
 * need to disable it, try only disabling it for Release builds as having
 * full TextFormat can be useful for debugging.
 **/
#ifndef _GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
#define _GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS 0
#endif

// Used in the generated code to give sizes to enums. int32_t was chosen based
// on the fact that Protocol Buffers enums are limited to this range.
#if !__has_feature(objc_fixed_enum)
 #error All supported Xcode versions should support objc_fixed_enum.
#endif

// If the headers are imported into Objective-C++, we can run into an issue
// where the defintion of NS_ENUM (really CF_ENUM) changes based on the C++
// standard that is in effect.  If it isn't C++11 or higher, the definition
// doesn't allow us to forward declare. We work around this one case by
// providing a local definition. The default case has to use NS_ENUM for the
// magic that is Swift bridging of enums.
#if (defined(__cplusplus) && __cplusplus && __cplusplus < 201103L)
 #define _GPB_ENUM(X) enum X : int32_t X; enum X : int32_t
#else
 #define _GPB_ENUM(X) NS_ENUM(int32_t, X)
#endif

/**
 * _GPB_ENUM_FWD_DECLARE is used for forward declaring enums, for example:
 *
 * ```
 * _GPB_ENUM_FWD_DECLARE(Foo_Enum)
 *
 * @interface BarClass : NSObject
 * @property (nonatomic) enum Foo_Enum value;
 * - (void)bazMethod:(enum Foo_Enum):value;
 * @end
 * ```
 **/
#define _GPB_ENUM_FWD_DECLARE(X) enum X : int32_t

/**
 * Based upon CF_INLINE. Forces inlining in non DEBUG builds.
 **/
#if !defined(DEBUG)
#define _GPB_INLINE static __inline__ __attribute__((always_inline))
#else
#define _GPB_INLINE static __inline__
#endif

/**
 * For use in public headers that might need to deal with ARC.
 **/
#ifndef _GPB_UNSAFE_UNRETAINED
#if __has_feature(objc_arc)
#define _GPB_UNSAFE_UNRETAINED __unsafe_unretained
#else
#define _GPB_UNSAFE_UNRETAINED
#endif
#endif

/**
 * Attribute used for Objective-C proto interface deprecations without messages.
 **/
#ifndef _GPB_DEPRECATED
#define _GPB_DEPRECATED __attribute__((deprecated))
#endif

/**
 * Attribute used for Objective-C proto interface deprecations with messages.
 **/
#ifndef _GPB_DEPRECATED_MSG
#if __has_extension(attribute_deprecated_with_message)
#define _GPB_DEPRECATED_MSG(msg) __attribute__((deprecated(msg)))
#else
#define _GPB_DEPRECATED_MSG(msg) __attribute__((deprecated))
#endif
#endif

// If property name starts with init we need to annotate it to get past ARC.
// http://stackoverflow.com/questions/18723226/how-do-i-annotate-an-objective-c-property-with-an-objc-method-family/18723227#18723227
//
// Meant to be used internally by generated code.
#define _GPB_METHOD_FAMILY_NONE __attribute__((objc_method_family(none)))

// ----------------------------------------------------------------------------
// These version numbers are all internal to the ObjC Protobuf runtime; they
// are used to ensure compatibility between the generated sources and the
// headers being compiled against and/or the version of sources being run
// against.
//
// They are all #defines so the values are captured into every .o file they
// are used in and to allow comparisons in the preprocessor.

// Current library runtime version.
// - Gets bumped when the runtime makes changes to the interfaces between the
//   generated code and runtime (things added/removed, etc).
#define GOOGLE_PROTOBUF_OBJC_VERSION 30002

// Minimum runtime version supported for compiling/running against.
// - Gets changed when support for the older generated code is dropped.
#define GOOGLE_PROTOBUF_OBJC_MIN_SUPPORTED_VERSION 30001


// This is a legacy constant now frozen in time for old generated code. If
// GOOGLE_PROTOBUF_OBJC_MIN_SUPPORTED_VERSION ever gets moved above 30001 then
// this should also change to break code compiled with an old runtime that
// can't be supported any more.
#define GOOGLE_PROTOBUF_OBJC_GEN_VERSION 30001
