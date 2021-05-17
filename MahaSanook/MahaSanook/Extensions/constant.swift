//
//  constant.swift
//  MahaSanook
//
//  Created by Napassorn V. on 4/12/2563 BE.
//

import Foundation
import Firebase
import UIKit

struct Constants
{
    struct refs
    {
        static let databaseRoot = Database.database().reference()
        static let databaseChats = databaseRoot.child("chats")
    }
}

struct createUser
{
    struct refs
    {
        static let databaseRoot = Database.database().reference()
        static let databaseUser = databaseRoot.child("user")
    }
}


struct UsernameCreate
{
    struct refs
    {
        static let databaseRoot = Database.database().reference()
        static let databaseUsername = databaseRoot.child("username")
    }
}
struct Friends
{
    struct refs
    {
        static let databaseRoot = Database.database().reference()
        static let databaseFriends = databaseRoot.child("friends")
    }
}

struct GameHistory
{
    struct refs
    {
        static let databaseRoot = Database.database().reference()
        static let Game = databaseRoot.child("game")
    }
}
