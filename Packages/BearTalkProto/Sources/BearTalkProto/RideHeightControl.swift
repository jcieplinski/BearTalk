import SwiftProtobuf

public struct Mobilegateway_Protos_RideHeightControlRequest: Sendable {
    public var targetHeight: Mobilegateway_Protos_RideHeightStatus = .unknown
    public var vehicleID: String = String()
    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}
}

public struct Mobilegateway_Protos_RideHeightControlResponse: Sendable {
    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}
}

extension Mobilegateway_Protos_RideHeightControlRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
    public static let protoMessageName: String = "mobilegateway.protos.RideHeightControlRequest"
    public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .standard(proto: "target_height"),
        2: .standard(proto: "vehicle_id"),
    ]

    public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
        while let fieldNumber = try decoder.nextFieldNumber() {
            switch fieldNumber {
            case 1: try { try decoder.decodeSingularEnumField(value: &self.targetHeight) }()
            case 2: try { try decoder.decodeSingularStringField(value: &self.vehicleID) }()
            default: break
            }
        }
    }

    public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
        if self.targetHeight != .unknown {
            try visitor.visitSingularEnumField(value: self.targetHeight, fieldNumber: 1)
        }
        if !self.vehicleID.isEmpty {
            try visitor.visitSingularStringField(value: self.vehicleID, fieldNumber: 2)
        }
        try unknownFields.traverse(visitor: &visitor)
    }

    public static func == (lhs: Mobilegateway_Protos_RideHeightControlRequest, rhs: Mobilegateway_Protos_RideHeightControlRequest) -> Bool {
        if lhs.targetHeight != rhs.targetHeight { return false }
        if lhs.vehicleID != rhs.vehicleID { return false }
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}

extension Mobilegateway_Protos_RideHeightControlResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
    public static let protoMessageName: String = "mobilegateway.protos.RideHeightControlResponse"
    public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

    public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
        while try decoder.nextFieldNumber() != nil {}
    }

    public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
        try unknownFields.traverse(visitor: &visitor)
    }

    public static func == (lhs: Mobilegateway_Protos_RideHeightControlResponse, rhs: Mobilegateway_Protos_RideHeightControlResponse) -> Bool {
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}
