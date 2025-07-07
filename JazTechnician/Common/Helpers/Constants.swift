//
//  Constants.swift
//  Khawi
//
//  Created by Karim Amsha on 6.11.2023.
//

import Foundation
import Alamofire
import Firebase

struct Constants {
    static let baseURL = "https://fazzaa-a48e8d79fa23.herokuapp.com/api"
    static let apiKey = "f8dd3a017f39b886c815f5cb248d26a2" // API KEY
    static let FCMLink = "https:fcm.googleapis.com/fcm/send"
    static let serverkey            = "AAAAbK-sj9o:APA91bGuybNZ8Z5t92aAvWb83iLvGmHgcl3kmxpERQFYeH96SmdwaCPrKD7ZYQZyeonezalAi-iB-SIYpNFnG3XIlHMYZbEA3mvbP0RvVUUHprVFzQfBjU4JEe_Hha5nq4nx1jktE2Sk"
    static let headers: HTTPHeaders = ["Authorization":"key = \(serverkey)", "Accept": "application/json"]
    static let dbRef                = Database.database().reference()
    static let usersRef             = dbRef.child("user")
    static let userLocationRef      = dbRef.child("userLocation")
    static let trackingRef          = dbRef.child("tracking")
    static let messagesRef          = dbRef.child("messages")
    static let messagesList         = "messagesList"   
    static let lastMessage          = "lastMessage"
    static let lastMessageDate      = "lastMessageDate"
    static let receiverId           = "receiverId"
    static let senderId             = "senderId"
    static let chatEnabled          = "chatEnabled"
    static let id                   = "id"
    static let orderId              = "orderId"
    static let distance             = 50.0
}
