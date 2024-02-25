//
//  RedBlackTree.swift
//  StrTree
//
//  Created by Nail Sharipov on 24.02.2024.
//

struct RedBlackTree<T: Comparable> {
    
    private var store: NodeStore<T>
    private let emptyIndex: UInt32
    private (set) var root: UInt32
    
    subscript(index: UInt32) -> TreeNode<T> {
        get {
            store.buffer[Int(index)]
        }
        set {
            store.buffer[Int(index)] = newValue
        }
    }
    
    private mutating func save(_ n: TreeNode<T>) {
        store.buffer[Int(n.index)] = n
    }
    
    private func isBlack(_ index: UInt32) -> Bool {
        index == .empty || index != .empty && store.buffer[Int(index)].color == .black
    }
    
    private mutating func createNilNode(parent: UInt32) -> UInt32 {
        var node = store.buffer[Int(self.emptyIndex)]
        node.parent = parent
        node.left = .empty
        node.right = .empty
        node.color = .black
        
        return node.index
    }
    
    init(empty: T, capacity: Int = 32) {
        self.store = NodeStore(empty: empty, capacity: capacity)
        self.emptyIndex = store.getFreeIndex() // must be 0
        self.root = .empty
    }

    private mutating func rotateRight(_ index: UInt32) {
        var n = self[index]
        let p = n.parent
        let l = self[n.left]
        
        if l.right != .empty {
            n.left = l.right
            self[l.right].parent = index
        } else {
            n.left = .empty
        }
        
        self[l.index].right = index
        n.parent = l.index
        
        self.save(n)
        
        self.replaceParentsChild(p, oldChild: n.index, newChild: l.index)
    }
    
    private mutating func rotateLeft(_ index: UInt32) {
        var n = self[index]
        let p = n.parent
        let r = self[n.right]
        
        if r.left != .empty {
            n.right = r.left
            self[r.left].parent = index
        } else {
            n.right = .empty
        }
        
        self[r.index].left = index
        n.parent = r.index
        
        self.save(n)
        
        self.replaceParentsChild(p, oldChild: n.index, newChild: r.index)
    }
    
    private mutating func replaceParentsChild(_ parent: UInt32, oldChild: UInt32, newChild: UInt32) {
        guard parent != .empty else {
            root = newChild
            self[newChild].parent = .empty
            return
        }
        
        var p = self[parent]
        assert(p.left == oldChild || p.right == oldChild, "Node is not a child of its parent")
        
        if p.left == oldChild {
            p.left = newChild
        } else {
            p.right = newChild
        }
        
        self[parent] = p
        self[newChild].parent = parent
    }
    
    private mutating func replaceParentsChild(_ parent: UInt32, oldChild: UInt32) {
        var p = self[parent]
        assert(p.left == oldChild || p.right == oldChild, "Node is not a child of its parent")
        
        if p.left == oldChild {
            p.left = .empty
        } else {
            p.right = .empty
        }
        
        self[parent] = p
    }
    
    mutating func insert(value: T) {
        var newNode = self.store.getFree()
        newNode.value = value
        newNode.color = .red
        
        guard self.root != .empty else {
            self.save(newNode)
            self.root = newNode.index
            return
        }
        
        var index = root
        var pIndex = root
        repeat {
            let node = self[index]
            pIndex = index
            assert(node.value != value)
            
            if value < node.value {
                index = node.left
            } else {
                index = node.right
            }
        } while index != .empty

        var parent = self[pIndex]
        
        if value < parent.value {
            parent.left = newNode.index
        } else {
            parent.right = newNode.index
        }
        newNode.parent = pIndex
        
        self.save(newNode)
        self.save(parent)

        if parent.color == .red {
            fixRedBlackPropertiesAfterInsert(nIndex: newNode.index, pIndex: pIndex)
        }
    }
    
    mutating private func fixRedBlackPropertiesAfterInsert(nIndex: UInt32, pIndex: UInt32) {
        // parent is red!
        var pIndex = pIndex
        let parent = self[pIndex]
        // Case 2:
        // Not having a grandparent means that parent is the root. If we enforce black roots
        // (rule 2), grandparent will never be null, and the following if-then block can be
        // removed.
        let gIndex = parent.parent
        guard gIndex != .empty else {
            // As this method is only called on red nodes (either on newly inserted ones - or -
            // recursively on red grandparents), all we have to do is to recolor the root black.
            self[pIndex].color = .black
            return
        }

        // Case 3: Uncle is red -> recolor parent, grandparent and uncle
        let uIndex = self.getUncle(pIndex: pIndex)
        let grandparent = self[gIndex]
        if uIndex != .empty && self[uIndex].color == .red {
            self[pIndex].color = .black
            self[gIndex].color = .red
            self[uIndex].color = .black

            // Call recursively for grandparent, which is now red.
            // It might be root or have a red parent, in which case we need to fix more...
            let ggIndex = grandparent.parent
            if ggIndex != .empty, self[ggIndex].color == .red {
                self.fixRedBlackPropertiesAfterInsert(nIndex: gIndex, pIndex: ggIndex)
            }
        } else if pIndex == grandparent.left {
            // Parent is left child of grandparent
            // Case 4a: Uncle is black and node is left->right "inner child" of its grandparent
            if nIndex == parent.right {
                rotateLeft(pIndex)

                // Let "parent" point to the new root node of the rotated sub-tree.
                // It will be recolored in the next step, which we're going to fall-through to.
                pIndex = nIndex
            }

            // Case 5a: Uncle is black and node is left->left "outer child" of its grandparent
            rotateRight(gIndex)

            // Recolor original parent and grandparent
            self[pIndex].color = .black
            self[gIndex].color = .red
        } else {
            // Parent is right child of grandparent
            // Case 4b: Uncle is black and node is right->left "inner child" of its grandparent
            if nIndex == parent.left {
                rotateRight(pIndex)

                // Let "parent" point to the new root node of the rotated sub-tree.
                // It will be recolored in the next step, which we're going to fall-through to.
                pIndex = nIndex
            }

            // Case 5b: Uncle is black and node is right->right "outer child" of its grandparent
            rotateLeft(gIndex)

            // Recolor original parent and grandparent
            self[pIndex].color = .black
            self[gIndex].color = .red
        }
    }
    
    private func getUncle(pIndex: UInt32) -> UInt32 {
        let parent = self[pIndex]
        guard parent.parent != .empty else {
            return .empty
        }
        
        let grandparent = self[parent.parent]
        
        assert(grandparent.left == pIndex || grandparent.right == pIndex, "Parent is not a child of its grandparent")
        
        if grandparent.left == pIndex {
            return grandparent.right
        } else {
            return grandparent.left
        }
    }
    
    mutating func delete(value: T) {
        var index = root
        // Find the node to be deleted
        while index != .empty {
            let node = self[index]
            if value == node.value {
                break
            } else if value < node.value {
                index = node.left
            } else {
                index = node.right
            }
        }
        
        guard index != .empty else {
            assertionFailure("value is not found")
            return
        }

        // At this point, "node" is the node to be deleted

        // In this variable, we'll store the node at which we're going to start to fix the R-B
        // properties after deleting a node.
        let movedUpNode: UInt32
        let deletedNodeColor: NodeColor

        let node = self[index]
        
        // Node has zero or one child
        if node.left == .empty || node.right == .empty {
            deletedNodeColor = node.color
            movedUpNode = deleteNodeWithZeroOrOneChild(node.index)
        } else {
            // Node has two children
            // Find minimum node of right subtree ("inorder successor" of current node)
            let inOrderSuccessor = findMinimum(node.right)
            deletedNodeColor = inOrderSuccessor.color
            
            // Copy inorder successor's data to current node (keep its color!)
            self[index].value = inOrderSuccessor.value

            // Delete inorder successor just as we would delete a node with 0 or 1 child
            movedUpNode = deleteNodeWithZeroOrOneChild(inOrderSuccessor.index)
        }

        // TODO case where movedUpNode == nil
        guard movedUpNode != .empty, deletedNodeColor == .black else {
            return
        }
        
        fixRedBlackPropertiesAfterDelete(movedUpNode)

        if movedUpNode == self.emptyIndex {
            let pIndex = self[movedUpNode].parent
            
            if pIndex != .empty {
                self.replaceParentsChild(pIndex, oldChild: movedUpNode)
            }
        }
    }
    
    mutating private func deleteNodeWithZeroOrOneChild(_ nIndex: UInt32) -> UInt32 {
        let node = self[nIndex]
        if node.left != .empty {
            // Node has ONLY a left child --> replace by its left child
            self.replaceParentsChild(node.parent, oldChild: nIndex, newChild: node.left)
            return node.left // moved-up node
        } else if node.right != .empty {
            // Node has ONLY a right child --> replace by its right child
            self.replaceParentsChild(node.parent, oldChild: nIndex, newChild: node.right)
            return node.right // moved-up node
        } else {
            // Node has no children -->
            // * node is red --> just remove it
            // * node is black --> replace it by a temporary NIL node (needed to fix the R-B rules)

            if node.parent != .empty {
                if node.color == .black {
                    let newChild = self.createNilNode(parent: node.parent)
                    replaceParentsChild(node.parent, oldChild: nIndex, newChild: newChild)
                    return newChild
                } else {
                    replaceParentsChild(node.parent, oldChild: nIndex)
                    return .empty
                }
            } else {
                if node.color == .black {
                    return emptyIndex
                } else {

                    return .empty
                }
            }
        }
    }
    
    private mutating func fixRedBlackPropertiesAfterDelete(_ nIndex: UInt32) {
        // Case 1: Examined node is root, end of recursion
        guard nIndex != root else {
            // Uncomment the following line if you want to enforce black roots (rule 2):
            // node.color = BLACK;
            return
        }

        var sIndex = getSibling(nIndex)

        // Case 2: Red sibling
        if self[sIndex].color == .red {
            handleRedSibling(nIndex, sIndex)
            sIndex = getSibling(nIndex) // Get new sibling for fall-through to cases 3-6
        }

        let sibling = self[sIndex]
        
        // Cases 3+4: Black sibling with two black children
        if isBlack(sibling.left) && isBlack(sibling.right) {
            self[sIndex].color = .red
            let pIndex = self[nIndex].parent
            
            // Case 3: Black sibling with two black children + red parent
            if self[pIndex].color == .red {
                self[pIndex].color = .black
            } else {
                // Case 4: Black sibling with two black children + black parent
                fixRedBlackPropertiesAfterDelete(pIndex)
            }
        } else {
            // Case 5+6: Black sibling with at least one red child
            handleBlackSiblingWithAtLeastOneRedChild(nIndex, sIndex)
        }
    }
    
    mutating private func handleBlackSiblingWithAtLeastOneRedChild(_ nIndex: UInt32, _ sIndex: UInt32) {
        var sIndex = sIndex
        let pIndex = self[nIndex].parent
        var sibling = self[sIndex]
        let nodeIsLeftChild = nIndex == self[pIndex].left

        // Case 5: Black sibling with at least one red child + "outer nephew" is black
        // --> Recolor sibling and its child, and rotate around sibling
        if nodeIsLeftChild && isBlack(sibling.right) {
            if sibling.left != .empty {
                self[sibling.left].color = .black
            }
            self[sIndex].color = .red
            rotateRight(sIndex)
            sIndex = self[pIndex].right
            sibling = self[sIndex]
        } else if !nodeIsLeftChild && isBlack(sibling.left) {
            if sibling.right != .empty {
                self[sibling.right].color = .black
            }
            self[sIndex].color = .red
            rotateLeft(sIndex)
            sIndex = self[pIndex].left
            sibling = self[sIndex]
        }

        // Fall-through to case 6...

        // Case 6: Black sibling with at least one red child + "outer nephew" is red
        // --> Recolor sibling + parent + sibling's child, and rotate around parent
        self[sIndex].color = self[pIndex].color
        self[pIndex].color = .black
        if nodeIsLeftChild {
            if sibling.right != .empty {
                self[sibling.right].color = .black
            }
            rotateLeft(pIndex)
        } else {
            if sibling.left != .empty {
                self[sibling.left].color = .black
            }
            rotateRight(pIndex)
        }
    }
    
    mutating private func handleRedSibling(_ nIndex: UInt32, _ sIndex: UInt32) {
        // Recolor...
        
        self[sIndex].color = .black
        let pIndex = self[nIndex].parent
        
        self[pIndex].color = .red

        // ... and rotate
        if nIndex == self[pIndex].left {
            rotateLeft(pIndex)
        } else {
            rotateRight(pIndex)
        }
    }
    
    private func getSibling(_ nIndex: UInt32) -> UInt32 {
        let pIndex = self[nIndex].parent
        let parent = self[pIndex]
        assert(nIndex == parent.left || nIndex == parent.right)
        if nIndex == parent.left {
            return parent.right
        } else {
            return parent.left
        }
    }
    
    private func findMinimum(_ nIndex: UInt32) -> TreeNode<T> {
        var i = nIndex
        var j = UInt32.max
        repeat {
            j = i
            i = self[i].left
        } while i != .empty
        
        return self[j]
    }
    
    func find(value: T) -> T? {
        var index = root

        while index != .empty {
            let node = self[index]
            if node.value == value {
                return node.value
            } else if value < node.value {
                index = node.left
            } else {
                index = node.right
            }
        }
        
        return nil
    }
    
}
