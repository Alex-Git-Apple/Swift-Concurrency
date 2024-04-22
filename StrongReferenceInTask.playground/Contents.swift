import UIKit

class ExampleClass {
    
    func startLongJobWithHandler() {
        DispatchQueue.global().async { [weak self] in
            // Simulate some asynchronous task
            Thread.sleep(forTimeInterval: 2)
            self?.doSomething()
        }
    }
    
    func startLongJobWithTask() {
        Task { [weak self] in
            // Simulate some asynchronous task
            print("Wait for 2s.")
            try? await Task.sleep(for: .seconds(2)) // 2 seconds
            print("After 2s.")
            self?.doSomething()
        }
    }
    
    func doSomething() {
        print("Doing something...")
    }
    
    deinit {
        print("ExampleClass deinitialized")
    }
}


var example1: ExampleClass? = ExampleClass()
example1?.startLongJobWithTask()
example1 = nil

