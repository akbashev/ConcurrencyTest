/// Just took it here:
/// https://github.com/apple/swift/blob/main/test/Concurrency/Runtime/custom_executors_protocol.swift

public protocol WithSpecifiedExecutor: Actor {
  nonisolated var executor: any SpecifiedExecutor { get }
}

public protocol SpecifiedExecutor: SerialExecutor {}

public extension WithSpecifiedExecutor {
  /// Establishes the WithSpecifiedExecutorExecutor as the serial
  /// executor that will coordinate execution for the actor.
  nonisolated var unownedExecutor: UnownedSerialExecutor {
    executor.asUnownedSerialExecutor()
  }
}

public final class NaiveQueueExecutor: SpecifiedExecutor, CustomStringConvertible {
  
  let name: String
  let thread: CustomThread

  public init(name: String) {
    self.name = name
    self.thread = CustomThread(name: name)
  }

  
  public func enqueue(_ job: consuming ExecutorJob) {
    print("\(self): enqueue")
    let unowned = UnownedJob(job)
    thread.execute {
      unowned.runSynchronously(on: self.asUnownedSerialExecutor())
    }
    print("\(self): after run")
  }
  
  public var description: Swift.String {
    "NaiveQueueExecutor(\(name))"
  }
}
