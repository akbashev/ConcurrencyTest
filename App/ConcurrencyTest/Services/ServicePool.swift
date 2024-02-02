import ConcurrencyUtils

actor ServicePool {
    
  lazy var workerPool: WorkerPool = .init(
    workers: .init(
      repeating: ServicePoolWorker(),
      count: Config.workerPoolCount
    )
  )
  
  func execute() async throws -> HighCpuLoaderResult {
    try await self.workerPool.submit(work: ())
  }
}

actor ServicePoolWorker: Worker {
  
  lazy var highCpuLoad: HighCpuLoad = .init()
  
  func submit(work: Void) async -> HighCpuLoaderResult {
    await self.highCpuLoad.execute()
  }
}
