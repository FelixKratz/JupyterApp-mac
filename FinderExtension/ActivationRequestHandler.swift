//
//  ActionViewController.swift
//  FinderExtension
//
//  Created by Felix Kratz on 18.11.20.
//  Copyright © 2020 fk. All rights reserved.
//

import Cocoa

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        print("Moin")
        // For an Action Extension there will only ever be one extension item.
        precondition(context.inputItems.count == 1)
        guard let inputItem = context.inputItems[0] as? NSExtensionItem
            else { preconditionFailure("Expected an extension item") }

        // The extension item's attachments hold the set of files to process.
        guard let inputAttachments = inputItem.attachments
            else { preconditionFailure("Expected a valid array of attachments") }
        precondition(inputAttachments.isEmpty == false, "Expected at least one attachment")

        // Use a dispatch group to synchronise asynchronous calls to loadInPlaceFileRepresentation.
        let dispatchGroup = DispatchGroup()

        dispatchGroup.notify(queue: DispatchQueue.main) {
            let outputItem = NSExtensionItem()
            context.completeRequest(returningItems: [outputItem], completionHandler: nil)
        }
    }
}
