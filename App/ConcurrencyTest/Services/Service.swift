actor Service {
  
  let highCpuLoad: HighCpuLoad = .init()
  
  func execute() async -> HighCpuLoaderResult {
    await self.highCpuLoad.execute()
  }
}
