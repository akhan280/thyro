import Foundation
import Network

// Define a type for the operations in the queue
typealias OfflineTask = () -> Void // Potentially make this async and throwable

class OfflineQueue {
    static let shared = OfflineQueue()

    private var queue: [OfflineTask] = []
    private let queueKey = "offlineQueueTasks"
    private let monitor = NWPathMonitor()
    private let dispatchQueue = DispatchQueue(label: "OfflineQueueMonitor")

    private init() {
        loadQueueFromDisk()
        startMonitoringNetwork()
    }

    private func saveQueueToDisk() {
        // Implement saving the queue to disk (e.g., using JSONEncoder for identifiable tasks)
        // This is tricky with closures directly. Consider saving descriptors of tasks.
        // For now, this is a placeholder.
        print("OfflineQueue: Attempting to save queue (not implemented yet).")
    }

    private func loadQueueFromDisk() {
        // Implement loading the queue from disk
        // For now, this is a placeholder.
        print("OfflineQueue: Attempting to load queue (not implemented yet).")
    }

    func addTask(_ task: @escaping OfflineTask) {
        queue.append(task)
        saveQueueToDisk()
        print("OfflineQueue: Task added. Current queue size: \(queue.count)")
        // Attempt to process immediately if online
        if monitor.currentPath.status == .satisfied {
            processQueue()
        }
    }

    private func startMonitoringNetwork() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            if path.status == .satisfied {
                print("OfflineQueue: Network connection is now .satisfied. Processing queue.")
                self.processQueue()
            } else {
                print("OfflineQueue: Network connection is now \(path.status).")
            }
        }
        monitor.start(queue: dispatchQueue)
    }

    func processQueue() {
        // Implement retry logic with exponential back-off
        // For now, just try to execute all tasks
        guard !queue.isEmpty else {
            print("OfflineQueue: Queue is empty. Nothing to process.")
            return
        }
        
        print("OfflineQueue: Processing \(queue.count) tasks.")
        let tasksToProcess = queue // Process a copy
        queue.removeAll() // Clear original queue, tasks will be re-added if they fail and need retry

        for (index, task) in tasksToProcess.enumerated() {
            // In a real implementation, you'd handle success/failure and requeue with backoff.
            // For now, just execute.
            print("OfflineQueue: Executing task \(index + 1) of \(tasksToProcess.count)")
            task()
            // If task needs to be async and report completion, this simple loop won't suffice.
        }
        // After processing, if any tasks failed and were re-added, save the queue.
        // saveQueueToDisk() // if tasks can be re-added upon failure.
        if queue.isEmpty {
             print("OfflineQueue: All tasks processed (or assumed successful).")
        }
    }
    
    // Deinit to stop monitoring
    deinit {
        monitor.cancel()
    }
} 