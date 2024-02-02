public protocol Worker: Actor {
  associatedtype WorkItem: Sendable
  associatedtype WorkResult: Sendable
  
  func submit(work: WorkItem) async throws -> WorkResult
}

public struct WorkerPoolError: Error {}

public actor WorkerPool<W> where W: Worker {
  
  public typealias WorkItem = W.WorkItem
  public typealias WorkResult = W.WorkResult
  
  private var workers: [W] = []
  private var currentIndex: Int = 0
  
  public init(
    workers: [W]
  ) {
    self.workers = workers
  }
  
  public func submit(work item: WorkItem) async throws -> WorkResult {
    try await self.getNextWorker()
      .submit(work: item)
  }
  
  private func getNextWorker() throws -> W {
    guard !self.workers.isEmpty else {
      throw WorkerPoolError()
    }
    let nextWorker = self.workers[currentIndex]
    self.currentIndex = (self.currentIndex + 1) % self.workers.count
    return nextWorker
  }
}
