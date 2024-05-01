//: [Previous](@previous)

import Dispatch

class CustomJob {
    var completion: () -> ()
    init(completion: @escaping () -> Void) {
        self.completion = completion
    }
}

//class JobScheduler {
//    private var maxRunningCount: Int
//    private var runningJobCount = 0
//    private var pendingJobs = [CustomJob]()
//    private let serialQueue = DispatchQueue(label: "serial")
//    private let jobRunningQueue = DispatchQueue.global()
//    
//    init(maxRunningCount: Int) {
//        self.maxRunningCount = maxRunningCount
//    }
//    
//    func scheduleJob(job: @escaping () -> ()) {
//        serialQueue.async {
//            self.pendingJobs.append(CustomJob(completion: job))
//            self.runNextJob()
//        }
//    }
//    
//    func runNextJob() {
//        serialQueue.async { [weak self] in
//            guard let self else { return }
//            guard self.pendingJobs.count > 0 else { return }
//            if self.runningJobCount < self.maxRunningCount {
//                let nextJob = self.pendingJobs.removeFirst()
//                self.runningJobCount += 1
//                self.jobRunningQueue.async { [weak self] in
//                    guard let self else { return }
//                    nextJob.completion()
//                    self.serialQueue.async {
//                        self.runningJobCount -= 1
//                        self.runNextJob()
//                    }
//                }
//            }
//        }
//    }
//}


actor JobQueue {
    private var maxRunningCount: Int
    private var runningJobCount = 0
    private var pendingJobs = [CustomJob]()
    
    init(maxRunningCount: Int) {
        self.maxRunningCount = maxRunningCount
    }
    
    func addJob(job: CustomJob) {
        pendingJobs.append(job)
    }
    
    func nextJob() -> CustomJob? {
        if runningJobCount == maxRunningCount {
            print("The next job need to wait")
            return nil
        }
        if runningJobCount < maxRunningCount && pendingJobs.count > 0 {
            runningJobCount += 1
            return pendingJobs.removeFirst()
        } else {
            return nil
        }
    }
    
    
    func finishOneJob() {
        runningJobCount -= 1
    }
}

class JobScheduler {
    
    let jobQueue: JobQueue
    
    init(maxRunningCount: Int) {
        jobQueue = JobQueue(maxRunningCount: maxRunningCount)
    }
    
    func scheduleJob(job: @escaping () -> ()) {
        Task {
            await jobQueue.addJob(job: CustomJob(completion: job))
            run()
        }
    }
    
    private func run() {
        Task {
            if let job = await jobQueue.nextJob() {
                Task {
                    await self.executeJob(job: job)
                    await self.jobQueue.finishOneJob()
                    run()
                }
            }
        }
    }
    
    private func executeJob(job: CustomJob) async {
        return await withCheckedContinuation { continuation in
            job.completion()
            continuation.resume()
        }
    }
}


// MARK: - TEST


let processor = JobScheduler(maxRunningCount: 2)
let group = DispatchGroup()

for job in 1...5 {
    group.enter()
    print("Job \(job) scheduled")
    processor.scheduleJob {
        print("Job \(job) starts")
        sleep(2)
        print("Job \(job) complete")
        group.leave()
    }
}

group.wait()
print("Done")

//: [Next](@next)
