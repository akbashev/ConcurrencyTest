import Foundation

/// Not sure if it's correct and optimal, but seems like working.
public class CustomThread: @unchecked Sendable {
  
  private lazy var operationQueue: OperationQueue = {
    let operationQueue = OperationQueue()
    operationQueue.name = name
    operationQueue.maxConcurrentOperationCount = 1
    return operationQueue
  }()
  
  private let name: String
  
  public init(name: String) {
    self.name = name
  }
  
  public func execute(task: @escaping () -> Void) {
    let block = BlockOperation {
      task()
    }
    block.name = name
    self.operationQueue.addOperation(block)
  }
}
