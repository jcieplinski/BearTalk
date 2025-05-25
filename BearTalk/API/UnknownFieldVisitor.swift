//
//  UnknownFieldVisitor.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/24/25.
//

import Foundation
import SwiftProtobuf

class UnknownFieldVisitor: SwiftProtobuf.Visitor {
    func visitMapField<KeyType, ValueType>(fieldType: SwiftProtobuf._ProtobufMap<KeyType, ValueType>.Type, value: SwiftProtobuf._ProtobufMap<KeyType, ValueType>.BaseType, fieldNumber: Int) throws where KeyType : SwiftProtobuf.MapKeyType, ValueType : SwiftProtobuf.MapValueType {
        print("Unknown field \(fieldNumber) with map value: \(value)")
    }
    
    func visitMapField<KeyType, ValueType>(fieldType: SwiftProtobuf._ProtobufEnumMap<KeyType, ValueType>.Type, value: SwiftProtobuf._ProtobufEnumMap<KeyType, ValueType>.BaseType, fieldNumber: Int) throws where KeyType : SwiftProtobuf.MapKeyType, ValueType : SwiftProtobuf.Enum, ValueType.RawValue == Int {
        print("Unknown field \(fieldNumber) with enum map value: \(value)")
    }
    
    func visitMapField<KeyType, ValueType>(fieldType: SwiftProtobuf._ProtobufMessageMap<KeyType, ValueType>.Type, value: SwiftProtobuf._ProtobufMessageMap<KeyType, ValueType>.BaseType, fieldNumber: Int) throws where KeyType : SwiftProtobuf.MapKeyType, ValueType : Hashable, ValueType : SwiftProtobuf.Message {
        print("Unknown field \(fieldNumber) with message map value: \(value)")
    }
    
    func visitUnknown(bytes: Data) throws {
        print("Found unknown field with data: \(bytes)")
    }
    
    func visitSingularFixed32Field(value: UInt32, fieldNumber: Int) throws {
        print("Unknown field \(fieldNumber) with fixed32 value: \(value)")
    }
    
    func visitSingularFixed64Field(value: UInt64, fieldNumber: Int) throws {
        print("Unknown field \(fieldNumber) with fixed64 value: \(value)")
    }
    
    func visitSingularStringField(value: String, fieldNumber: Int) throws {
        print("Unknown field \(fieldNumber) with string value: \(value)")
    }
    
    func visitSingularInt32Field(value: Int32, fieldNumber: Int) throws {
        print("Unknown field \(fieldNumber) with int32 value: \(value)")
    }
    
    func visitSingularInt64Field(value: Int64, fieldNumber: Int) throws {
        print("Unknown field \(fieldNumber) with int64 value: \(value)")
    }
    
    func visitSingularUInt32Field(value: UInt32, fieldNumber: Int) throws {
        print("Unknown field \(fieldNumber) with uint32 value: \(value)")
    }
    
    func visitSingularUInt64Field(value: UInt64, fieldNumber: Int) throws {
        print("Unknown field \(fieldNumber) with uint64 value: \(value)")
    }
    
    func visitSingularBoolField(value: Bool, fieldNumber: Int) throws {
        print("Unknown field \(fieldNumber) with bool value: \(value)")
    }
    
    func visitSingularFloatField(value: Float, fieldNumber: Int) throws {
        print("Unknown field \(fieldNumber) with float value: \(value)")
    }
    
    func visitSingularDoubleField(value: Double, fieldNumber: Int) throws {
        print("Unknown field \(fieldNumber) with double value: \(value)")
    }
    
    func visitSingularBytesField(value: Data, fieldNumber: Int) throws {
        print("Unknown field \(fieldNumber) with bytes value: \(value)")
    }
    
    func visitSingularEnumField<E>(value: E, fieldNumber: Int) throws where E : SwiftProtobuf.Enum {
        print("Unknown field \(fieldNumber) with enum value: \(value)")
    }
    
    func visitSingularMessageField<M>(value: M, fieldNumber: Int) throws where M : SwiftProtobuf.Message {
        print("Unknown field \(fieldNumber) with message value: \(value)")
    }
    
    func visitRepeatedField<Element>(value: [Element], fieldNumber: Int) throws where Element : SwiftProtobuf.Message {
        print("Unknown field \(fieldNumber) with repeated message value: \(value)")
    }
    
    func visitRepeatedField<Element>(value: [Element], fieldNumber: Int) throws where Element : SwiftProtobuf.Enum {
        print("Unknown field \(fieldNumber) with repeated enum value: \(value)")
    }
    
    func visitRepeatedField<Element>(value: [Element], fieldNumber: Int) throws where Element == String {
        print("Unknown field \(fieldNumber) with repeated string value: \(value)")
    }
    
    func visitRepeatedField<Element>(value: [Element], fieldNumber: Int) throws where Element == Data {
        print("Unknown field \(fieldNumber) with repeated bytes value: \(value)")
    }
    
    func visitRepeatedField<Element>(value: [Element], fieldNumber: Int) throws where Element == UInt32 {
        print("Unknown field \(fieldNumber) with repeated uint32 value: \(value)")
    }
    
    func visitRepeatedField<Element>(value: [Element], fieldNumber: Int) throws where Element == UInt64 {
        print("Unknown field \(fieldNumber) with repeated uint64 value: \(value)")
    }
    
    func visitRepeatedField<Element>(value: [Element], fieldNumber: Int) throws where Element == Int32 {
        print("Unknown field \(fieldNumber) with repeated int32 value: \(value)")
    }
    
    func visitRepeatedField<Element>(value: [Element], fieldNumber: Int) throws where Element == Int64 {
        print("Unknown field \(fieldNumber) with repeated int64 value: \(value)")
    }
    
    func visitRepeatedField<Element>(value: [Element], fieldNumber: Int) throws where Element == Bool {
        print("Unknown field \(fieldNumber) with repeated bool value: \(value)")
    }
    
    func visitRepeatedField<Element>(value: [Element], fieldNumber: Int) throws where Element == Float {
        print("Unknown field \(fieldNumber) with repeated float value: \(value)")
    }
    
    func visitRepeatedField<Element>(value: [Element], fieldNumber: Int) throws where Element == Double {
        print("Unknown field \(fieldNumber) with repeated double value: \(value)")
    }
    
    func visitPackedField<Element>(value: [Element], fieldNumber: Int) throws where Element : SwiftProtobuf.Enum {
        print("Unknown field \(fieldNumber) with packed enum value: \(value)")
    }
    
    func visitPackedField<Element>(value: [Element], fieldNumber: Int) throws where Element == UInt32 {
        print("Unknown field \(fieldNumber) with packed uint32 value: \(value)")
    }
    
    func visitPackedField<Element>(value: [Element], fieldNumber: Int) throws where Element == UInt64 {
        print("Unknown field \(fieldNumber) with packed uint64 value: \(value)")
    }
    
    func visitPackedField<Element>(value: [Element], fieldNumber: Int) throws where Element == Int32 {
        print("Unknown field \(fieldNumber) with packed int32 value: \(value)")
    }
    
    func visitPackedField<Element>(value: [Element], fieldNumber: Int) throws where Element == Int64 {
        print("Unknown field \(fieldNumber) with packed int64 value: \(value)")
    }
    
    func visitPackedField<Element>(value: [Element], fieldNumber: Int) throws where Element == Bool {
        print("Unknown field \(fieldNumber) with packed bool value: \(value)")
    }
    
    func visitPackedField<Element>(value: [Element], fieldNumber: Int) throws where Element == Float {
        print("Unknown field \(fieldNumber) with packed float value: \(value)")
    }
    
    func visitPackedField<Element>(value: [Element], fieldNumber: Int) throws where Element == Double {
        print("Unknown field \(fieldNumber) with packed double value: \(value)")
    }
} 
