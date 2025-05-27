//
//  BodyState.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct BodyState: Codable, Equatable {
    var doorLocks: LockState
    var frontCargo: DoorState
    var rearCargo: DoorState
    let frontLeftDoor: DoorState
    let frontRightDoor: DoorState
    let rearLeftDoor: DoorState
    let rearRightDoor: DoorState
    var chargePortState: DoorState
    let walkawayLockSts: WalkawayState
    let keyfobBatteryStatus: KeyfobBatteryStatus
    let windowPosition: WindowPosition
    let accessTypeSts: AccessRequest
    
    internal init(proto: Mobilegateway_Protos_BodyState) {
        self.doorLocks = LockState(proto: proto.doorLocks)
        self.frontCargo = DoorState(proto: proto.frontCargo)
        self.rearCargo = DoorState(proto: proto.rearCargo)
        self.frontLeftDoor = DoorState(proto: proto.frontLeftDoor)
        self.frontRightDoor = DoorState(proto: proto.frontRightDoor)
        self.rearLeftDoor = DoorState(proto: proto.rearLeftDoor)
        self.rearRightDoor = DoorState(proto: proto.rearRightDoor)
        self.chargePortState = DoorState(proto: proto.chargePort)
        self.windowPosition = WindowPosition(proto: proto.windowPosition)
        self.walkawayLockSts = WalkawayState(proto: proto.walkawayLock)
        self.keyfobBatteryStatus = KeyfobBatteryStatus(proto: proto.keyfobBatteryStatus)
        self.accessTypeSts = AccessRequest(proto: proto.accessTypeStatus)
    }
}

struct WindowPosition: Codable, Equatable {
    var leftFront: WindowPositionStatus
    var leftRear: WindowPositionStatus
    var rightFront: WindowPositionStatus
    var rightRear: WindowPositionStatus
    
    init(proto: Mobilegateway_Protos_WindowPositionState) {
        leftFront = WindowPositionStatus(proto: proto.leftFront)
        leftRear = WindowPositionStatus(proto: proto.leftRear)
        rightFront = WindowPositionStatus(proto: proto.rightFront)
        rightRear = WindowPositionStatus(proto: proto.rightRear)
    }
    
    var isOpen: Bool {
        return leftFront != .fullyClosed && leftRear != .fullyClosed && rightFront != .fullyClosed && rightRear != .fullyClosed
    }
}

enum WindowPositionStatus: Codable, Equatable {
    case unknown // = 0
    case fullyClosed // = 1
    case aboveShortDropPosition // = 2
    case shortDropPosition // = 3
    case belowShortDropPosition // = 4
    case fullyOpen // = 5
    case unknownDeInitialized // = 6
    case atpReversePosition // = 7
    case anticlatterPosition // = 8
    case hardStopUp // = 9
    case hardStopDown // = 10
    case longDropPosition // = 11
    case ventDropPosition // = 12
    case betweenFullyClosedAndShortDropDown // = 13
    case betweenShortDropDownAndFullyOpen // = 14
    case UNRECOGNIZED(Int)
    
    var isOpen: Bool {
        return self != .fullyClosed
    }
    
    var image: String {
        switch self {
            
        case .unknown, .fullyClosed, .unknownDeInitialized, .atpReversePosition, .hardStopUp, .UNRECOGNIZED:
            "windowClosed"
        case .aboveShortDropPosition, .shortDropPosition, .anticlatterPosition, .ventDropPosition, .betweenFullyClosedAndShortDropDown, .betweenShortDropDownAndFullyOpen:
            "windowVent"
        case .belowShortDropPosition, .fullyOpen, .longDropPosition, .hardStopDown:
            "windowOpen"
        }
    }
    
    var positionTitle: String {
        switch self {
        case .unknown, .fullyClosed, .unknownDeInitialized, .atpReversePosition, .hardStopUp, .UNRECOGNIZED:
            "Closed"
        case .aboveShortDropPosition, .shortDropPosition, .anticlatterPosition, .ventDropPosition, .betweenFullyClosedAndShortDropDown, .betweenShortDropDownAndFullyOpen, .belowShortDropPosition:
            "Partially Open"
        case .fullyOpen, .longDropPosition, .hardStopDown:
            "Open"
        }
    }
    
    init(proto: Mobilegateway_Protos_WindowPositionStatus) {
        switch proto {
        case .unknown: self = .unknown
        case .fullyClosed: self = .fullyClosed
        case .aboveShortDropPosition: self = .aboveShortDropPosition
        case .shortDropPosition: self = .shortDropPosition
        case .belowShortDropPosition: self = .belowShortDropPosition
        case .fullyOpen: self = .fullyOpen
        case .unknownDeInitialized: self = .unknownDeInitialized
        case .atpReversePosition: self = .atpReversePosition
        case .anticlatterPosition: self = .anticlatterPosition
        case .hardStopUp: self = .hardStopUp
        case .hardStopDown: self = .hardStopDown
        case .longDropPosition: self = .longDropPosition
        case .ventDropPosition: self = .ventDropPosition
        case .betweenFullyClosedAndShortDropDown: self = .betweenFullyClosedAndShortDropDown
        case .betweenShortDropDownAndFullyOpen: self = .betweenShortDropDownAndFullyOpen
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum DoorState: Codable, Equatable {
    case unknown // = 0
    case `open` // = 1
    case closed // = 2
    case ajar // = 3
    case closeError // = 4
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_DoorState) {
        switch proto {
        case .unknown:
            self = .unknown
        case .open:
            self = .open
        case .closed:
            self = .closed
        case .ajar:
            self = .ajar
        case .closeError:
            self = .closeError
        case .UNRECOGNIZED(let int):
            self = .UNRECOGNIZED(int)
        }
    }
    
    var intValue: Int {
        switch self {
        case .unknown: 0
        case .open: 1
        case .closed: 2
        case .ajar: 3
        case .closeError: 4
        case .UNRECOGNIZED(let int): int
        }
    }
    
    var frunkImage: String {
        switch self {
        case .open, .ajar:
            return "frunkOpen"
        case .closed:
            return "frunkClosed"
        case .unknown, .UNRECOGNIZED(_), .closeError:
            return "frunkClosed"
        }
    }
    
    var trunkImage: String {
        switch self {
        case .open, .ajar:
            return "trunkOpen"
        case .closed:
            return "trunkClosed"
        case .unknown, .UNRECOGNIZED(_), .closeError:
            return "trunkClosed"
        }
    }
    
    var chargePortImage: String {
        switch self {
        case .open, .ajar:
            return "chargePortOpen"
        case .closed:
            return "chargePortClosed"
        case .unknown, .UNRECOGNIZED(_), .closeError:
            return "chargePortClosed"
            
        }
    }
}

enum WalkawayState: Codable, Equatable {
    case walkawayUnknown // = 0
    case walkawayIdle // = 1
    case walkawayActive // = 2
    case walkawayDisable // = 3
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_WalkawayState) {
        switch proto {
        case .walkawayUnknown:
            self = .walkawayUnknown
        case .walkawayActive:
            self = .walkawayActive
        case .walkawayIdle:
            self = .walkawayIdle
        case .walkawayDisable:
            self = .walkawayDisable
        case .UNRECOGNIZED(let int):
            self = .UNRECOGNIZED(int)
        }
    }
}

enum AccessRequest: Codable, Equatable {
    case unknown // = 0
    case active // = 1
    case passive // = 2
    case passiveDriver // = 3
    case passiveTempDisabled // = 4
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_AccessRequest) {
        switch proto {
        case .unknown:
            self = .unknown
        case .active:
            self = .active
        case .passive:
            self = .passive
        case .passiveDriver:
            self = .passiveDriver
        case .passiveTempDisabled:
            self = .passiveTempDisabled
        case .UNRECOGNIZED(let int):
            self = .UNRECOGNIZED(int)
        }
    }
}
