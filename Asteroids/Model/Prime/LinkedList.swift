class ListNode<T> {
    var data: T
    var next: ListNode<T>?

    init(data: T) {
        self.data = data
        self.next = nil
    }
}

class LinkedList<T> {
    private(set) var head: ListNode<T>?
    private(set) var tail: ListNode<T>?
    private(set) var length: Int = 0

    // Add a new node to the end of the list
    func add(_ data: T) {
        let newNode = ListNode(data: data)
        if head == nil {
            head = newNode
            tail = newNode
        } else if let tailNode = tail {
            tailNode.next = newNode
            tail = newNode
        }
        length += 1
    }

    // Remove a node with the specified data
    func remove(_ data: T) where T: Equatable {
        var current = head
        var previous: ListNode<T>?

        while current != nil {
            if current!.data == data {
                if let prevNode = previous {
                    prevNode.next = current!.next
                    if current === tail {
                        tail = prevNode
                    }
                } else {
                    head = current!.next
                    if current === tail {
                        tail = nil
                    }
                }
                length -= 1
                return
            }
            previous = current
            current = current?.next
        }
    }

    // Clear the list
    func clear() {
        head = nil
        tail = nil
        length = 0
    }

    // Print the list
    func printList() {
        var current = head
        while current != nil {
            print("\(current!.data) -> ", terminator: "")
            current = current?.next
        }
        print("nil")
    }

    // Iterate over the list
    func forEach(_ callback: (T) -> Void) {
        var current = head
        while current != nil {
            callback(current!.data)
            current = current?.next
        }
    }

    // Convert the list to an array
    func toArray() -> [T] {
        var array: [T] = []
        var current = head
        while current != nil {
            array.append(current!.data)
            current = current?.next
        }
        return array
    }

    // Enqueue (same as add)
    func enqueue(_ data: T) {
        add(data)
    }

    // Dequeue (remove from head)
    func dequeue() -> T? {
        guard let headNode = head else { return nil }
        let data = headNode.data
        head = headNode.next
        length -= 1
        if head == nil {
            tail = nil
        }
        return data
    }
}

extension LinkedList where T == any Movable {
    func remove(_ element: any Movable) {
        var current = head
        var previous: ListNode<T>?

        while current != nil {
            if current!.data === element {
                if let prevNode = previous {
                    prevNode.next = current!.next
                    if current === tail {
                        tail = prevNode
                    }
                } else {
                    head = current!.next
                    if current === tail {
                        tail = nil
                    }
                }
                length -= 1
                return
            }
            previous = current
            current = current?.next
        }
    }
}
