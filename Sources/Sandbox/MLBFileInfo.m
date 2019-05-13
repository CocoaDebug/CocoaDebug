//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "MLBFileInfo.h"
#import "Sandbox.h"
#import "SandboxHelper.h"
#import <QuickLook/QuickLook.h>

#define MLBIsStringEmpty(string)                    (nil == string || (NSNull *)string == [NSNull null] || [@"" isEqualToString:string])
#define MLBIsStringNotEmpty(string)                 (string && (NSNull *)string != [NSNull null] && ![@"" isEqualToString:string])

@interface MLBFileInfo ()

@property (nonatomic, copy, readwrite) NSString *typeImageName;

@end

@implementation MLBFileInfo

- (instancetype)initWithFileURL:(NSURL *)URL {
    if (self = [super init]) {
        self.URL = URL;
        self.displayName = URL.lastPathComponent;
        self.attributes = [MLBFileInfo attributesWithFileURL:URL];
        
        if ([self.attributes.fileType isEqualToString:NSFileTypeDirectory]) {
            self.type = MLBFileTypeDirectory;
            self.filesCount = [MLBFileInfo contentCountOfDirectoryAtURL:URL];
            //liman
            if ([URL isFileURL]) {
                self.modificationDateText = [NSString stringWithFormat:@"[%@] %@", [SandboxHelper fileModificationDateTextWithDate:self.attributes.fileModificationDate], [SandboxHelper sizeOfFolder:URL.path]];
            }
        } else {
            self.extension = URL.pathExtension;
            self.type = [MLBFileInfo fileTypeWithExtension:self.extension];
            self.filesCount = 0;
            //liman
            if ([URL isFileURL]) {
                self.modificationDateText = [NSString stringWithFormat:@"[%@] %@", [SandboxHelper fileModificationDateTextWithDate:self.attributes.fileModificationDate], [SandboxHelper sizeOfFile:URL.path]];
            }
        }
        
        //liman
        if ([self.modificationDateText containsString:@"[] "]) {
            self.modificationDateText = [[self.modificationDateText mutableCopy] stringByReplacingOccurrencesOfString:@"[] " withString:@""];
        }
    }
    
    return self;
}

#pragma mark - Getters

- (BOOL)isDirectory {
    return self.type == MLBFileTypeDirectory;
}

- (NSString *)typeImageName {
    if (!_typeImageName) {
//        NSString *fileExtension = [self.URL pathExtension];
//        NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
//        NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
//        NSLog(@"%@, UTI = %@, contentType = %@", self.URL.lastPathComponent, UTI, contentType);
        
        switch (self.type) {
            case MLBFileTypeUnknown: _typeImageName = @"icon_file_type_default"; break;
            case MLBFileTypeDirectory: _typeImageName = self.filesCount == 0 ? @"icon_file_type_folder_empty" : @"icon_file_type_folder_not_empty"; break;
            // Image
            case MLBFileTypeJPG: _typeImageName = @"icon_file_type_jpg"; break;
            case MLBFileTypePNG: _typeImageName = @"icon_file_type_png"; break;
            case MLBFileTypeGIF: _typeImageName = @"icon_file_type_gif"; break;
            case MLBFileTypeSVG: _typeImageName = @"icon_file_type_svg"; break;
            case MLBFileTypeBMP: _typeImageName = @"icon_file_type_bmp"; break;
            case MLBFileTypeTIF: _typeImageName = @"icon_file_type_tif"; break;
            // Audio
            case MLBFileTypeMP3: _typeImageName = @"icon_file_type_mp3"; break;
            case MLBFileTypeAAC: _typeImageName = @"icon_file_type_aac"; break;
            case MLBFileTypeWAV: _typeImageName = @"icon_file_type_wav"; break;
            case MLBFileTypeOGG: _typeImageName = @"icon_file_type_ogg"; break;
            // Video
            case MLBFileTypeMP4: _typeImageName = @"icon_file_type_mp4"; break;
            case MLBFileTypeAVI: _typeImageName = @"icon_file_type_avi"; break;
            case MLBFileTypeFLV: _typeImageName = @"icon_file_type_flv"; break;
            case MLBFileTypeMIDI: _typeImageName = @"icon_file_type_midi"; break;
            case MLBFileTypeMOV: _typeImageName = @"icon_file_type_mov"; break;
            case MLBFileTypeMPG: _typeImageName = @"icon_file_type_mpg"; break;
            case MLBFileTypeWMV: _typeImageName = @"icon_file_type_wmv"; break;
            // Apple
            case MLBFileTypeDMG: _typeImageName = @"icon_file_type_dmg"; break;
            case MLBFileTypeIPA: _typeImageName = @"icon_file_type_ipa"; break;
            case MLBFileTypeNumbers: _typeImageName = @"icon_file_type_numbers"; break;
            case MLBFileTypePages: _typeImageName = @"icon_file_type_pages"; break;
            case MLBFileTypeKeynote: _typeImageName = @"icon_file_type_keynote"; break;
            // Google
            case MLBFileTypeAPK: _typeImageName = @"icon_file_type_apk"; break;
            // Microsoft
            case MLBFileTypeWord: _typeImageName = @"icon_file_type_doc"; break;
            case MLBFileTypeExcel: _typeImageName = @"icon_file_type_xls"; break;
            case MLBFileTypePPT: _typeImageName = @"icon_file_type_ppt"; break;
            case MLBFileTypeEXE: _typeImageName = @"icon_file_type_exe"; break;
            case MLBFileTypeDLL: _typeImageName = @"icon_file_type_dll"; break;
            // Document
            case MLBFileTypeTXT: _typeImageName = @"icon_file_type_txt"; break;
            case MLBFileTypeRTF: _typeImageName = @"icon_file_type_rtf"; break;
            case MLBFileTypePDF: _typeImageName = @"icon_file_type_pdf"; break;
            case MLBFileTypeZIP: _typeImageName = @"icon_file_type_zip"; break;
            case MLBFileType7z: _typeImageName = @"icon_file_type_7z"; break;
            case MLBFileTypeCVS: _typeImageName = @"icon_file_type_cvs"; break;
            case MLBFileTypeMD: _typeImageName = @"icon_file_type_md"; break;
            // Programming
            case MLBFileTypeSwift: _typeImageName = @"icon_file_type_swift"; break;
            case MLBFileTypeJava: _typeImageName = @"icon_file_type_java"; break;
            case MLBFileTypeC: _typeImageName = @"icon_file_type_c"; break;
            case MLBFileTypeCPP: _typeImageName = @"icon_file_type_cpp"; break;
            case MLBFileTypePHP: _typeImageName = @"icon_file_type_php"; break;
            case MLBFileTypeJSON: _typeImageName = @"icon_file_type_json"; break;
            case MLBFileTypePList: _typeImageName = @"icon_file_type_plist"; break;
            case MLBFileTypeXML: _typeImageName = @"icon_file_type_xml"; break;
            case MLBFileTypeDatabase: _typeImageName = @"icon_file_type_db"; break;
            case MLBFileTypeJS: _typeImageName = @"icon_file_type_js"; break;
            case MLBFileTypeHTML: _typeImageName = @"icon_file_type_html"; break;
            case MLBFileTypeCSS: _typeImageName = @"icon_file_type_css"; break;
            case MLBFileTypeBIN: _typeImageName = @"icon_file_type_bin"; break;
            case MLBFileTypeDat: _typeImageName = @"icon_file_type_dat"; break;
            case MLBFileTypeSQL: _typeImageName = @"icon_file_type_sql"; break;
            case MLBFileTypeJAR: _typeImageName = @"icon_file_type_jar"; break;
            // Adobe
            case MLBFileTypeFlash: _typeImageName = @"icon_file_type_fla"; break;
            case MLBFileTypePSD: _typeImageName = @"icon_file_type_psd"; break;
            case MLBFileTypeEPS: _typeImageName = @"icon_file_type_eps"; break;
            // Other
            case MLBFileTypeTTF: _typeImageName = @"icon_file_type_ttf"; break;
            case MLBFileTypeTorrent: _typeImageName = @"icon_file_type_torrent"; break;
        }
    }
    
    return _typeImageName;
}

- (BOOL)isCanPreviewInQuickLook {
    return [QLPreviewController canPreviewItem:self.URL];
}

- (BOOL)isCanPreviewInWebView {
    if (// Image
        self.type == MLBFileTypePNG ||
        self.type == MLBFileTypeJPG ||
        self.type == MLBFileTypeGIF ||
        self.type == MLBFileTypeSVG ||
        self.type == MLBFileTypeBMP ||
        // Audio
        self.type == MLBFileTypeWAV ||
        // Apple
        self.type == MLBFileTypeNumbers ||
        self.type == MLBFileTypePages ||
        self.type == MLBFileTypeKeynote ||
        // Microsoft
        self.type == MLBFileTypeWord ||
        self.type == MLBFileTypeExcel ||
        // Document
        self.type == MLBFileTypeTXT || // 编码问题
        self.type == MLBFileTypePDF ||
        self.type == MLBFileTypeMD ||
        // Programming
        self.type == MLBFileTypeJava ||
        self.type == MLBFileTypeSwift ||
        self.type == MLBFileTypeCSS ||
        // Adobe
        self.type == MLBFileTypePSD) {
        return YES;
    }
    
    return NO;
}

#pragma mark - helper

//按照时间排序 by CocoaDebug
+ (NSMutableArray<MLBFileInfo *> *)sortedMLBFileInfoArray:(NSMutableArray<MLBFileInfo *> *)array
{
    return [[[array copy] sortedArrayUsingComparator:^NSComparisonResult(MLBFileInfo  *_Nonnull obj1, MLBFileInfo  *_Nonnull obj2) {
        return [obj1.attributes.fileModificationDate compare:obj2.attributes.fileModificationDate ?: [NSDate date]];
    }] mutableCopy];
}

#pragma mark - Public Methods

+ (NSDictionary<NSString *, id> *)attributesWithFileURL:(NSURL *)URL {
    NSError *error;
    NSDictionary<NSString *, id> *attributes = [NSFileManager.defaultManager attributesOfItemAtPath:URL.path error:&error];
    if (error) {
//        NSLog(@"%@, error: %@", NSStringFromSelector(_cmd), error.localizedDescription);
    }
    
    return attributes;
}

+ (NSMutableArray<MLBFileInfo *> *)contentsOfDirectoryAtURL:(NSURL *)URL {
//    NSLog(@"%@, url = %@", NSStringFromSelector(_cmd), URL.path);
    NSMutableArray *fileInfos = @[].mutableCopy;
    BOOL isDir = NO;
    BOOL isExists = [NSFileManager.defaultManager fileExistsAtPath:URL.path isDirectory:&isDir];
    if (isExists && isDir) {
        NSError *error;
        NSArray<NSString *> *contents = [NSFileManager.defaultManager contentsOfDirectoryAtPath:URL.path error:&error];
        if (!error) {
            for (NSString *name in contents) {
                if (Sandbox.shared.isSystemFilesHidden && [name hasPrefix:@"."]) { continue; }
                MLBFileInfo *fileInfo = [[MLBFileInfo alloc] initWithFileURL:[URL URLByAppendingPathComponent:name]];
                [fileInfos addObject:fileInfo];
            }
        } else {
//            NSLog(@"%@, error: %@", NSStringFromSelector(_cmd), error.localizedDescription);
        }
    }
    
    //按照时间排序 by CocoaDebug
    return [self sortedMLBFileInfoArray:fileInfos];
}

+ (NSUInteger)contentCountOfDirectoryAtURL:(NSURL *)URL {
//    NSLog(@"%@, url = %@", NSStringFromSelector(_cmd), URL.path);
    NSUInteger count = 0;
    BOOL isDir = NO;
    BOOL isExists = [NSFileManager.defaultManager fileExistsAtPath:URL.path isDirectory:&isDir];
    if (isExists && isDir) {
        NSError *error;
        NSArray<NSString *> *contents = [NSFileManager.defaultManager contentsOfDirectoryAtPath:URL.path error:&error];
        if (!error) {
            for (NSString *name in contents) {
                if (Sandbox.shared.isSystemFilesHidden && [name hasPrefix:@"."]) { continue; }
                count++;
            }
        } else {
//            NSLog(@"%@, error: %@", NSStringFromSelector(_cmd), error.localizedDescription);
        }
    }
    
    return count;
}

+ (MLBFileType)fileTypeWithExtension:(NSString *)extension {
    MLBFileType type = MLBFileTypeUnknown;
    
    if (MLBIsStringEmpty(extension)) {
        return type;
    }
    
    // Image
    if ([extension compare:@"jpg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeJPG;
    } else if ([extension compare:@"png" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypePNG;
    } else if ([extension compare:@"gif" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeGIF;
    } else if ([extension compare:@"svg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeSVG;
    } else if ([extension compare:@"bmp" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeBMP;
    } else if ([extension compare:@"tif" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeTIF;
    }
    // Audio
    else if ([extension compare:@"mp3" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeMP3;
    } else if ([extension compare:@"aac" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeAAC;
    } else if ([extension compare:@"wav" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeWAV;
    } else if ([extension compare:@"ogg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeOGG;
    }
    // Video
    else if ([extension compare:@"mp4" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeMP4;
    } else if ([extension compare:@"avi" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeAVI;
    } else if ([extension compare:@"flv" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeFLV;
    } else if ([extension compare:@"midi" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeMIDI;
    } else if ([extension compare:@"mov" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeMOV;
    } else if ([extension compare:@"mpg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeMPG;
    } else if ([extension compare:@"wmv" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeWMV;
    }
    // Apple
    else if ([extension compare:@"dmg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeDMG;
    } else if ([extension compare:@"ipa" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeIPA;
    } else if ([extension compare:@"numbers" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeNumbers;
    } else if ([extension compare:@"pages" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypePages;
    } else if ([extension compare:@"key" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeKeynote;
    }
    // Google
    else if ([extension compare:@"apk" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeAPK;
    }
    // Microsoft
    else if ([extension compare:@"doc" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
             [extension compare:@"docx" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeWord;
    } else if ([extension compare:@"xls" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
               [extension compare:@"xlsx" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeExcel;
    } else if ([extension compare:@"ppt" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
               [extension compare:@"pptx" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypePPT;
    } else if ([extension compare:@"exe" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeEXE;
    } else if ([extension compare:@"dll" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeDLL;
    }
    // Document
    else if ([extension compare:@"txt" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeTXT;
    } else if ([extension compare:@"rtf" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeRTF;
    } else if ([extension compare:@"pdf" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypePDF;
    } else if ([extension compare:@"zip" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeZIP;
    } else if ([extension compare:@"7z" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileType7z;
    } else if ([extension compare:@"cvs" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeCVS;
    } else if ([extension compare:@"md" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeMD;
    }
    // Programming
    else if ([extension compare:@"swift" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeSwift;
    } else if ([extension compare:@"java" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeJava;
    } else if ([extension compare:@"c" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeC;
    } else if ([extension compare:@"cpp" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeCPP;
    } else if ([extension compare:@"php" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypePHP;
    } else if ([extension compare:@"json" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeJSON;
    } else if ([extension compare:@"plist" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypePList;
    } else if ([extension compare:@"xml" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeXML;
    } else if ([extension compare:@"db" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeDatabase;
    } else if ([extension compare:@"js" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeJS;
    } else if ([extension compare:@"html" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeHTML;
    } else if ([extension compare:@"css" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeCSS;
    } else if ([extension compare:@"bin" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeBIN;
    } else if ([extension compare:@"dat" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeDat;
    } else if ([extension compare:@"sql" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeSQL;
    } else if ([extension compare:@"jar" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeJAR;
    }
    // Adobe
    else if ([extension compare:@"psd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypePSD;
    }
    else if ([extension compare:@"eps" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeEPS;
    }
    // Other
    else if ([extension compare:@"ttf" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeTTF;
    } else if ([extension compare:@"torrent" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = MLBFileTypeTorrent;
    }
    
    return type;
}

@end
