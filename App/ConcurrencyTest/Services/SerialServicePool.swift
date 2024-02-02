import ConcurrencyUtils

actor SerialServicePool {
  
  lazy var workerPool: WorkerPool<SerialServicePoolWorker> = {
    var workers: [SerialServicePoolWorker] = []
    for i in 1...Config.serialWorkerPoolCount {
      workers.append(SerialServicePoolWorker(index: i))
    }
    return WorkerPool(
      workers: workers
    )
  }()
  
  func execute() async throws -> HighCpuLoaderResult {
    try await self.workerPool.submit(work: ())
  }
}

actor SerialServicePoolWorker: Worker {
  
  let highCpuLoad: SerialHighCpuLoad
  
  func submit(work: Void) async -> HighCpuLoaderResult {
    await self.highCpuLoad.execute()
  }
  
  init(index: Int) {
    self.highCpuLoad = .init(threadName: "Worker thread \(index)")
  }
}

