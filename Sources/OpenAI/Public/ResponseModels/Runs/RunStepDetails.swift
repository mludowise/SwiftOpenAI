//
//  RunStepDetails.swift
//
//
//  Created by James Rochabrun on 3/17/24.
//

import Foundation

public struct RunStepDetails: Codable, Hashable {
   
   /// `message_creation` or `tool_calls`
   public let type: String
   /// Details of the message creation by the run step.
   public let messageCreation: MessageCreation?
   /// An array of tool calls the run step was involved in. These can be associated with one of three types of tools: code_interpreter, file_search, or function.
   public let toolCalls: [ToolCall]?
   
   enum CodingKeys: String, CodingKey {
      case type
      case messageCreation = "message_creation"
      case toolCalls = "tool_calls"
   }
   
   public struct MessageCreation: Codable, Hashable {
      /// The ID of the message that was created by this run step.
      public let messageID: String
      
      enum CodingKeys: String, CodingKey {
         case messageID = "message_id"
      }
   }

   public struct ToolCall: Codable, Hashable {
      
      public let index: Int?
      public let id: String?
      public let type: String
      public let toolCall: RunStepToolCall
      
      enum CodingKeys: String, CodingKey {
         case index, id, type
         case codeInterpreter = "code_interpreter"
         case fileSearch = "file_search"
         case function
      }
      
      public init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: CodingKeys.self)
         index = try container.decodeIfPresent(Int.self, forKey: .index)
         id = try container.decodeIfPresent(String.self, forKey: .id)
         type = try container.decode(String.self, forKey: .type)
         
         // Based on the type, decode the corresponding tool call
         switch type {
         case "code_interpreter":
            let codeInterpreter = try container.decode(CodeInterpreterToolCall.self, forKey: .codeInterpreter)
            toolCall = .codeInterpreterToolCall(codeInterpreter)
         case "file_search":
            let retrieval = try container.decode(FileSearchToolCall.self, forKey: .fileSearch)
            toolCall = .fileSearchToolCall(retrieval)
         case "function":
            // Assuming you have a function key in your JSON that corresponds to this type
            let function = try container.decode(FunctionToolCall.self, forKey: .function)
            toolCall = .functionToolCall(function)
         default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unrecognized tool call type")
         }
      }
      
      public func encode(to encoder: Encoder) throws {
         var container = encoder.container(keyedBy: CodingKeys.self)
         try container.encode(id, forKey: .id)
         try container.encode(type, forKey: .type)
         
         // Based on the toolCall type, encode the corresponding object
         switch toolCall {
         case .codeInterpreterToolCall(let codeInterpreter):
            try container.encode(codeInterpreter, forKey: .codeInterpreter)
         case .fileSearchToolCall(let retrieval):
            // Encode retrieval if it's not nil
            try container.encode(retrieval, forKey: .fileSearch)
         case .functionToolCall(let function):
            // Encode function if it's not nil
            try container.encode(function, forKey: .function)
         }
      }
   }
}

// MARK: RunStepToolCall

/// Details of the tool call.
public enum RunStepToolCall: Codable, Hashable {
   
   case codeInterpreterToolCall(CodeInterpreterToolCall)
   case fileSearchToolCall(FileSearchToolCall)
   case functionToolCall(FunctionToolCall)
   
   private enum TypeEnum: String, Decodable {
      case codeInterpreter = "code_interpreter"
      case fileSearch = "file_search"
      case function
   }
   
   public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      
      // Decode the `type` property to determine which case to decode
      let type = try container.decode(TypeEnum.self)
      
      // Switch to the appropriate case based on the type
      switch type {
      case .codeInterpreter:
         let value = try CodeInterpreterToolCall(from: decoder)
         self = .codeInterpreterToolCall(value)
      case .fileSearch:
         let value = try FileSearchToolCall(from: decoder)
         self = .fileSearchToolCall(value)
      case .function:
         let value = try FunctionToolCall(from: decoder)
         self = .functionToolCall(value)
      }
   }
   
   public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      
      switch self {
      case .codeInterpreterToolCall(let value):
         try container.encode(value)
      case .fileSearchToolCall(let value):
         try container.encode(value)
      case .functionToolCall(let value):
         try container.encode(value)
      }
   }
}

// MARK: CodeInterpreterToolCall

public struct CodeInterpreterToolCall: Codable, Hashable {
   public var input: String?
   public var outputs: [CodeInterpreterOutput]?
   
   enum CodingKeys: String, CodingKey {
      case input, outputs
   }
   
   public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      input = try container.decodeIfPresent(String.self, forKey: .input)
      // This is needed as the input is retrieved as ""input": "# Calculate the square root of 500900\nmath.sqrt(500900)"
      input = input?.replacingOccurrences(of: "\\n", with: "\n")
      outputs = try container.decodeIfPresent([CodeInterpreterOutput].self, forKey: .outputs)
   }
   
   public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      // Revert the newline characters to their escaped form
      let encodedInput = input?.replacingOccurrences(of: "\n", with: "\\n")
      try container.encode(encodedInput, forKey: .input)
      try container.encode(outputs, forKey: .outputs)
   }
   
   public init(input: String?, outputs: [CodeInterpreterOutput]?) {
      self.input = input
      self.outputs = outputs
   }
}

public enum CodeInterpreterOutput: Codable, Hashable {
   
   case logs(CodeInterpreterLogOutput)
   case images(CodeInterpreterImageOutput)
   
   private enum CodingKeys: String, CodingKey {
      case type
   }
   
   private enum OutputType: String, Decodable {
      case logs, images
   }
   
   public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let outputType = try container.decode(OutputType.self, forKey: .type)
      
      switch outputType {
      case .logs:
         let logOutput = try CodeInterpreterLogOutput(from: decoder)
         self = .logs(logOutput)
      case .images:
         let imageOutput = try CodeInterpreterImageOutput(from: decoder)
         self = .images(imageOutput)
      }
   }
   
   public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      switch self {
      case .logs(let logOutput):
         try container.encode(OutputType.logs.rawValue, forKey: .type)
         try logOutput.encode(to: encoder)
      case .images(let imageOutput):
         try container.encode(OutputType.images.rawValue, forKey: .type)
         try imageOutput.encode(to: encoder)
      }
   }
}

/// Text output from the Code Interpreter tool call as part of a run step.
public struct CodeInterpreterLogOutput: Codable, Hashable {
   
   /// Always logs.
   public var type: String
   /// The text output from the Code Interpreter tool call.
   public var logs: String
   
   public init(type: String, logs: String) {
      self.type = type
      self.logs = logs
   }
}

public struct CodeInterpreterImageOutput: Codable, Hashable {
   
   public var type: String
   public var image: Image
   
   public struct Image: Codable, Hashable {
      /// The [file](https://platform.openai.com/docs/api-reference/files) ID of the image.
      public var fileID: String
      
      enum CodingKeys: String, CodingKey {
         case fileID = "file_id"
      }
      
      public init(fileID: String) {
         self.fileID = fileID
      }
   }
   
   public init(type: String, image: Image) {
      self.type = type
      self.image = image
   }
}

// MARK: FileSearchToolCall

public struct FileSearchToolCall: Codable, Hashable {
   
   /// For now, this is always going to be an empty object.
   public let fileSearch: [String: String]?
   
   enum CodingKeys: String, CodingKey {
      case fileSearch = "file_search"
   }
}

// MARK: FunctionToolCall

public struct FunctionToolCall: Codable, Hashable {
   
   /// The name of the function.
   public var name: String?
   /// The arguments passed to the function.
   public var arguments: String
   /// The output of the function. This will be null if the outputs have not been [submitted](https://platform.openai.com/docs/api-reference/runs/submitToolOutputs) yet.
   public var output: String?
   
   public init(name: String? = nil, arguments: String, output: String? = nil) {
      self.name = name
      self.arguments = arguments
      self.output = output
   }
}
