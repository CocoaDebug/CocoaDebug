//
//  DebugTool.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "FileInfo.h"
#import "Sandbox.h"
#import "SandboxHelper.h"
#import <QuickLook/QuickLook.h>

#define IsStringEmpty(string)                    (nil == string || (NSNull *)string == [NSNull null] || [@"" isEqualToString:string])
#define IsStringNotEmpty(string)                 (string && (NSNull *)string != [NSNull null] && ![@"" isEqualToString:string])

@interface FileInfo ()

@property (nonatomic, strong, readwrite) NSString *typeImageName;

@end

@implementation FileInfo

- (instancetype)initWithFileURL:(NSURL *)URL {
    if (self = [super init]) {
        self.URL = URL;
        self.displayName = URL.lastPathComponent;
        self.attributes = [FileInfo attributesWithFileURL:URL];
        
        if ([self.attributes.fileType isEqualToString:NSFileTypeDirectory]) {
            self.type = FileTypeDirectory;
            self.filesCount = [FileInfo contentCountOfDirectoryAtURL:URL];
            //liman
            if ([URL isFileURL]) {
                self.modificationDateText = [NSString stringWithFormat:@"[%@] %@", [SandboxHelper fileModificationDateTextWithDate:self.attributes.fileModificationDate], [SandboxHelper sizeOfFolder:URL.path]];
            }
        } else {
            self.extension = URL.pathExtension;
            self.type = [FileInfo fileTypeWithExtension:self.extension];
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
    return self.type == FileTypeDirectory;
}

- (NSString *)typeImageName {
    if (!_typeImageName) {
//        NSString *fileExtension = [self.URL pathExtension];
//        NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
//        NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
//        NSLog(@"%@, UTI = %@, contentType = %@", self.URL.lastPathComponent, UTI, contentType);
        
        switch (self.type) {
            case FileTypeUnknown: _typeImageName = @"icon_file_type_default"; break;
            case FileTypeDirectory: _typeImageName = self.filesCount == 0 ? @"icon_file_type_folder_empty" : @"icon_file_type_folder_not_empty"; break;
            // Image
            case FileTypeJPG: _typeImageName = @"icon_file_type_jpg"; break;
            case FileTypePNG: _typeImageName = @"icon_file_type_png"; break;
            case FileTypeGIF: _typeImageName = @"icon_file_type_gif"; break;
            case FileTypeSVG: _typeImageName = @"icon_file_type_svg"; break;
            case FileTypeBMP: _typeImageName = @"icon_file_type_bmp"; break;
            case FileTypeTIF: _typeImageName = @"icon_file_type_tif"; break;
            // Audio
            case FileTypeMP3: _typeImageName = @"icon_file_type_mp3"; break;
            case FileTypeAAC: _typeImageName = @"icon_file_type_aac"; break;
            case FileTypeWAV: _typeImageName = @"icon_file_type_wav"; break;
            case FileTypeOGG: _typeImageName = @"icon_file_type_ogg"; break;
            // Video
            case FileTypeMP4: _typeImageName = @"icon_file_type_mp4"; break;
            case FileTypeAVI: _typeImageName = @"icon_file_type_avi"; break;
            case FileTypeFLV: _typeImageName = @"icon_file_type_flv"; break;
            case FileTypeMIDI: _typeImageName = @"icon_file_type_midi"; break;
            case FileTypeMOV: _typeImageName = @"icon_file_type_mov"; break;
            case FileTypeMPG: _typeImageName = @"icon_file_type_mpg"; break;
            case FileTypeWMV: _typeImageName = @"icon_file_type_wmv"; break;
            // Apple
            case FileTypeDMG: _typeImageName = @"icon_file_type_dmg"; break;
            case FileTypeIPA: _typeImageName = @"icon_file_type_ipa"; break;
            case FileTypeNumbers: _typeImageName = @"icon_file_type_numbers"; break;
            case FileTypePages: _typeImageName = @"icon_file_type_pages"; break;
            case FileTypeKeynote: _typeImageName = @"icon_file_type_keynote"; break;
            // Google
            case FileTypeAPK: _typeImageName = @"icon_file_type_apk"; break;
            // Microsoft
            case FileTypeWord: _typeImageName = @"icon_file_type_doc"; break;
            case FileTypeExcel: _typeImageName = @"icon_file_type_xls"; break;
            case FileTypePPT: _typeImageName = @"icon_file_type_ppt"; break;
            case FileTypeEXE: _typeImageName = @"icon_file_type_exe"; break;
            case FileTypeDLL: _typeImageName = @"icon_file_type_dll"; break;
            // Document
            case FileTypeTXT: _typeImageName = @"icon_file_type_txt"; break;
            case FileTypeRTF: _typeImageName = @"icon_file_type_rtf"; break;
            case FileTypePDF: _typeImageName = @"icon_file_type_pdf"; break;
            case FileTypeZIP: _typeImageName = @"icon_file_type_zip"; break;
            case FileType7z: _typeImageName = @"icon_file_type_7z"; break;
            case FileTypeCVS: _typeImageName = @"icon_file_type_cvs"; break;
            case FileTypeMD: _typeImageName = @"icon_file_type_md"; break;
            // Programming
            case FileTypeSwift: _typeImageName = @"icon_file_type_swift"; break;
            case FileTypeJava: _typeImageName = @"icon_file_type_java"; break;
            case FileTypeC: _typeImageName = @"icon_file_type_c"; break;
            case FileTypeCPP: _typeImageName = @"icon_file_type_cpp"; break;
            case FileTypePHP: _typeImageName = @"icon_file_type_php"; break;
            case FileTypeJSON: _typeImageName = @"icon_file_type_json"; break;
            case FileTypePList: _typeImageName = @"icon_file_type_plist"; break;
            case FileTypeXML: _typeImageName = @"icon_file_type_xml"; break;
            case FileTypeDatabase: _typeImageName = @"icon_file_type_db"; break;
            case FileTypeJS: _typeImageName = @"icon_file_type_js"; break;
            case FileTypeHTML: _typeImageName = @"icon_file_type_html"; break;
            case FileTypeCSS: _typeImageName = @"icon_file_type_css"; break;
            case FileTypeBIN: _typeImageName = @"icon_file_type_bin"; break;
            case FileTypeDat: _typeImageName = @"icon_file_type_dat"; break;
            case FileTypeSQL: _typeImageName = @"icon_file_type_sql"; break;
            case FileTypeJAR: _typeImageName = @"icon_file_type_jar"; break;
            // Adobe
            case FileTypeFlash: _typeImageName = @"icon_file_type_fla"; break;
            case FileTypePSD: _typeImageName = @"icon_file_type_psd"; break;
            case FileTypeEPS: _typeImageName = @"icon_file_type_eps"; break;
            // Other
            case FileTypeTTF: _typeImageName = @"icon_file_type_ttf"; break;
            case FileTypeTorrent: _typeImageName = @"icon_file_type_torrent"; break;
        }
    }
    
    return _typeImageName;
}

- (BOOL)isCanPreviewInQuickLook {
    return [QLPreviewController canPreviewItem:self.URL];
}

- (BOOL)isCanPreviewInWebView {
    if (// Image
        self.type == FileTypePNG ||
        self.type == FileTypeJPG ||
        self.type == FileTypeGIF ||
        self.type == FileTypeSVG ||
        self.type == FileTypeBMP ||
        // Audio
        self.type == FileTypeWAV ||
        // Apple
        self.type == FileTypeNumbers ||
        self.type == FileTypePages ||
        self.type == FileTypeKeynote ||
        // Microsoft
        self.type == FileTypeWord ||
        self.type == FileTypeExcel ||
        // Document
        self.type == FileTypeTXT || // 编码问题
        self.type == FileTypePDF ||
        self.type == FileTypeMD ||
        // Programming
        self.type == FileTypeJava ||
        self.type == FileTypeSwift ||
        self.type == FileTypeCSS ||
        // Adobe
        self.type == FileTypePSD) {
        return YES;
    }
    
    return NO;
}

#pragma mark - helper

//按照时间排序 by liman
+ (NSMutableArray<FileInfo *> *)sortedFileInfoArray:(NSMutableArray<FileInfo *> *)array
{
    return [[[array copy] sortedArrayUsingComparator:^NSComparisonResult(FileInfo  *_Nonnull obj1, FileInfo  *_Nonnull obj2) {
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

+ (NSMutableArray<FileInfo *> *)contentsOfDirectoryAtURL:(NSURL *)URL {
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
                FileInfo *fileInfo = [[FileInfo alloc] initWithFileURL:[URL URLByAppendingPathComponent:name]];
                [fileInfos addObject:fileInfo];
            }
        } else {
//            NSLog(@"%@, error: %@", NSStringFromSelector(_cmd), error.localizedDescription);
        }
    }
    
    //按照时间排序 by liman
    return [self sortedFileInfoArray:fileInfos];
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

+ (FileType)fileTypeWithExtension:(NSString *)extension {
    FileType type = FileTypeUnknown;
    
    if (IsStringEmpty(extension)) {
        return type;
    }
    
    // Image
    if ([extension compare:@"jpg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeJPG;
    } else if ([extension compare:@"png" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypePNG;
    } else if ([extension compare:@"gif" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeGIF;
    } else if ([extension compare:@"svg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeSVG;
    } else if ([extension compare:@"bmp" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeBMP;
    } else if ([extension compare:@"tif" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeTIF;
    }
    // Audio
    else if ([extension compare:@"mp3" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeMP3;
    } else if ([extension compare:@"aac" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeAAC;
    } else if ([extension compare:@"wav" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeWAV;
    } else if ([extension compare:@"ogg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeOGG;
    }
    // Video
    else if ([extension compare:@"mp4" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeMP4;
    } else if ([extension compare:@"avi" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeAVI;
    } else if ([extension compare:@"flv" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeFLV;
    } else if ([extension compare:@"midi" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeMIDI;
    } else if ([extension compare:@"mov" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeMOV;
    } else if ([extension compare:@"mpg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeMPG;
    } else if ([extension compare:@"wmv" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeWMV;
    }
    // Apple
    else if ([extension compare:@"dmg" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeDMG;
    } else if ([extension compare:@"ipa" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeIPA;
    } else if ([extension compare:@"numbers" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeNumbers;
    } else if ([extension compare:@"pages" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypePages;
    } else if ([extension compare:@"key" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeKeynote;
    }
    // Google
    else if ([extension compare:@"apk" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeAPK;
    }
    // Microsoft
    else if ([extension compare:@"doc" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
             [extension compare:@"docx" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeWord;
    } else if ([extension compare:@"xls" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
               [extension compare:@"xlsx" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeExcel;
    } else if ([extension compare:@"ppt" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
               [extension compare:@"pptx" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypePPT;
    } else if ([extension compare:@"exe" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeEXE;
    } else if ([extension compare:@"dll" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeDLL;
    }
    // Document
    else if ([extension compare:@"txt" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeTXT;
    } else if ([extension compare:@"rtf" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeRTF;
    } else if ([extension compare:@"pdf" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypePDF;
    } else if ([extension compare:@"zip" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeZIP;
    } else if ([extension compare:@"7z" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileType7z;
    } else if ([extension compare:@"cvs" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeCVS;
    } else if ([extension compare:@"md" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeMD;
    }
    // Programming
    else if ([extension compare:@"swift" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeSwift;
    } else if ([extension compare:@"java" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeJava;
    } else if ([extension compare:@"c" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeC;
    } else if ([extension compare:@"cpp" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeCPP;
    } else if ([extension compare:@"php" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypePHP;
    } else if ([extension compare:@"json" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeJSON;
    } else if ([extension compare:@"plist" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypePList;
    } else if ([extension compare:@"xml" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeXML;
    } else if ([extension compare:@"db" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeDatabase;
    } else if ([extension compare:@"js" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeJS;
    } else if ([extension compare:@"html" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeHTML;
    } else if ([extension compare:@"css" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeCSS;
    } else if ([extension compare:@"bin" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeBIN;
    } else if ([extension compare:@"dat" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeDat;
    } else if ([extension compare:@"sql" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeSQL;
    } else if ([extension compare:@"jar" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeJAR;
    }
    // Adobe
    else if ([extension compare:@"psd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypePSD;
    }
    else if ([extension compare:@"eps" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeEPS;
    }
    // Other
    else if ([extension compare:@"ttf" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeTTF;
    } else if ([extension compare:@"torrent" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        type = FileTypeTorrent;
    }
    
    return type;
}

@end
