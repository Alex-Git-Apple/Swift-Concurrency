//: [Previous](@previous)

import Foundation

// The order of a task group can not be guaranteed.
func printMessage() async {
    let string = await withTaskGroup(of: String.self) { group -> String in
        group.addTask { "Hello" }
        group.addTask { "From" }
        group.addTask { "A" }
        group.addTask { "Task" }
        group.addTask { "Group" }

        var collected = [String]()

        for await value in group {
            collected.append(value)
        }

        return collected.joined(separator: " ")
    }

    print(string)
}

for i in 0..<10 {
    Task {
        await printMessage()
    }
}

//: [Next](@next)
