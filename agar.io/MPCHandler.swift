//
//  MPCHandler.swift
//  TicTacToe
//
//  Created by Xingyuji on 7/10/2015.
//  Copyright © 2015 com.xingyuji. All rights reserved.
//

import UIKit
import MultipeerConnectivity

// create different types of messages to communicate
enum MessageType: Int {
    case PlayerInfo, FoodInfo, VirusInfo, EncounterViruse, SceneSet, CellInfo
}
struct Message {
    let messageType: MessageType
}

struct PlayerInfo {
    let message: Message
    let player: Player
}

struct FoodInfo {
    let message: Message
    let food: Food
    let x: CGFloat
    let y:CGFloat
}

struct ViruseInfo {
    let message: Message
    let viruse: Viruse
}

struct SceneSet {
    let message: Message
    var foodList: [Food]
    var viruseList: [Viruse]
}

struct EncounterViruse {
    let message: Message
    let player: Player
}

struct CellInfo {
    let message: Message
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let name: String?
}



class MPCHandler: NSObject, MCSessionDelegate {
    var delegate : MPCHandlerDelegate?
    var peerID:MCPeerID!
    var session:MCSession!
    var browser:MCBrowserViewController!
    var advertiser:MCAdvertiserAssistant? = nil
    
    func setupPeerWithDisplayerName(displayName:String){
        peerID = MCPeerID(displayName: displayName)
    }
    
    func setupSession(){
        session = MCSession(peer: peerID)
        session.delegate = self
    }
    
    func setupBrowser(){
        browser = MCBrowserViewController(serviceType: "my-game", session: session)
    }
    
    func advertiseSelf(advertise:Bool){
        if advertise{
            advertiser = MCAdvertiserAssistant(serviceType: "my-game", discoveryInfo: nil, session: session)
            advertiser!.start()
        } else {
            advertiser!.stop()
            advertiser = nil
        }
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        let userInfo = ["peerID":peerID,"state":state.rawValue]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("MPC_DidChangeStateNotification", object: nil, userInfo: userInfo)
         
            switch state{
            case MCSessionState.Connected:
                print("Connected to session: \(session)\n")
                //            delegate?.connectedWithPeer(peerID)
                self.delegate?.connectedDevicesChanged(self, connectedDevices: session.connectedPeers.map({$0.displayName}))
                break
            case MCSessionState.Connecting:
                print("Connecting to session: \(session)\n")
                break
            case MCSessionState.NotConnected:
                print("not Connecting to session: \(session)\n")
                break
            default:
                print("Did not connect to session: \(session)\n")
                break
            }
        })
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        var message = UnsafePointer<Message>(data.bytes).memory
        if message.messageType == MessageType.SceneSet {
            let sceneSet = UnsafePointer<SceneSet>(data.bytes).memory
            self.delegate?.sceneSet(self, scene: sceneSet)
        }
        else if message.messageType == MessageType.FoodInfo {
            let foodInfo = UnsafePointer<FoodInfo>(data.bytes).memory
            self.delegate?.foodInfo(self, food: foodInfo.food, x: foodInfo.x, y: foodInfo.y)
        }
        else if message.messageType == MessageType.CellInfo {
            let cellInfo: CellInfo = self.decode(data)
            self.delegate?.cellInfo(self,x: cellInfo.x, y: cellInfo.y, size: cellInfo.size, name: cellInfo.name)
        }
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func sendData(data:NSData) {
        if session.connectedPeers.count > 0 {
            do {
                try session.sendData(data, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func encode<T>(var value: T) -> NSData {
        return withUnsafePointer(&value) { p in
            NSData(bytes: p, length: sizeofValue(value))
        }
    }
    
    func decode<T>(data: NSData) -> T {
        let pointer = UnsafeMutablePointer<T>.alloc(sizeof(T.Type))
        data.getBytes(pointer)
        
        return pointer.move()
    }
    
}

protocol MPCHandlerDelegate {
    
    func peerDisconnected(manager : MPCHandler, peer: MCPeerID)
    func connectedDevicesChanged(manager : MPCHandler, connectedDevices: [String])
    func otherPeerMoved(manager : MPCHandler, axis: String)
    func sceneSet(manager: MPCHandler, scene: SceneSet)
    func foodInfo(manager: MPCHandler, food: Food, x: CGFloat, y: CGFloat)
    func cellInfo(manager: MPCHandler, x: CGFloat, y: CGFloat, size: CGFloat, name: String?)
}
