//
//  XBPCViewController.m
//  XBPushChat
//
//  Created by eugenenguyen on 12/05/2014.
//  Copyright (c) 2014 eugenenguyen. All rights reserved.
//

#import "XBPCViewController.h"
#import <XBMobile.h>
#import <XBPCMessageViewController.h>
#import <XBPC_storageConversation.h>

@interface XBPCViewController () <XBTableViewDelegate>

@end

@implementation XBPCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - XBTableViewDelegate

- (UITableViewCell *)xbTableView:(XBTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withPreparedCell:(UITableViewCell *)cell withItem:(XBPC_storageConversation *)item
{
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    label.text = [@([item numberOfUnreadMessage]) stringValue];
    return cell;
}

- (void)xbTableView:(XBTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath forItem:(XBPC_storageConversation *)item
{
    XBPCMessageViewController *messageViewController = [[XBPCMessageViewController alloc] init];
    if ([item.sender intValue] == [[XBPushChat sharedInstance] sender_id])
    {
        messageViewController.sender_id = [item.sender intValue];
        messageViewController.receiver_id = [item.receiver intValue];
    }
    else
    {
        messageViewController.sender_id = [item.receiver intValue];
        messageViewController.receiver_id = [item.sender intValue];
    }
    messageViewController.room = item.room;
    messageViewController.senderDisplayName = [item.sender stringValue];
    messageViewController.receiverDisplayName = [item.receiver stringValue];
    [self.navigationController pushViewController:messageViewController animated:YES];
}

@end
