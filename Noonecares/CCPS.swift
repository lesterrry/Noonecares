//
//  CCPSFoundation.swift
//  Noonecares
//
//  Created by Lesterrry on 18.02.2022.
//

import Foundation
import Cocoa
import CoreGraphics

/// Main CCPS handling class
public class CCPS {
    
    /// Sequence object itself
    public class Sequence {
        
        /// Repeat value used in Sets
        public enum SetRepeat: Equatable {
            case Num(Int)
            case TillTheEnd
            case Unknown
            
            func asString() throws -> String {
                switch self {
                case .Num(let x):
                    return String(x)  // TODO: No way this is the only solution
                case .TillTheEnd:
                    return "i"
                case .Unknown:
                    throw OperationError.OperationOnUnknownValue
                }
            }
        }
        /// Default color values
        public enum DefaultColorConstant: Equatable, CaseIterable {
            case White
            case None
            case Alpha
            case Red
            case Green
            case Blue
            case Cyan
            case Magenta
            case Yellow
            
            func asCharacter() -> Character {
                switch self {
                case .White:
                    return "W"
                case .None:
                    return "N"
                case .Alpha:
                    return "A"
                case .Red:
                    return "R"
                case .Green:
                    return "G"
                case .Blue:
                    return "B"
                case .Cyan:
                    return "C"
                case .Magenta:
                    return "M"
                case .Yellow:
                    return "Y"
                }
            }
        }
        /// Custom color values, individual for each of `r`, `g` and `b` values
        public enum CustomColorConstant: Equatable {
            case Full
            case Empty
            case Num(Int)
            case Unknown
            
            func asString() throws -> String {
                switch self {
                case .Full:
                    return "f"
                case .Empty:
                    return "e"
                case .Num(let x):
                    return String(x)
                case .Unknown:
                    throw OperationError.OperationOnUnknownValue
                }
            }
        }
        public enum OperationError: Error {
            case TypeSpecificOperationOnWrongType
            case OperationOnFullInstruction
            case OperationOnUnknownValue
        }
        /// Main instruction object
        public indirect enum Instruction: Equatable {
            case DefaultColor(DefaultColorConstant)
            case CustomColor(CustomColorConstant, CustomColorConstant, CustomColorConstant)
            case Set(Instruction, SetRepeat)
            
            /// Add Custom Color's default value (`f` or `e`) to the first empty position
            /// - Parameter color: Custom Color to add
            /// - Throws: If function is called on something but CustomColor
            mutating func appendCustomColorDefaultValue(_ color: CustomColorConstant) throws {
                if case let Self.CustomColor(r, g, b) = self {
                    if r == .Unknown {
                        self = .CustomColor(color, g, b)
                    } else if g == .Unknown {
                        self = .CustomColor(r, color, b)
                    } else if b == .Unknown{
                        self = .CustomColor(r, g, color)
                    }
                } else { throw OperationError.TypeSpecificOperationOnWrongType }
            }
            /// Appends (concatenates) Custom Color value integer to the other Custom Color integer in first suitable position
            /// - Parameters:
            ///   - value: Integer to append
            ///   - passToNext: Whether to append to the first empty position instead of the first numeric one
            /// - Throws: If function is called on something but CustomColor
            mutating func appendCustomColorIntegerValue(_ value: Int, passToNext: Bool = false) throws {
                var passToNext = passToNext
                if case let Self.CustomColor(r, g, b) = self {
                    var colors = [r, g, b]
                    for i in 0...2 {
                        if case .Num(let x) = colors[i], (colors[safeIndex: i + 1] == nil || colors[safeIndex: i + 1] == .Unknown) {
                            if passToNext { passToNext = false; continue }
                            colors[i] = .Num(x.concat(value))
                            break
                        } else if colors[i] == .Unknown {
                            colors[i] = .Num(value)
                            break
                        }
                    }
                    self = .CustomColor(colors[0], colors[1], colors[2])
                } else { throw OperationError.TypeSpecificOperationOnWrongType }
            }
            /// Appends (concatenates) integer to the current Set's Repeat integer value
            /// - Parameter value: Integer to append
            /// - Throws: If function is called on something but Set
            mutating func appendSetRepeatsIntegerValue(_ value: Int) throws {
                if case let Self.Set(ins, rep) = self {
                    switch rep {
                    case .Unknown:
                        self = .Set(ins, .Num(value))
                    case .TillTheEnd:
                        throw OperationError.OperationOnFullInstruction
                    case .Num(let x):
                        self = .Set(ins, .Num(x.concat(value)))
                    }
                } else { throw OperationError.TypeSpecificOperationOnWrongType }
            }
            /// Sets Set's Repeat value to `TillTheEnd`
            /// - Throws: If function is called on something but Set
            mutating func setInfiniteSetRepeatsValue() throws {
                if case let Self.Set(ins, _) = self {
                    self = .Set(ins, .TillTheEnd)
                } else { throw OperationError.TypeSpecificOperationOnWrongType }
            }
            
            var isFull: Bool {
                switch self {
                case .DefaultColor:
                    return true
                case let .CustomColor(r, g, b):
                    return r != .Unknown && g != .Unknown && b != .Unknown
                case let .Set(_, rep):
                    return rep != .Unknown
                }
            }
            var stringRepresentationStartsWithANumber: Bool {
                switch self {
                case .DefaultColor:
                    return false
                case .CustomColor(let r, _, _):
                    if case .Num(_) = r { return true } else { return false }
                case .Set(let ins, _):
                    if case .CustomColor(let r, _, _) = ins, case .Num(_) = r { return true } else { return false }
                }
            }
            var stringRepresentationEndsWithANumber: Bool {
                switch self {
                case .DefaultColor:
                    return false
                case .CustomColor(_, _, let b):
                    if case .Num(_) = b { return true } else { return false }
                case .Set(_, let rep):
                    if case .Num(_) = rep { return true } else { return false }
                }
            }
            var countInPixels: Int? {
                switch self {
                case .CustomColor, .DefaultColor:
                    return 1
                case .Set(_, let rep):
                    if case .Num(let x) = rep {
                        return x
                    } else {
                        return nil
                    }
                }
            }
        }
        
        var instructions: [Instruction]
        var initialString: String? = nil
        
        /// Initialize a Sequence from string
        /// - Parameter string: String to initialize from
        /// - Parameter wipeAfter: Add clearing set to the end of the Sequence
        /// - Parameter disableOptimize: Do not optimize the Sequence
        /// - Throws: If CCPS is corrupt
        init(from string: String, wipeAfter: Bool = true, disableOptimize: Bool = false) throws {
            var a = try string.parse()
            if !disableOptimize { try a.optimize() }
            initialString = string
            if wipeAfter { a.append(.Set(.DefaultColor(.Alpha), .TillTheEnd)) }
            instructions = a
        }
        /// Initialize a Sequence manually
        /// - Parameter array: Set of Instructions
        /// - Parameter wipeAfter: Add clearing set to the end of the Sequence
        /// - Parameter disableOptimize: Do not optimize the Sequence
        /// - Throws: If CCPS is corrupt
        init(from array: [Instruction], wipeAfter: Bool = true, disableOptimize: Bool = false) throws {
            if !disableOptimize {
                var a = array
                try a.optimize()
                instructions = a
            } else {
                instructions = array
            }
            if wipeAfter { instructions.append(.Set(.DefaultColor(.Alpha), .TillTheEnd)) }
        }
        /// Initialize a Sequence from image
        /// - Parameters:
        ///   - image: Image to use
        /// - Parameter wipeAfter: Add clearing set to the end of the Sequence
        /// - Parameter disableOptimize: Do not optimize the Sequence
        /// - Throws: If CCPS is corrupt
        init(from image: NSImage, wipeAfter: Bool = true, disableOptimize: Bool = false) throws {
            var a = try Foundation.construct(image)
            //if !disableOptimize { try a.optimize() }
            //if wipeAfter { a.append(.Set(.DefaultColor(.Alpha), .TillTheEnd)) }
            instructions = a
        }
        /// Return string representation of the Sequence
        /// - Throws: If CCPS is corrupt
        /// - Returns: Sequence string
        public func asString() throws -> String {
            return try CCPS.Foundation.render(self.instructions)
        }
        /// Return string representation of the Sequence
        /// - Throws: If CCPS is corrupt
        /// - Returns: Sequence string
        public func asString(blockSize: Int = 16) throws -> [String] {
            return try CCPS.Foundation.render(self.instructions, blockSize: blockSize)
        }
        /// Optimize the Sequence by making it shorter if possible
        /// - Throws: If CCPS is corrupt
        /// - Returns: Optimized set of Instructions
        public func optimize() throws {
            let optimized = try CCPS.Foundation.optimize(self.instructions)
            self.instructions = optimized
        }
        
    }
    
    /// Internal CCPS operations
    fileprivate class Foundation {
        
        enum ParsingError: Error {
            case ReadyToPassOnNil
            case UnexpectedMarker(Character)
            case OperationOnNilInstruction
        }
        
        enum OptimizationError: Error {
            case UnknownInSequence
        }
        
        enum ConstructionError: Error {
            case MatrixSizeNotSet
            case ImageSizeNotSupported
        }
        
        static let defaultColorConstantKeys: [Character] = ["W", "N", "A", "R", "G", "B", "C", "M", "Y"]  // TODO: I'd rather fetch these from the enum but i don't know how yet
        
        /// Create string out of a single instruction
        /// - Parameter instruction: Instruction to render
        /// - Throws: If CCPS is corrupt
        /// - Returns: Instruction string representation
        private static func renderInstruction(_ instruction: CCPS.Sequence.Instruction) throws -> String {
            switch instruction {
            case let .CustomColor(r, g, b):
                if case .Num(_) = r, case .Num(_) = g, case .Num(_) = b {
                    return "\(try r.asString()),\(try g.asString()),\(try b.asString())"
                } else if case .Num(_) = r, case .Num(_) = g {
                    return "\(try r.asString()),\(try g.asString())\(try b.asString())"
                } else if case .Num(_) = g, case .Num(_) = b {
                    return "\(try r.asString())\(try g.asString()),\(try b.asString())"
                } else {
                    return "\(try r.asString())\(try g.asString())\(try b.asString())"
                }
            case let .DefaultColor(color):
                return String(color.asCharacter())
            case let .Set(ins, rep):
                let renderedInstruction = try renderInstruction(ins)
                return "\(renderedInstruction)>\(try rep.asString())"
            }
        }
        
        /// Parse CCPS string into a set of Instructions
        /// - Parameter from: String to parse
        /// - Throws: If CCPS is corrupt
        /// - Returns: Set of Instructions
        static func parse(_ from: String) throws -> [Sequence.Instruction] {
            func passInstruction() throws {
                guard (currentInstruction != nil) else { throw ParsingError.ReadyToPassOnNil }
                if passToLast {
                    r[r.count - 1] = currentInstruction!
                    passToLast = false
                } else {
                    r.append(currentInstruction!)
                }
                currentInstruction = nil
            }
            var r: [Sequence.Instruction] = []
            var currentInstruction: Sequence.Instruction? = nil
            var readyToSeparateCustomColorValues = false
            var passToLast = false
            var inSet = false
            for i in from {
                switch i {
                case let s where defaultColorConstantKeys.contains(s):
                    readyToSeparateCustomColorValues = false
                    inSet = false
                    switch currentInstruction {
                    case .CustomColor, .Set:
                        try passInstruction()
                        currentInstruction = Sequence.Instruction.DefaultColor(
                            CCPS.Sequence.DefaultColorConstant.allCases[defaultColorConstantKeys.firstIndex(of: i)!]
                        )
                        try passInstruction()
                    case nil:
                        currentInstruction = Sequence.Instruction.DefaultColor(
                            CCPS.Sequence.DefaultColorConstant.allCases[defaultColorConstantKeys.firstIndex(of: i)!]
                        )
                        try passInstruction()
                    default:
                        throw ParsingError.UnexpectedMarker(s)
                    }
                case let s where s == "f" || s == "e":
                    readyToSeparateCustomColorValues = false
                    inSet = false
                    switch currentInstruction {
                    case .CustomColor:
                        try currentInstruction!.appendCustomColorDefaultValue(s == "f" ? .Full : .Empty)
                    case .Set:
                        try passInstruction()
                        currentInstruction = Sequence.Instruction.CustomColor(s == "f" ? .Full : .Empty, .Unknown, .Unknown)
                    case nil:
                        currentInstruction = Sequence.Instruction.CustomColor(s == "f" ? .Full : .Empty, .Unknown, .Unknown)
                    default:
                        throw ParsingError.UnexpectedMarker(s)
                    }
                case let s where s.wholeNumberValue != nil:
                    if inSet {
                        try currentInstruction!.appendSetRepeatsIntegerValue(s.wholeNumberValue!)
                    } else {
                        switch currentInstruction {
                        case .CustomColor:
                            try currentInstruction!.appendCustomColorIntegerValue(s.wholeNumberValue!, passToNext: readyToSeparateCustomColorValues)
                            readyToSeparateCustomColorValues = false
                        case nil:
                            currentInstruction = Sequence.Instruction.CustomColor(.Num(s.wholeNumberValue!), .Unknown, .Unknown)
                        default:
                            throw ParsingError.UnexpectedMarker(s)
                        }
                    }
                case ",":
                    guard let a = currentInstruction else { throw ParsingError.OperationOnNilInstruction }
                    if a.isFull {
                        try passInstruction()
                        inSet = false
                    } else {
                        readyToSeparateCustomColorValues = true
                    }
                case ">":
                    readyToSeparateCustomColorValues = false
                    inSet = true
                    if let a = currentInstruction {
                        currentInstruction = .Set(a, .Unknown)
                    } else {
                        currentInstruction = .Set(r[r.count - 1], .Unknown)
                        passToLast = true
                    }
                case "i":
                    guard currentInstruction != nil else { throw ParsingError.OperationOnNilInstruction }
                    if inSet {
                        try currentInstruction!.setInfiniteSetRepeatsValue()
                        inSet = false
                        try passInstruction()
                    } else { throw ParsingError.UnexpectedMarker("i")}
                case let unknown:
                    throw ParsingError.UnexpectedMarker(unknown)
                }
            }
            try? passInstruction()
            return r
        }
        /// Create string out of a set of Instructions
        /// - Parameter from: Set of Instructions to create string from
        /// - Throws: If CCPS is corrupt
        /// - Returns: Sequence string
        static func render(_ from: [Sequence.Instruction]) throws -> String {
            var ret = ""
            for i in 0...from.count {
                ret.append(try renderInstruction(from[i]))
                if from[i].stringRepresentationEndsWithANumber,
                   let x = from[safeIndex: i + 1],
                   x.stringRepresentationStartsWithANumber
                { ret.append(",") }
            }
            return ret
        }
        /// Create set of strings out of a set of Instructions, divided into small blocks
        /// - Parameter from: Set of Instructions to create string from
        /// - Parameter blockSize: Number of instructions to put in a single block
        /// - Throws: If CCPS is corrupt
        /// - Returns: Set of sequence strings
        static func render(_ from: [Sequence.Instruction], blockSize: Int) throws -> [String] {
            var ret = [""]
            var index = 0
            var blockPixelSize = 0
            for i in 0...from.count - 1 {
                if i != 0 && i % blockSize == 0 {
                    index += 1
                    ret.append("A>\(blockPixelSize)")
                }
                if let x = from[i].countInPixels { blockPixelSize += x }
                ret[index].append(try renderInstruction(from[i]))
                if (i + 1) % blockSize != 0,
                   from[i].stringRepresentationEndsWithANumber,
                   let x = from[safeIndex: i + 1],
                   x.stringRepresentationStartsWithANumber
                { ret[index].append(",") }
            }
            return ret
        }
        /// Optimize the set of Instructions by making it shorter if possible
        /// - Parameter what: Set of Instructions to optimize
        /// - Throws: If CCPS is corrupt
        /// - Returns: Optimized set of Instructions
        static func optimize(_ what: [Sequence.Instruction]) throws -> [Sequence.Instruction] {
            // TODO: Separate sets if repeated less then 4 times
            // TODO: Pack repeating instructions into sets
            // TODO: Remove everything after infinite set
            @discardableResult
            func optimizeInstruction(_ instruction: inout Sequence.Instruction) throws -> Bool {
                switch instruction {
                case .DefaultColor:
                    return true
                case var .CustomColor(r, g, b):
                    switch (r, g, b) {
                    case let (x, y, z) where x == .Unknown || y == .Unknown || z == .Unknown:
                        throw OptimizationError.UnknownInSequence
                    case (.Num(255), .Num(255), .Num(255)):
                        instruction = .DefaultColor(.White); return true
                    case (.Num(0), .Num(0), .Num(0)):
                        instruction = .DefaultColor(.None); return true
                    case (.Num(255), .Num(0), .Num(0)):
                        instruction = .DefaultColor(.Red); return true
                    case (.Num(0), .Num(255), .Num(0)):
                        instruction = .DefaultColor(.Green); return true
                    case (.Num(0), .Num(0), .Num(255)):
                        instruction = .DefaultColor(.Blue); return true
                    case (.Num(0), .Num(255), .Num(255)):
                        instruction = .DefaultColor(.Cyan); return true
                    case (.Num(255), .Num(0), .Num(255)):
                        instruction = .DefaultColor(.Magenta); return true
                    case (.Num(255), .Num(255), .Num(0)):
                        instruction = .DefaultColor(.Yellow); return true
                    case let unknown:
                        if unknown.0 == .Num(255) {
                            r = .Full
                        }
                        if unknown.1 == .Num(255) {
                            g = .Full
                        }
                        if unknown.2 == .Num(255) {
                            b = .Full
                        }
                        if unknown.0 == .Num(0) {
                            r = .Empty
                        }
                        if unknown.1 == .Num(0) {
                            g = .Empty
                        }
                        if unknown.2 == .Num(0) {
                            b = .Empty
                        }
                        instruction = .CustomColor(r, g, b)
                    }
                case let .Set(_, rep):
                    if case CCPS.Sequence.SetRepeat.Unknown = rep {
                        throw OptimizationError.UnknownInSequence
                    }
                }
                return false
            }
            var what = what
            var lastInstruction: Sequence.Instruction? = nil
            var instructionRepeats = 0
            var needToPackInSet = false
            for i in 0...what.count - 1 {
                try optimizeInstruction(&what[i])
                if lastInstruction == what[i] {
                    instructionRepeats += 1
                } else {
                    if needToPackInSet {
                        what.removeSubrange(i - instructionRepeats...what.count)
                        what.append(Sequence.Instruction.Set(lastInstruction!, .Num(instructionRepeats)))
                    }
                    needToPackInSet = false
                    instructionRepeats = 0
                }
                if instructionRepeats >= 4 { needToPackInSet = true }
                lastInstruction = what[i]
            }
            return what
        }
        static func construct(_ from: NSImage) throws -> [Sequence.Instruction] {
            let imageData = from.imageData()
            dump(imageData)
            return []
            //            guard let a = DeviceProperties.matrixSize else { throw ConstructionError.MatrixSizeNotSet }
            //            guard imageData.1 != a.x || imageData.2 != a.y else { throw ConstructionError.ImageSizeNotSupported }
            //            var ret: [Sequence.Instruction] = []
            //            for i in imageData.0 {
            //                ret.append(.CustomColor(.Num(i.), <#T##CCPS.Sequence.CustomColorConstant#>, <#T##CCPS.Sequence.CustomColorConstant#>))
            //            }
            //            return ret
        }
        
    }
    
}

fileprivate extension String {
    func parse(by: Int = 32) throws -> [CCPS.Sequence.Instruction] { return try CCPS.Foundation.parse(self) }
}

fileprivate extension Int {
    func concat(_ value: Int) -> Int { return Int(String(self) + String(value))! }
}

fileprivate extension Array {
    subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else { return nil }
        return self[index]
    }
}

fileprivate extension Array where Element == CCPS.Sequence.Instruction {
    mutating func optimize() throws {
        let optimized = try CCPS.Foundation.optimize(self)
        self = optimized
    }
    func asString() throws -> String {
        return try CCPS.Foundation.render(self)
    }
}

// TODO: Native Swift image parsing
//fileprivate extension NSImage {
//    func imageData() -> (pixelValues: [[UInt8]], x: Int, y: Int)?
//    {
//        let width = Int(self.size.width)
//        let height = Int(self.size.height)
//        let colorspace = CGColorSpaceCreateDeviceRGB()
//        let bytesPerRow = (4 * width);
//        let bitsPerComponent = 8
//        let dataSize = self.size.width * self.size.height * 4
//        var pixels = [UInt8](repeating: 0, count: Int(dataSize))
//        let context = CGContext(data: &pixels,
//                                width: Int(self.size.width),
//                                height: Int(self.size.height),
//                                bitsPerComponent: bitsPerComponent,
//                                bytesPerRow: bytesPerRow,
//                                space: colorspace,
//                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
//        let image = self.cgImage(forProposedRect: nil, context: NSGraphicsContext(cgContext: context!, flipped: false), hints: nil)!
//        context?.draw(image, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
//
//        dump(pixels)
//        for x in 0...width {
//            for y in 0...height {
//                let offset = 4*((Int(width) * Int(y)) + Int(x))
//                print("A \(pixels[offset])")
//                print("R \(pixels[offset + 1])")
//                print("G \(pixels[offset + 2])")
//                print("B \(pixels[offset + 3])")
//            }
//        }
//        return nil
//    }
//}
