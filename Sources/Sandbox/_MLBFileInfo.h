//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, _MLBFileType) {
    _MLBFileTypeUnknown,
    _MLBFileTypeDirectory,
    // Image
    _MLBFileTypeJPG, _MLBFileTypePNG, _MLBFileTypeGIF, _MLBFileTypeSVG, _MLBFileTypeBMP, _MLBFileTypeTIF,
    // Audio
    _MLBFileTypeMP3, _MLBFileTypeAAC, _MLBFileTypeWAV, _MLBFileTypeOGG,
    // Video
    _MLBFileTypeMP4, _MLBFileTypeAVI, _MLBFileTypeFLV, _MLBFileTypeMIDI, _MLBFileTypeMOV, _MLBFileTypeMPG, _MLBFileTypeWMV,
    // Apple
    _MLBFileTypeDMG, _MLBFileTypeIPA, _MLBFileTypeNumbers, _MLBFileTypePages, _MLBFileTypeKeynote,
    // Google
    _MLBFileTypeAPK,
    // Microsoft
    _MLBFileTypeWord, _MLBFileTypeExcel, _MLBFileTypePPT, _MLBFileTypeEXE, _MLBFileTypeDLL,
    // Document
    _MLBFileTypeTXT, _MLBFileTypeRTF, _MLBFileTypePDF, _MLBFileTypeZIP, _MLBFileType7z, _MLBFileTypeCVS, _MLBFileTypeMD,
    // Programming
    _MLBFileTypeSwift, _MLBFileTypeJava, _MLBFileTypeC, _MLBFileTypeCPP, _MLBFileTypePHP,
    _MLBFileTypeJSON, _MLBFileTypePList, _MLBFileTypeXML, _MLBFileTypeDatabase,
    _MLBFileTypeJS, _MLBFileTypeHTML, _MLBFileTypeCSS,
    _MLBFileTypeBIN, _MLBFileTypeDat, _MLBFileTypeSQL, _MLBFileTypeJAR,
    // Adobe
    _MLBFileTypeFlash, _MLBFileTypePSD, _MLBFileTypeEPS,
    // Other
    _MLBFileTypeTTF, _MLBFileTypeTorrent,
};

@interface _MLBFileInfo : NSObject

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *extension;
@property (nonatomic, strong) NSString *modificationDateText;
@property (nonatomic, strong) NSDictionary<NSString *, id> *attributes;

@property (nonatomic, assign) _MLBFileType type;
@property (nonatomic, assign, readonly) BOOL isDirectory;
@property (nonatomic, assign) NSUInteger filesCount; // File always 0

@property (nonatomic, strong, readonly) NSString *typeImageName;
@property (nonatomic, assign, readonly) BOOL isCanPreviewInQuickLook;
@property (nonatomic, assign, readonly) BOOL isCanPreviewInWebView;

- (instancetype)initWithFileURL:(NSURL *)URL;

+ (NSDictionary<NSString *, id> *)attributesWithFileURL:(NSURL *)URL;
+ (NSMutableArray<_MLBFileInfo *> *)contentsOfDirectoryAtURL:(NSURL *)URL;

@end
