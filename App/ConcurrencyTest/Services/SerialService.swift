actor SerialService {
  
  let highCpuLoad: SerialHighCpuLoad = .init(threadName: "Serial service thread")
  
  func execute() async -> HighCpuLoaderResult {
    await self.highCpuLoad.execute()
  }
}
