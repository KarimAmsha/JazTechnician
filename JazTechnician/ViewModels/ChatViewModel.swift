//
//  ChatViewModel.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

//  ChatViewModel.swift
//  FreelanceApp
//  Created by Karim OTHMAN on 8.05.2025.

import SwiftUI
import FirebaseDatabase
import FirebaseMessaging

class ChatViewModel: ObservableObject {
    @Published var messages: [FirebaseMessage] = []
    @Published var chat: FirebaseChat?
    @Published var messageText: String = ""
    @Published var isOtherUserTyping: Bool = false

    private var dbRef = Database.database().reference()
    private var chatId: String
    let currentUserId: String
    private var listenerHandle: DatabaseHandle?
    private let userService = FirebaseUserService()
    private let pushService = PushNotificationService()
    private var typingTimer: Timer?
    @Published var users: [String: FirebaseUser] = [:]
    private var receiverId: String?

    init(chatId: String, currentUserId: String, receiverId: String?) {
        self.chatId = chatId
        self.currentUserId = currentUserId
        self.receiverId = receiverId

        print("11ss \(self.chatId)")
        print("1122 \(self.currentUserId)")

        #if DEBUG
        if chatId == "debug" {
            self.messages = [
                FirebaseMessage(id: "1", message: "أهلاً، هذا مثال!", messageDate: Int64(Date().timeIntervalSince1970 - 100), senderId: "user2"),
                FirebaseMessage(id: "2", message: "تجريب الرسائل", messageDate: Int64(Date().timeIntervalSince1970 - 60), senderId: "user1")
            ]
            self.chat = FirebaseChat(id: chatId, chatEnabled: true, lastMessage: "تجريب الرسائل", lastMessageDate: Int64(Date().timeIntervalSince1970 - 60), orderId: "ORD_TEST", senderId: "user1", receiverId: "user2", messagesList: nil)
            return
        }
        #endif

        observeMessages()
    }

    deinit {
        if let handle = listenerHandle {
            dbRef.child("messages").child(chatId).child("messagesList").removeObserver(withHandle: handle)
        }
        dbRef.child("typingStatus").child(chatId).child(currentUserId).removeValue()
    }

    private func observeMessages() {
        listenerHandle = dbRef.child("messages").child(chatId).child("messagesList")
            .observe(.value) { snapshot in
                var tempMessages: [FirebaseMessage] = []

                for child in snapshot.children {
                    if let snap = child as? DataSnapshot,
                       let dict = snap.value as? [String: Any] {
                        let message = FirebaseMessage(
                            id: dict["id"] as? String,
                            message: dict["message"] as? String,
                            messageDate: dict["messageDate"] as? Int64,
                            senderId: dict["senderId"] as? String
                        )
                        tempMessages.append(message)
                    }
                }

                DispatchQueue.main.async {
                    self.messages = tempMessages.sorted { ($0.messageDate ?? 0) < ($1.messageDate ?? 0) }
                }
            }

        dbRef.child("messages").child(chatId).observeSingleEvent(of: .value) { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let chat = FirebaseChat(
                    id: snapshot.key,
                    chatEnabled: dict["chatEnabled"] as? Bool,
                    lastMessage: dict["lastMessage"] as? String,
                    lastMessageDate: dict["lastMessageDate"] as? Int64,
                    orderId: dict["orderId"] as? String,
                    senderId: dict["senderId"] as? String,
                    receiverId: dict["receiverId"] as? String,
                    messagesList: nil
                )
                DispatchQueue.main.async {
                    self.chat = chat
                    self.observeTypingStatus()
                }
            }
        }
    }

    func sendMessage() {
        guard let receiverId = self.receiverId, !receiverId.isEmpty else {
            print("🚨 Error: receiverId is nil or empty")
            return
        }

        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("❌ Empty message")
            return
        }

        let timestamp = Int(Date().timeIntervalSince1970)
        let messageId = UUID().uuidString

        // في حال ما تم تحميل chat بعد
        if chat == nil {
            print("🆕 إنشاء شات جديد تلقائيًا")

            // مؤقتًا خمن الطرف الآخر
            let receiverIdGuess = self.receiverId ?? (currentUserId == UserSettings.shared.id ? nil : UserSettings.shared.id)

            let newChat: FirebaseChat = FirebaseChat(
                id: chatId,
                chatEnabled: true,
                lastMessage: messageText,
                lastMessageDate: Int64(timestamp),
                orderId: nil,
                senderId: currentUserId,
                receiverId: receiverIdGuess,
                messagesList: nil
            )

            let chatData: [String: Any] = [
                "chatEnabled": true,
                "senderId": newChat.senderId ?? "",
                "receiverId": newChat.receiverId ?? "",
                "lastMessage": messageText,
                "lastMessageDate": timestamp
            ]

            dbRef.child("messages").child(chatId).setValue(chatData)

            DispatchQueue.main.async {
                self.chat = newChat
            }
        } else {
            dbRef.child("messages").child(chatId).updateChildValues([
                "lastMessage": messageText,
                "lastMessageDate": timestamp
            ])
        }

        // أضف الرسالة
        let messageData: [String: Any] = [
            "id": messageId,
            "message": messageText,
            "messageDate": timestamp,
            "senderId": currentUserId
        ]

        let newMessageRef = dbRef.child("messages").child(chatId).child("messagesList").child(messageId)
        newMessageRef.setValue(messageData)

        // إشعار للطرف الآخر
        if let receiverId = chat?.senderId == currentUserId ? chat?.receiverId : chat?.senderId {
            userService.fetchUser(userId: receiverId) { user in
                if let token = user?.fcmToken {
                    self.pushService.sendPush(
                        to: token,
                        title: "رسالة جديدة",
                        body: self.messageText
                    )
                }
            }
        }

        messageText = ""
        stopTyping()
    }

    func startTyping() {
        dbRef.child("typingStatus").child(chatId).child(currentUserId).setValue(true)
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.stopTyping()
        }
    }

    func stopTyping() {
        dbRef.child("typingStatus").child(chatId).child(currentUserId).setValue(false)
    }

    private func observeTypingStatus() {
        guard let chat = chat else { return }
        let otherUserId = chat.senderId == currentUserId ? chat.receiverId : chat.senderId

        if let otherUserId = otherUserId {
            dbRef.child("typingStatus").child(chatId).child(otherUserId)
                .observe(.value) { snapshot in
                    let isTyping = snapshot.value as? Bool ?? false
                    DispatchQueue.main.async {
                        self.isOtherUserTyping = isTyping
                    }
                }
        }
    }
}

class MockChatViewModel: ChatViewModel {
    init() {
        super.init(chatId: "mock_chat_id", currentUserId: "user1", receiverId: "user2")
        self.messages = [
            FirebaseMessage(id: "1", message: "مرحبا، كيف فيني أساعدك؟", messageDate: Int64(Date().timeIntervalSince1970 - 300), senderId: "user2"),
            FirebaseMessage(id: "2", message: "عندي استفسار عن الخدمة اللي بتقدمها", messageDate: Int64(Date().timeIntervalSince1970 - 200), senderId: "user1"),
            FirebaseMessage(id: "3", message: "تفضل، احكيلي التفاصيل", messageDate: Int64(Date().timeIntervalSince1970 - 100), senderId: "user2")
        ]
        self.chat = FirebaseChat(
            id: "mock_chat_id",
            chatEnabled: true,
            lastMessage: "تفضل، احكيلي التفاصيل",
            lastMessageDate: Int64(Date().timeIntervalSince1970 - 100),
            orderId: "ORD999",
            senderId: "user1",
            receiverId: "user2",
            messagesList: nil
        )
        self.isOtherUserTyping = true
    }
}

extension ChatViewModel {
    func isValidFirebaseKey(_ key: String?) -> Bool {
        guard let key = key, !key.isEmpty else { return false }
        let forbiddenCharacters = CharacterSet(charactersIn: ".$#[]")
        return key.rangeOfCharacter(from: forbiddenCharacters) == nil
    }

    func fetchUserIfNeeded(for userId: String) {
        print("👀 Trying to fetch userId: \(userId)")

        guard !userId.isEmpty,
              userId.rangeOfCharacter(from: CharacterSet(charactersIn: ".$#[]")) == nil else {
            print("❌ Invalid Firebase Key: \(userId)")
            return
        }

        guard users[userId] == nil else {
            print("ℹ️ User already loaded: \(userId)")
            return
        }

        let ref = Database.database().reference().child("user").child(userId)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                print("❌ Snapshot empty or invalid for userId: \(userId)")
                return
            }

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: value)
                let user = try JSONDecoder().decode(FirebaseUser.self, from: jsonData)
                print("✅ User fetched: \(user.displayName)")
                DispatchQueue.main.async {
                    self.users[userId] = user
                }
            } catch {
                print("❌ Decoding error for userId \(userId): \(error)")
            }
        }
    }

    func getUser(for userId: String) -> FirebaseUser? {
        guard !userId.isEmpty, userId.rangeOfCharacter(from: CharacterSet(charactersIn: ".$#[]")) == nil else { return nil }

        if let user = users[userId] {
            print("1111 \(user)")
            return user
        }
        // جلب من الداتابيز إذا لم يكن موجود
        let ref = Database.database().reference().child("user").child(userId)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: value)
                let user = try JSONDecoder().decode(FirebaseUser.self, from: jsonData)
                print("22222 \(user)")
                DispatchQueue.main.async {
                    self.users[userId] = user
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        return nil // أول مرة، البيانات ليست جاهزة
    }
}

extension ChatViewModel {
    static func setUser(completion: ((Error?) -> Void)? = nil) {
        guard let userId = UserSettings.shared.id else {
            completion?(NSError(domain: "Missing UserID", code: 0))
            return
        }
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("فشل في الحصول على FCM Token: \(error.localizedDescription)")
            }
            let fcmToken = token ?? UserSettings.shared.fcmToken ?? ""
            UserSettings.shared.fcmToken = fcmToken
            
            let ref = Database.database().reference().child("user").child(userId)
            let userData: [String: Any] = [
                "id": userId,
                "name": UserSettings.shared.user?.full_name ?? "",
                "image": UserSettings.shared.user?.image ?? "",
                "fcmToken": fcmToken,
                "lastOnline": Int(Date().timeIntervalSince1970),
                "online": true
            ]
            
            ref.setValue(userData) { error, _ in
                if let error = error {
                    print("فشل تحديث بيانات المستخدم: \(error.localizedDescription)")
                } else {
                    print("✅ تم تحديث بيانات المستخدم بنجاح")
                }
                completion?(error)
            }
        }
    }
}

