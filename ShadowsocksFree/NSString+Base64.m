//
//  NSString+Base64.m
//  QRCreat
//
//  Created by 成璐飞 on 16/6/5.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

#import "NSString+Base64.h"

@implementation NSString (Base64)

- (NSString *)base64EncodedString;
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

@end
