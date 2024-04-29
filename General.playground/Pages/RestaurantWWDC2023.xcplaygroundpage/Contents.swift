//: [Previous](@previous)

import UIKit

struct Order {}

actor Cook {
    func handleShift<Orders>(orders: Orders) async throws
    where Orders: AsyncSequence,
          Orders.Element == Order {
              
          for try await order in orders {
              let soup = try await makeSoup(order)
              // ...
          }
      }
    
    func makeSoup(_ order: Order) async throws -> String {
        return "Soup fininsed"
    }
}

let staff = [Cook]()
let shiftDuration = 8 * 60 * 60

// Create a shared async stream orders. How to do this part?
var orders = AsyncStream([Order])

func run() async throws {
    // Unstructured concurrency for all the cooks
    let workTask = Task {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for cook in staff {
                group.addTask { try await cook.handleShift(orders: orders) }
            }

            try await group.waitForAll()
            print("all work done")
        }
    }

    // Unstructured concurrency for the end of the shift

    let cancelTask = Task {
        try await Task.sleep(for: .seconds(shiftDuration)) // keep the restaurant going until closing time
        print("ending shift")
        workTask.cancel()   // at the end of the shift, tell the cooks to stop working
    }

    // And because we're using unstructured concurrency, we need to manually handle
    // cancelation of `run`, itself.

    try await withTaskCancellationHandler {
        // perform all the work of `handleShift` for all the cooks
        _ = try await workTask.value
        // if all the work finished, then `cancelTask` is no longer needed and should be canceled, itself; obviously, if the timeout `Task` ended up getting invoked (i.e., work was still in progress at the end of the shift), then we will not reach this line because `workTask` will throw `CancellationError`
        cancelTask.cancel()
    } onCancel: {
        // if `run` was canceled, though (e.g., there was a fire and the restaurant needed to be closed prematurely; lol), then just clean up
        cancelTask.cancel()
        workTask.cancel()
    }
}

//: [Next](@next)
