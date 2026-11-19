class BSTNode:
    def __init__(self, value):
        self.value = value
        self.left = None
        self.right = None


class HubBST:
    def __init__(self):
        self.root = None

    def insert(self, value):
        if self.root is None:
            self.root = BSTNode(value)
            return
        node = self.root
        while True:
            if value < node.value:
                if node.left is None:
                    node.left = BSTNode(value)
                    return
                node = node.left
            elif value > node.value:
                if node.right is None:
                    node.right = BSTNode(value)
                    return
                node = node.right
            else:
                return

    def search(self, value):
        node = self.root
        while node:
            if node.value == value:
                return True
            node = node.left if value < node.value else node.right
        return False

    def height(self, node=None, root_call=True):
        if root_call:
            node = self.root
        if node is None:
            return 0
        return 1 + max(self.height(node.left, False), self.height(node.right, False))


def find_repeated_scans(scans):
    """Input records are (tracking_number, hub_code)."""
    seen = set()
    repeated = []
    for tracking_number, hub_code in scans:
        key = (tracking_number, hub_code)
        if key in seen:
            repeated.append(key)
        else:
            seen.add(key)
    return repeated


def bfs_shortest_route(graph, start, destination):
    if start not in graph or destination not in graph:
        return None
    queue = [start]
    parent = {start: None}
    index = 0
    while index < len(queue):
        node = queue[index]
        index += 1
        if node == destination:
            path = []
            while node is not None:
                path.append(node)
                node = parent[node]
            return list(reversed(path))
        for neighbour in graph[node]:
            if neighbour not in parent:
                parent[neighbour] = node
                queue.append(neighbour)
    return None


def dfs_reachable(graph, start):
    if start not in graph:
        return []
    visited = set()
    result = []

    def visit(node):
        visited.add(node)
        result.append(node)
        for neighbour in graph[node]:
            if neighbour not in visited:
                visit(neighbour)

    visit(start)
    return result


def highest_average_window(values, window_size=4):
    if window_size <= 0 or len(values) < window_size:
        raise ValueError("A positive window size and enough hourly values are required.")
    current = sum(values[:window_size])
    best = current
    best_start = 0
    for i in range(window_size, len(values)):
        current += values[i] - values[i - window_size]
        if current > best:
            best = current
            best_start = i - window_size + 1
    return best_start, best_start + window_size - 1, best / window_size


def is_hub_palindrome(description):
    """Compare hub codes after ignoring case and non-alphanumeric separators."""
    cleaned = "".join(ch.casefold() for ch in description if ch.isalnum())
    left, right = 0, len(cleaned) - 1
    while left < right:
        if cleaned[left] != cleaned[right]:
            return False
        left += 1
        right -= 1
    return True


def main():
    print("SET 3 – LOGISTICS NETWORK AND DELIVERY WINDOWS")
    print("=" * 55)

    print("\n1. HUB CODE BINARY SEARCH TREE")
    hubs = ["HUB-50", "HUB-30", "HUB-70", "HUB-20", "HUB-40",
            "HUB-60", "HUB-80"]
    tree = HubBST()
    for hub in hubs:
        tree.insert(hub)
    print("Insertion order:", hubs)
    print("Search HUB-60:", tree.search("HUB-60"))
    print("Tree height (levels):", tree.height())
    sorted_tree = HubBST()
    for hub in sorted(hubs):
        sorted_tree.insert(hub)
    print("Height after sorted insertion:", sorted_tree.height())
    print("Sorted input creates a skewed tree; height can reach n.")

    print("\n2. PARCEL TRACKING HASH MAP")
    scans = [
        ("TRK100", "HUB-50"), ("TRK200", "HUB-30"),
        ("TRK100", "HUB-50"), ("TRK100", "HUB-60"),
        ("TRK300", "HUB-30"), ("TRK200", "HUB-30")
    ]
    print("Repeated scans at same hub:", find_repeated_scans(scans))

    print("\n3. TEN-HUB ROUTE GRAPH")
    graph = {
        "HUB-01": ["HUB-02", "HUB-03"],
        "HUB-02": ["HUB-01", "HUB-04", "HUB-05"],
        "HUB-03": ["HUB-01", "HUB-06"],
        "HUB-04": ["HUB-02", "HUB-07"],
        "HUB-05": ["HUB-02", "HUB-07", "HUB-08"],
        "HUB-06": ["HUB-03", "HUB-08"],
        "HUB-07": ["HUB-04", "HUB-05", "HUB-09"],
        "HUB-08": ["HUB-05", "HUB-06", "HUB-10"],
        "HUB-09": ["HUB-07", "HUB-10"],
        "HUB-10": ["HUB-08", "HUB-09"]
    }
    print("Adjacency list:")
    for hub, neighbours in graph.items():
        print(f"  {hub}: {', '.join(neighbours)}")
    route = bfs_shortest_route(graph, "HUB-01", "HUB-10")
    print("Fewest-hop route HUB-01 to HUB-10:", " -> ".join(route))
    print("Hubs reachable from central depot HUB-01:", dfs_reachable(graph, "HUB-01"))

    print("\n4. HIGHEST-AVERAGE FOUR-HOUR WINDOW")
    parcel_counts = [40, 55, 70, 90, 120, 150, 145, 130, 110, 95, 80, 75]
    start, end, average = highest_average_window(parcel_counts, 4)
    print("Hourly parcel counts:", parcel_counts)
    print(f"Best window: hours {start}–{end}; average = {average:.2f} parcels/hour")

    print("\n5. TWO-POINTER HUB-CODE PALINDROME")
    examples = ["A-B-C-B-A", "HUB-1 / HUB-2 / HUB-1", "HUB-01-HUB-02"]
    for description in examples:
        print(f"{description!r} -> {is_hub_palindrome(description)}")


if __name__ == "__main__":
    main()
