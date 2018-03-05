//
//  DebugTool.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FileType) {
    FileTypeUnknown,
    FileTypeDirectory,
    // Image
    FileTypeJPG, FileTypePNG, FileTypeGIF, FileTypeSVG, FileTypeBMP, FileTypeTIF,
    // Audio
    FileTypeMP3, FileTypeAAC, FileTypeWAV, FileTypeOGG,
    // Video
    FileTypeMP4, FileTypeAVI, FileTypeFLV, FileTypeMIDI, FileTypeMOV, FileTypeMPG, FileTypeWMV,
    // Apple
    FileTypeDMG, FileTypeIPA, FileTypeNumbers, FileTypePages, FileTypeKeynote,
    // Google
    FileTypeAPK,
    // Microsoft
    FileTypeWord, FileTypeExcel, FileTypePPT, FileTypeEXE, FileTypeDLL,
    // Document
    FileTypeTXT, FileTypeRTF, FileTypePDF, FileTypeZIP, FileType7z, FileTypeCVS, FileTypeMD,
    // Programming
    FileTypeSwift, FileTypeJava, FileTypeC, FileTypeCPP, FileTypePHP,
    FileTypeJSON, FileTypePList, FileTypeXML, FileTypeDatabase,
    FileTypeJS, FileTypeHTML, FileTypeCSS,
    FileTypeBIN, FileTypeDat, FileTypeSQL, FileTypeJAR,
    // Adobe
    FileTypeFlash, FileTypePSD, FileTypeEPS,
    // Other
    FileTypeTTF, FileTypeTorrent,
};

@interface FileInfo : NSObject

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *extension;
@property (nonatomic, strong) NSString *modificationDateText;
@property (nonatomic, strong) NSDictionary<NSString *, id> *attributes;

@property (nonatomic, assign) FileType type;
@property (nonatomic, assign, readonly) BOOL isDirectory;
@property (nonatomic, assign) NSUInteger filesCount; // File always 0

@property (nonatomic, strong, readonly) NSString *typeImageName;
@property (nonatomic, assign, readonly) BOOL isCanPreviewInQuickLook;
@property (nonatomic, assign, readonly) BOOL isCanPreviewInWebView;

- (instancetype)initWithFileURL:(NSURL *)URL;

+ (NSDictionary<NSString *, id> *)attributesWithFileURL:(NSURL *)URL;
+ (NSMutableArray<FileInfo *> *)contentsOfDirectoryAtURL:(NSURL *)URL;

@end
