from time import perf_counter

class BSTNode:
    def __init__(self, value):
        self.value = value
        self.left = None
        self.right = None


class BST:
    def __init__(self):
        self.root = None

    def insert(self, value):
        if self.root is None:
            self.root = BSTNode(value)
            return
        current = self.root
        while True:
            if value < current.value:
                if current.left is None:
                    current.left = BSTNode(value)
                    return
                current = current.left
            elif value > current.value:
                if current.right is None:
                    current.right = BSTNode(value)
                    return
                current = current.right
            else:
                return

    def search(self, value):
        current = self.root
        while current:
            if value == current.value:
                return True
            current = current.left if value < current.value else current.right
        return False

    def inorder(self, node):
        if node:
            self.inorder(node.left)
            print(node.value, end=" | ")
            self.inorder(node.right)

    def preorder(self, node):
        if node:
            print(node.value, end=" | ")
            self.preorder(node.left)
            self.preorder(node.right)

    def postorder(self, node):
        if node:
            self.postorder(node.left)
            self.postorder(node.right)
            print(node.value, end=" | ")


class ChainedHashTable:
    def __init__(self, capacity=11):
        self.capacity = capacity
        self.buckets = [[] for _ in range(capacity)]

    def _index(self, key):
        return sum(ord(ch) for ch in str(key)) % self.capacity

    def put(self, key, value):
        bucket = self.buckets[self._index(key)]
        for i, (existing, _) in enumerate(bucket):
            if existing == key:
                bucket[i] = (key, value)
                return
        bucket.append((key, value))

    def get(self, key):
        for existing, value in self.buckets[self._index(key)]:
            if existing == key:
                return value
        return None


def benchmark_lookups(count=100_000):
    skus = [f"SKU{i:06d}" for i in range(count)]
    custom = ChainedHashTable(capacity=200_003)
    builtin = {}
    for sku in skus:
        custom.put(sku, sku)
        builtin[sku] = sku

    queries = skus[::10]  # 10,000 successful lookups
    start = perf_counter()
    for sku in queries:
        custom.get(sku)
    custom_time = perf_counter() - start

    start = perf_counter()
    for sku in queries:
        builtin.get(sku)
    builtin_time = perf_counter() - start

    print(f"Custom chained table: {custom_time:.6f} seconds")
    print(f"Built-in dict:        {builtin_time:.6f} seconds")
    print("Note: timings vary by computer and Python version.")


def bfs_topological_order(graph):
    indegree = {node: 0 for node in graph}
    for neighbours in graph.values():
        for neighbour in neighbours:
            indegree[neighbour] += 1

    queue = [node for node in graph if indegree[node] == 0]
    order = []
    index = 0
    while index < len(queue):
        node = queue[index]
        index += 1
        order.append(node)
        for neighbour in graph[node]:
            indegree[neighbour] -= 1
            if indegree[neighbour] == 0:
                queue.append(neighbour)
    return order if len(order) == len(graph) else None


def has_cycle_dfs(graph):
    WHITE, GRAY, BLACK = 0, 1, 2
    colour = {node: WHITE for node in graph}

    def visit(node):
        colour[node] = GRAY
        for neighbour in graph[node]:
            if colour[neighbour] == GRAY:
                return True
            if colour[neighbour] == WHITE and visit(neighbour):
                return True
        colour[node] = BLACK
        return False

    return any(colour[node] == WHITE and visit(node) for node in graph)


def busiest_three_hour_window(requests):
    if len(requests) < 3:
        raise ValueError("At least three hourly values are required.")
    current = sum(requests[:3])
    best = current
    best_start = 0
    for i in range(3, len(requests)):
        current += requests[i] - requests[i - 3]
        if current > best:
            best = current
            best_start = i - 2
    return best_start, best_start + 2, best


def gift_card_pairs(sorted_values, target):
    left, right = 0, len(sorted_values) - 1
    pairs = []
    while left < right:
        total = sorted_values[left] + sorted_values[right]
        if total == target:
            pairs.append((sorted_values[left], sorted_values[right]))
            left += 1
            right -= 1
        elif total < target:
            left += 1
        else:
            right -= 1
    return pairs


def main():
    print("SET 1 – E-COMMERCE CATALOGUE AND TRAFFIC ANALYSIS")
    print("=" * 55)

    categories = [
        "Electronics", "Fashion", "Books", "Home", "Sports",
        "Beauty", "Toys", "Grocery", "Automotive", "Furniture",
        "Jewellery", "Footwear", "Gaming", "Stationery", "Appliances"
    ]
    tree = BST()
    for category in categories:
        tree.insert(category)

    print("\n1. BINARY SEARCH TREE")
    print("Inorder:   ", end="")
    tree.inorder(tree.root)
    print("\nPreorder:  ", end="")
    tree.preorder(tree.root)
    print("\nPostorder: ", end="")
    tree.postorder(tree.root)
    print("\nSearch 'Gaming':", tree.search("Gaming"))
    print("Search 'Pharmacy':", tree.search("Pharmacy"))

    print("\n2. HASH TABLE AND SKU LOOK-UP")
    table = ChainedHashTable(capacity=5)
    table.put("SKU-101", "Wireless Mouse")
    table.put("SKU-110", "Keyboard")
    print("Index of SKU-101:", table._index("SKU-101"))
    print("Index of SKU-110:", table._index("SKU-110"))
    print("Collision bucket:", table.buckets[table._index("SKU-101")])
    print("Lookup SKU-110:", table.get("SKU-110"))
    print("Benchmark with 100,000 SKUs (10,000 look-ups):")
    benchmark_lookups()

    print("\n3. MICROSERVICE DEPENDENCY GRAPH")
    graph = {
        "gateway": ["cart", "catalogue"],
        "cart": ["pricing"],
        "pricing": ["inventory"],
        "catalogue": ["inventory"],
        "inventory": ["payment"],
        "payment": ["notification"],
        "notification": []
    }
    print("Valid deployment order (BFS/Kahn):", " -> ".join(bfs_topological_order(graph)))
    cyclic_graph = {"cart": ["pricing"], "pricing": ["inventory"],
                    "inventory": ["cart"]}
    print("Circular dependency detected:", has_cycle_dfs(cyclic_graph))

    print("\n4. BUSIEST CONTINUOUS 3-HOUR WINDOW")
    hourly_requests = [
        120, 135, 150, 180, 210, 240, 260, 280, 300, 290, 270, 250,
        230, 220, 210, 200, 190, 180, 170, 160, 150, 140, 130, 125
    ]
    start, end, total = busiest_three_hour_window(hourly_requests)
    print(f"Hours {start:02d}:00–{end + 1:02d}:00; total requests = {total}")
    print(f"Average requests per hour = {total / 3:.2f}")

    print("\n5. TWO-POINTER GIFT-CARD PAIRS")
    order_values = [10, 15, 20, 25, 30, 35, 40, 45, 50]
    target = 60
    print("Sorted order values:", order_values)
    print("Gift-card value:", target)
    print("Matching pairs:", gift_card_pairs(order_values, target))


if __name__ == "__main__":
    main()
