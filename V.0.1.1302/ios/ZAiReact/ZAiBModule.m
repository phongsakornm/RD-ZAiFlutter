//
// ZAiBModule.m
// Copyright R&D Computer System Co., Ltd.

#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"

@interface RCT_EXTERN_MODULE(ZAiBModule, NSObject)
RCT_EXTERN_METHOD(getFilesDirBM:(RCTPromiseResolveBlock)resolve Failed:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(openLibBM:(NSString *)Parameter_OpenLib resolve:(RCTPromiseResolveBlock)resolve Failed:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getReaderListBM:(RCTPromiseResolveBlock)resolve Failed:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(selectReaderBM:(NSString *)textReaderName resolve:(RCTPromiseResolveBlock)resolve Failed:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getReaderInfoBM:(RCTPromiseResolveBlock)resolve Failed:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getReaderIDBM:(RCTPromiseResolveBlock)resolve Failed:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(connectCardBM:(RCTPromiseResolveBlock)resolve Failed:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(disconnectCardBM:(RCTPromiseResolveBlock)resolve Failed:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getTextBM:(RCTPromiseResolveBlock)resolve Failed:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getSTextBM:(NSString *)aKey resolve:(RCTPromiseResolveBlock)resolve Failed:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getPhotoBM:(RCTPromiseResolveBlock)resolve Failed:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getNIDNumberBM:(RCTPromiseResolveBlock)resolve Failed:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(updateLicenseFileBM:(RCTPromiseResolveBlock)resolve Failed:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getCardStatusBM:(RCTPromiseResolveBlock)resolve Failed:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(deselectReaderBM:(RCTPromiseResolveBlock)resolve Failed:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(closeLibBM:(RCTPromiseResolveBlock)resolve Failed:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getLicenseInfoBM:(RCTPromiseResolveBlock)resolve Failed:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getSoftwareInfoBM:(RCTPromiseResolveBlock)resolve Failed:(RCTPromiseRejectBlock)reject)
@end
