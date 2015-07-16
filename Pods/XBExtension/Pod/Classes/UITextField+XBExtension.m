//
//  UITextField+XBExtension.m
//  Pods
//
//  Created by Binh Nguyen Xuan on 7/3/15.
//
//

#import "UITextField+XBExtension.h"
#import <objc/runtime.h>

NSString * const kDisabledCharacterSet = @"kDisabledCharacterSet";

@implementation UITextField (XBExtension)
@dynamic disabledCharacterSet;

- (void)setDisabledCharacterSet:(NSCharacterSet *)disabledCharacterSet
{
    objc_setAssociatedObject(self, (__bridge const void *)(kDisabledCharacterSet), disabledCharacterSet, OBJC_ASSOCIATION_RETAIN);
    if (disabledCharacterSet)
    {
        [self addTarget:self action:@selector(didChangeText:) forControlEvents:UIControlEventEditingChanged];
    }
}

- (void)didChangeText:(id)sender
{
    self.text = [[self.text componentsSeparatedByCharactersInSet:self.disabledCharacterSet] componentsJoinedByString:@""];
}

- (id)disabledCharacterSet
{
    return objc_getAssociatedObject(self, (__bridge const void *)(kDisabledCharacterSet));
}

- (void)activeUsernameLimitation
{
    self.disabledCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_."] invertedSet];
}

- (void)activePasswordLimitation
{
    self.disabledCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_."] invertedSet];
}

- (void)activeEmailLimitation
{
    self.disabledCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.@"] invertedSet];
}

@end
