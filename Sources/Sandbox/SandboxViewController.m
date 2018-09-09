//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#import "SandboxViewController.h"
#import "FilePreviewController.h"
#import "FileTableViewCell.h"
#import "Sandbox.h"
#import <QuickLook/QuickLook.h>
#import "FPSLabel.h"
#import "NetworkHelper.h"

#define MLBIsStringEmpty(string)                    (nil == string || (NSNull *)string == [NSNull null] || [@"" isEqualToString:string])
#define MLBIsStringNotEmpty(string)                 (string && (NSNull *)string != [NSNull null] && ![@"" isEqualToString:string])

@interface SandboxViewController () <QLPreviewControllerDataSource, UIViewControllerPreviewingDelegate>

@property (strong, nonatomic) NSMutableArray<MLBFileInfo *> *dataSource;

@property (strong, nonatomic) MLBFileInfo *previewingFileInfo;
@property (strong, nonatomic) MLBFileInfo *deletingFileInfo;

@property (strong, nonatomic) UIBarButtonItem *editItem;
@property (strong, nonatomic) UIBarButtonItem *deleteAllItem;
@property (strong, nonatomic) UIBarButtonItem *deleteItem;

@end

NSInteger const kMLBDeleteAlertViewTag = 101; // 左滑删除
NSInteger const kMLBDeleteAllAlertViewTag = 111; // Toolbar Delete All
NSInteger const kMLBDeleteSelectedAlertViewTag = 121; // Toolbar Delete

@implementation SandboxViewController {
    BOOL _isFirstAppear;
}

#pragma mark - liman
- (void)customNavigationBar
{
    //****** 以下代码从LogNavigationViewController.swift复制 ******
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationController.navigationBar.tintColor = [NetworkHelper shared].mainColor;
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSFontAttributeName:[UIFont boldSystemFontOfSize:20],
                                                                    NSForegroundColorAttributeName: [NetworkHelper shared].mainColor
                                                                    };
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_icon_file_type_close" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStyleDone target:self action:@selector(exit)];
    leftItem.tintColor = [NetworkHelper shared].mainColor;
    self.navigationController.topViewController.navigationItem.leftBarButtonItem = leftItem;
}

- (void)exit
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];    
    
    //liman
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:31/255.0 green:33/255.0 blue:36/255.0 alpha:1.0];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    if (MLBIsStringEmpty(self.title)) {
        if (self.isHomeDirectory) {
            [self customNavigationBar];//liman
            self.title = @"Sandbox";
        } else {
            self.title = self.fileInfo.displayName;
        }
    }
    
    [self initDatas];
    [self setupViews];
    [self registerForPreviewing];
    
    //liman
    self.view.backgroundColor = [UIColor blackColor];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //liman
    [self loadDirectoryContents];
    [self endEditing];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.tableView.isEditing) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

#pragma mark - Private Methods

- (void)initDatas {
    _isFirstAppear = YES;
}

- (void)setupViews {
    
    //liman
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_icon_file_type_close" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStyleDone target:self action:@selector(exit)];
    closeItem.tintColor = [NetworkHelper shared].mainColor;

    //liman
    if ([Sandbox shared].isFileDeletable || [Sandbox shared].isDirectoryDeletable) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:[NetworkHelper shared].mainColor forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        button.frame = CGRectMake(0, 0, 56, 34);
        [button setTitle:@"     Edit" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(editAction) forControlEvents:UIControlEventTouchUpInside];
        self.editItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        if (!self.homeDirectory) {
            self.navigationItem.rightBarButtonItems = @[closeItem, self.editItem];
        }else{
            self.navigationItem.rightBarButtonItem = self.editItem;
        }
    }else{
        if (!self.homeDirectory) {
            self.navigationItem.rightBarButtonItem = closeItem;
        }
    }
    
    
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.tableView registerClass:[FileTableViewCell class] forCellReuseIdentifier:FileTableViewCellReuseIdentifier];
    self.tableView.rowHeight = 60.0;
}

- (void)registerForPreviewing {
    if (@available(iOS 9.0, *)) {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            [self registerForPreviewingWithDelegate:self sourceView:self.view];
        }
    } else {
        // Fallback on earlier versions
        // do nothing by author
    }
}

- (void)loadDirectoryContents {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.dataSource = [MLBFileInfo contentsOfDirectoryAtURL:self.fileInfo.URL];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self updateToolbarItems];
            if (self->_isFirstAppear) {
                self->_isFirstAppear = NO;
            }
        });
    });
}

- (MLBFileInfo *)fileInfoAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataSource[indexPath.row];
}

- (UIViewController *)viewControllerWithFileInfo:(MLBFileInfo *)fileInfo {
    if (fileInfo.isDirectory) {
        SandboxViewController *sandboxViewController = [[SandboxViewController alloc] init];
//        sandboxViewController.hidesBottomBarWhenPushed = YES;//liman
        sandboxViewController.fileInfo = fileInfo;
        return sandboxViewController;
    } else {
        if ([Sandbox shared].isShareable && fileInfo.isCanPreviewInQuickLook) {
            self.previewingFileInfo = fileInfo;
            QLPreviewController *previewController = [[QLPreviewController alloc] init];
            previewController.dataSource = self;
            return previewController;
        } else {
            FilePreviewController *filePreviewController = [[FilePreviewController alloc] init];
            filePreviewController.hidesBottomBarWhenPushed = YES;//liman
            filePreviewController.fileInfo = fileInfo;
            return filePreviewController;
        }
    }
}

- (BOOL)isCanDeleteAll {
    if ((![Sandbox shared].isFileDeletable && ![Sandbox shared].isDirectoryDeletable) || self.dataSource.count == 0) {
        return NO;
    }
    
    NSInteger fileCount = 0;
    NSInteger directoryCount = 0;
    [self getDeletableFileCount:&fileCount directoryCount:&directoryCount];
    
    if (([Sandbox shared].isFileDeletable && ![Sandbox shared].isDirectoryDeletable && fileCount == 0) || // 只能删除文件,但是文件数为 0
        (![Sandbox shared].isFileDeletable && [Sandbox shared].isDirectoryDeletable && directoryCount == 0)) { // 只能删除文件夹,但是文件夹数为 0
        return NO;
    }
    
    return YES;
}

- (void)getDeletableFileCount:(NSInteger *)fileCount directoryCount:(NSInteger *)directoryCount {
    NSInteger fc = 0;
    NSInteger dc = 0;
    for (MLBFileInfo *fileInfo in self.dataSource) {
        if (fileInfo.isDirectory && [Sandbox shared].isDirectoryDeletable) {
            dc++;
        } else if (!fileInfo.isDirectory && [Sandbox shared].isFileDeletable) {
            fc++;
        }
    }
    
    *fileCount = fc;
    *directoryCount = dc;
}

- (void)updateToolbarItems {
    [self updateToolbarDeleteAllItem];
    [self updateToolbarDeleteItem];
}

- (void)updateToolbarDeleteAllItem {
    if (self.deleteAllItem) {
        BOOL isEnable = [self isCanDeleteAll];
        self.deleteAllItem.enabled = isEnable;
    }
}

- (void)updateToolbarDeleteItem {
    if (self.deleteItem) {
        self.deleteItem.enabled = self.tableView.indexPathsForSelectedRows.count > 0;
    }
}

- (NSString *)messageForDeleteWithFileCount:(NSInteger)fileCount directoryCount:(NSInteger)directoryCount {
    NSMutableString *message = [NSMutableString stringWithString:@"Are you sure to delete "];
    if ([Sandbox shared].isFileDeletable && fileCount > 0) {
        [message appendFormat:@"%ld files", (long)fileCount];
    }
    
    if ([Sandbox shared].isDirectoryDeletable && directoryCount > 0) {
        if ([Sandbox shared].isFileDeletable && fileCount > 0) {
            [message appendString:@", "];
        }
        
        [message appendFormat:@"%ld directories", (long)directoryCount];
    }
    
    [message appendString:@"?"];
    
    return message.copy;
}

- (UIAlertController *)alertControllerForDeleteWithMessage:(NSString *)message deleteHandler:(void (^ __nullable)(UIAlertAction *action))handler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:handler]];
    return alertController;
}

- (UIAlertView *)alertViewForDeleteWithMessage:(NSString *)message tag:(NSInteger)tag {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    alertView.tag = tag;
    return alertView;
}

#pragma mark - Action

- (void)editAction {
    if (!self.tableView.isEditing) {
        [self beginEditing];
    } else {
        [self endEditing];
    }
}

- (void)beginEditing {
    if (self.tableView.isEditing) { return; }
    self.tableView.editing = YES;
    [((UIButton *)self.editItem.customView) setTitle:@"Cancel" forState:UIControlStateNormal];
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    if (nil == self.deleteAllItem) {
        self.deleteAllItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete All" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAllAction)];
        self.deleteItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteSelectedFilesAction)];
        
        //liman
        [self.deleteAllItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} forState:UIControlStateNormal];
        [self.deleteItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} forState:UIControlStateNormal];
        [self.deleteAllItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:209/255.0 green:157/255.0 blue:157/255.0 alpha:1.0]} forState:UIControlStateHighlighted];
        [self.deleteItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:209/255.0 green:157/255.0 blue:157/255.0 alpha:1.0]} forState:UIControlStateHighlighted];
        
        
        [self setToolbarItems:@[self.deleteAllItem,
                                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                self.deleteItem] animated:YES];
    }
    
    [self updateToolbarItems];
}

- (void)endEditing {
    if (!self.tableView.isEditing) { return; }
    self.tableView.editing = NO;
    [((UIButton *)self.editItem.customView) setTitle:@"     Edit" forState:UIControlStateNormal];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)deleteAllAction {
    if (![self isCanDeleteAll]) {
        return;
    }
    
    NSInteger fileCount = 0;
    NSInteger directoryCount = 0;
    [self getDeletableFileCount:&fileCount directoryCount:&directoryCount];
    NSString *message = [self messageForDeleteWithFileCount:fileCount directoryCount:directoryCount];
    
    UIAlertController *alertController = [self alertControllerForDeleteWithMessage:message deleteHandler:^(UIAlertAction *action) {
        [self deleteAllFiles];
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)deleteSelectedFilesAction {
//    NSLog(@"mlb - %@, title = %@", NSStringFromSelector(_cmd), self.title);
    NSInteger fileCount = 0;
    NSInteger directoryCount = 0;
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        MLBFileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
//        NSLog(@"mlb - Delete file: %@", fileInfo.displayName);
        if (fileInfo.isDirectory) {
            directoryCount++;
        } else {
            fileCount++;
        }
    }
    
    NSString *message = [self messageForDeleteWithFileCount:fileCount directoryCount:directoryCount];
    
    UIAlertController *alertController = [self alertControllerForDeleteWithMessage:message deleteHandler:^(UIAlertAction *action) {
        [self deleteSelectedFiles];
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)deleteAllFiles {
//    NSLog(@"mlb - %@, title = %@", NSStringFromSelector(_cmd), self.title);
    NSMutableArray<MLBFileInfo *> *deletedFileInfos = [NSMutableArray arrayWithCapacity:self.dataSource.count];
    NSMutableArray<NSIndexPath *> *deletedIndexPaths = [NSMutableArray arrayWithCapacity:self.dataSource.count];
    [self.dataSource enumerateObjectsWithOptions:NSEnumerationReverse | NSEnumerationConcurrent usingBlock:^(MLBFileInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self deleteFile:obj]) {
//            NSLog(@"mlb - %@, idx = %lu, obj = %@", NSStringFromSelector(_cmd), idx, obj.displayName);
            [deletedIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
            [deletedFileInfos addObject:obj];
        }
    }];
    
    [self.dataSource removeObjectsInArray:deletedFileInfos];
    [self.tableView deleteRowsAtIndexPaths:deletedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self endEditing];
}

- (void)deleteSelectedFiles {
//    NSLog(@"mlb - %@, title = %@", NSStringFromSelector(_cmd), self.title);
    NSMutableArray<MLBFileInfo *> *deletedFileInfos = [NSMutableArray arrayWithCapacity:self.tableView.indexPathsForSelectedRows.count];
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        MLBFileInfo *fileInfo = self.dataSource[indexPath.row];
        if ([self deleteFile:fileInfo]) {
            [deletedFileInfos addObject:fileInfo];
        }
    }
    
    [self.dataSource removeObjectsInArray:deletedFileInfos];
    [self.tableView deleteRowsAtIndexPaths:self.tableView.indexPathsForSelectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self endEditing];
}

- (void)deleteSelectedFile {
    if ([self deleteFile:self.deletingFileInfo]) {
        NSInteger index = -1;
        index = [self.dataSource indexOfObject:self.deletingFileInfo];
        
        [self.dataSource removeObject:self.deletingFileInfo];
        if (index >= 0) {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        self.deletingFileInfo = nil;
    }
}

- (BOOL)deleteFile:(MLBFileInfo *)fileInfo {
    if (![Sandbox shared].isFileDeletable || // 是否可以删除文件
        (![Sandbox shared].isDirectoryDeletable && fileInfo.isDirectory)) { // 是否可以删除文件夹
        return NO;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileInfo.URL.path]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtURL:fileInfo.URL error:&error];
        if (error) {
//            NSLog(@"mlb - %@, file path: %@, error: %@", NSStringFromSelector(_cmd), fileInfo.URL.path, error.localizedDescription);
            return NO;
        } else {
//            NSLog(@"mlb - %@, file deleted", NSStringFromSelector(_cmd));
        }
    }
    
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FileTableViewCellReuseIdentifier forIndexPath:indexPath];
    MLBFileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:fileInfo.typeImageName inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    cell.textLabel.text = [Sandbox shared].isExtensionHidden ? fileInfo.displayName.stringByDeletingPathExtension : fileInfo.displayName;
    cell.accessoryType = fileInfo.isDirectory ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
//    cell.detailTextLabel.text = fileInfo.modificationDateText;
    
    //liman
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:fileInfo.modificationDateText];
    if ([attributedString length] >= 21) {
        [attributedString setAttributes:@{NSForegroundColorAttributeName: [NetworkHelper shared].mainColor, NSFontAttributeName: [UIFont boldSystemFontOfSize:12]} range:NSMakeRange(0, 21)];
    }
    cell.detailTextLabel.attributedText = [attributedString copy];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self fileInfoAtIndexPath:indexPath].isDirectory) {
        return [Sandbox shared].isDirectoryDeletable;
    } else {
        return [Sandbox shared].isFileDeletable;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    MLBFileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        NSLog(@"Clicked delete editing style");
        self.deletingFileInfo = fileInfo;
        NSMutableString *message = [NSMutableString string];
        if (fileInfo.isDirectory) {
            [message appendFormat:@"Are you sure to delete this directory(including %lu files(or directories) inside)?", (unsigned long)fileInfo.filesCount];
        } else {
            [message appendString:@"Are you sure to delete this file?"];
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self deleteSelectedFile];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MLBFileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
    if (tableView.isEditing) {
        if ((fileInfo.isDirectory && ![Sandbox shared].isDirectoryDeletable) || (!fileInfo.isDirectory && ![Sandbox shared].isFileDeletable)) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        } else {
            [self updateToolbarDeleteItem];
        }
    } else {
        
        //liman
        UIViewController *vc = [self viewControllerWithFileInfo:fileInfo];
        if ([vc isKindOfClass:[QLPreviewController class]]) {
            [self presentViewController:vc animated:YES completion:nil];
        }else{
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    MLBFileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
    if (tableView.isEditing) {
        if ((fileInfo.isDirectory && ![Sandbox shared].isDirectoryDeletable) || (!fileInfo.isDirectory && ![Sandbox shared].isFileDeletable)) {
            
        } else {
            [self updateToolbarDeleteItem];
        }
    }
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return self.previewingFileInfo ? 1 : 0;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.previewingFileInfo.URL;
}

#pragma mark - UIViewControllerPreviewingDelegate

/// Create a previewing view controller to be shown at "Peek".
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    // Obtain the index path and the cell that was pressed.
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    FileTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (!cell) { return nil; }
    
    MLBFileInfo *fileInfo = [self fileInfoAtIndexPath:indexPath];
    // Create a detail view controller and set its properties.
    UIViewController *detailViewController = [self viewControllerWithFileInfo:fileInfo];
    
    /*
     Set the height of the preview by setting the preferred content size of the detail view controller.
     Width should be zero, because it's not used in portrait.
     */
    detailViewController.preferredContentSize = CGSizeZero;
    
    // Set the source rect to the cell frame, so surrounding elements are blurred.
    if (@available(iOS 9.0, *)) {
        previewingContext.sourceRect = cell.frame;
    } else {
        // Fallback on earlier versions
        // do nothing by author
    }
    
    return detailViewController;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self showViewController:viewControllerToCommit sender:self];
}

@end
#pragma clang diagnostic pop
