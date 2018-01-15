//
//  JxbHttpModel.m
//  PhiHome
//
//  Created by liman on 11/12/2017.
//  Copyright © 2017 Phicomm. All rights reserved.
//

#import "JxbHttpModel.h"

@implementation JxbHttpModel

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    JxbHttpModel *model = [JxbHttpModel new];
    model.url = _url;
    model.requestData = _requestData;
    model.responseData = _responseData;
    model.requestId = _requestId;
    model.method = _method;
    model.statusCode = _statusCode;
    model.mineType = _mineType;
    model.startTime = _startTime;
    model.totalDuration = _totalDuration;
    model.isImage = _isImage;
    model.localizedErrorMsg = _localizedErrorMsg;
    model.headerFields = _headerFields;
    model.isTag = _isTag;
    model.isSelected = _isSelected;
    model.requestSerializer = _requestSerializer;
    
    return model;
}

@end



