//: [Previous](@previous)

import Foundation

func fast() async {
    try? await Task.sleep(for: .seconds(1))
    if Task.isCancelled {
        print("fast is cancelled")
        return
    }
    print("execute fast")
}

func slow() async {
    try? await Task.sleep(for: .seconds(3))
    if Task.isCancelled {
        print("slow is cancelled")
        return
    }
    print("execute slow")
}

func go() async {
    async let fast = fast()
    async let slow = slow()
}

func go2() async {
    await withDiscardingTaskGroup { group in
        group.addTask {
            await fast()
        }
        group.addTask {
            await slow()
        }
    }
}

Task.detached {
    print("Async let cancels tasks")
    await go()
    print("Finished")
}

Task.detached {
    print("Task group executes tasks")
    await go2()
    print("Finshed2")
}

//: [Next](@next)
