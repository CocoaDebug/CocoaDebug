//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, _FileType) {
    _FileTypeUnknown,
    _FileTypeDirectory,
    // Image
    _FileTypeJPG, _FileTypePNG, _FileTypeGIF, _FileTypeSVG, _FileTypeBMP, _FileTypeTIF,
    // Audio
    _FileTypeMP3, _FileTypeAAC, _FileTypeWAV, _FileTypeOGG,
    // Video
    _FileTypeMP4, _FileTypeAVI, _FileTypeFLV, _FileTypeMIDI, _FileTypeMOV, _FileTypeMPG, _FileTypeWMV,
    // Apple
    _FileTypeDMG, _FileTypeIPA, _FileTypeNumbers, _FileTypePages, _FileTypeKeynote,
    // Google
    _FileTypeAPK,
    // Microsoft
    _FileTypeWord, _FileTypeExcel, _FileTypePPT, _FileTypeEXE, _FileTypeDLL,
    // Document
    _FileTypeTXT, _FileTypeRTF, _FileTypePDF, _FileTypeZIP, _FileType7z, _FileTypeCVS, _FileTypeMD,
    // Programming
    _FileTypeSwift, _FileTypeJava, _FileTypeC, _FileTypeCPP, _FileTypePHP,
    _FileTypeJSON, _FileTypePList, _FileTypeXML, _FileTypeDatabase,
    _FileTypeJS, _FileTypeHTML, _FileTypeCSS,
    _FileTypeBIN, _FileTypeDat, _FileTypeSQL, _FileTypeJAR,
    // Adobe
    _FileTypeFlash, _FileTypePSD, _FileTypeEPS,
    // Other
    _FileTypeTTF, _FileTypeTorrent,
};

@interface _FileInfo : NSObject

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *extension;
@property (nonatomic, strong) NSString *modificationDateText;
@property (nonatomic, strong) NSDictionary<NSString *, id> *attributes;

@property (nonatomic, assign) _FileType type;
@property (nonatomic, assign, readonly) BOOL isDirectory;
@property (nonatomic, assign) NSUInteger filesCount; // File always 0

@property (nonatomic, strong, readonly) NSString *typeImageName;
@property (nonatomic, assign, readonly) BOOL isCanPreviewInQuickLook;
@property (nonatomic, assign, readonly) BOOL isCanPreviewInWebView;

- (instancetype)initWithFileURL:(NSURL *)URL;

+ (NSDictionary<NSString *, id> *)attributesWithFileURL:(NSURL *)URL;
+ (NSMutableArray<_FileInfo *> *)contentsOfDirectoryAtURL:(NSURL *)URL;

@end
