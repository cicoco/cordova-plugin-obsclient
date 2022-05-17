#import "CDVObsClient.h"

#import <OBS/OBS.h>
#import "HWCredential.h"

@implementation CDVObsClient

- (void) upload:(CDVInvokedUrlCommand*) command
{
    // 文件地址
    NSString* filePath = [command.arguments objectAtIndex:0];
    HWCredential* credential = [HWCredential new];
    credential.ak = [command.arguments objectAtIndex:1];
    credential.sk = [command.arguments objectAtIndex:2];
    credential.endpoint = [command.arguments objectAtIndex:3];
    credential.bucket = [command.arguments objectAtIndex:4];
    credential.prefix = [command.arguments objectAtIndex:5];
    credential.token = [command.arguments objectAtIndex:6];
    
    NSString* fileName = [command.arguments objectAtIndex:7];
    
    if([filePath hasPrefix:@"file://"]){
        filePath  = [filePath substringFromIndex:7];
    }
    
    __weak CDVObsClient* weakSelf = self;
    [self.commandDelegate runInBackground:^{
        
        if(!credential){
             [weakSelf.commandDelegate sendPluginResult: [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
            return;
        }
        
        OBSStaticCredentialProvider *credentailProvider = [[OBSStaticCredentialProvider alloc] initWithAccessKey:credential.ak secretKey:credential.sk];
        credentailProvider.securityToken = credential.token;
        
        OBSServiceConfiguration *conf = [[OBSServiceConfiguration alloc] initWithURLString:credential.endpoint credentialProvider:credentailProvider];
        OBSClient *client  = [[OBSClient alloc] initWithConfiguration:conf];
        
        NSString* _fileName = (fileName == nil || fileName.length == 0)? [filePath lastPathComponent] : fileName;
        NSString* objectKey = [credential.prefix stringByAppendingString:_fileName];
        
        OBSPutObjectWithFileRequest *request = [[OBSPutObjectWithFileRequest alloc]initWithBucketName:credential.bucket objectKey:objectKey uploadFilePath:filePath];

        // 同步上传文件
        BOOL result = [weakSelf syncPutObject:client request:request];
        CDVPluginResult* pluginResult = nil;
        if (result) {
            NSURL* url = [NSURL URLWithString:credential.endpoint];
            NSString* returned = [NSString stringWithFormat:@"%@://%@.%@/%@", [url scheme], credential.bucket, [url host], objectKey];
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:returned];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
    
}

-(BOOL) syncPutObject:(OBSClient*)client request:(OBSPutObjectWithFileRequest*)request
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL result;
    [client putObject:request completionHandler:^(OBSPutObjectResponse *response, NSError *error){

        if(!error && [@"200" isEqualToString:response.statusCode]){
            result = YES;
        } else {
            result = NO;
        }
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return result;
}

- (NSString *)createUUID
{
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidObject));
    CFRelease(uuidObject);
    return uuidStr;
}

@end
