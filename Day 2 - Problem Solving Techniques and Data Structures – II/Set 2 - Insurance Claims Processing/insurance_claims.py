class BSTNode:
    def __init__(self, value):
        self.value = value
        self.left = None
        self.right = None


class ClaimBST:
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

    def inorder(self, node):
        return self.inorder(node.left) + [node.value] + self.inorder(node.right) if node else []

    def preorder(self, node):
        return [node.value] + self.preorder(node.left) + self.preorder(node.right) if node else []

    def postorder(self, node):
        return self.postorder(node.left) + self.postorder(node.right) + [node.value] if node else []


def normalize_claim(policy_number, incident_date):
    """Ignore letter case and all whitespace in both identifying fields."""
    policy = "".join(str(policy_number).casefold().split())
    date = "".join(str(incident_date).casefold().split())
    return policy, date


def find_duplicate_claims(claims):
    """Return normalized keys that occur more than once."""
    seen = set()
    duplicates = set()
    for policy, date in claims:
        key = normalize_claim(policy, date)
        if key in seen:
            duplicates.add(key)
        else:
            seen.add(key)
    return sorted(duplicates)


def bfs_shortest_path(graph, start, destination):
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


def has_directed_cycle(graph):
    WHITE, GRAY, BLACK = 0, 1, 2
    colour = {node: WHITE for node in graph}

    def dfs(node):
        colour[node] = GRAY
        for neighbour in graph[node]:
            if neighbour not in colour:
                colour[neighbour] = WHITE
            if colour[neighbour] == GRAY:
                return True
            if colour[neighbour] == WHITE and dfs(neighbour):
                return True
        colour[node] = BLACK
        return False

    return any(colour[node] == WHITE and dfs(node) for node in list(colour))


def longest_run_over_threshold(values, threshold=100):
    """Variable-size sliding window over consecutive days above the threshold."""
    left = 0
    best_start = best_length = 0
    for right in range(len(values)):
        if values[right] <= threshold:
            left = right + 1
        else:
            current_length = right - left + 1
            if current_length > best_length:
                best_start, best_length = left, current_length
    return best_start, best_length


def merge_sorted_lists(first, second):
    """Merge two sorted lists in O(n+m) time; result list is the output."""
    i = j = 0
    merged = []
    while i < len(first) and j < len(second):
        if first[i] <= second[j]:
            merged.append(first[i])
            i += 1
        else:
            merged.append(second[j])
            j += 1
    merged.extend(first[i:])
    merged.extend(second[j:])
    return merged


def main():
    print("SET 2 – INSURANCE CLAIMS PROCESSING")
    print("=" * 48)

    print("\n1. CLAIM ID BINARY SEARCH TREE")
    claims_tree = ClaimBST()
    claim_ids = [105, 102, 108, 101, 104, 107, 110]
    for claim_id in claim_ids:
        claims_tree.insert(claim_id)
    print("Inorder:  ", claims_tree.inorder(claims_tree.root))
    print("Preorder: ", claims_tree.preorder(claims_tree.root))
    print("Postorder:", claims_tree.postorder(claims_tree.root))
    print("Search 107:", claims_tree.search(107))
    print("Inorder gives sorted claim IDs.")

    print("\n2. HASHING FOR DUPLICATE CLAIMS")
    submitted_claims = [
        ("POL-100", "2026-05-01"),
        ("pol-100", "2026-05-01"),
        ("POL-200", "2026-05-02"),
        (" POL-200 ", " 2026-05-02 "),
        ("POL-300", "2026-05-03")
    ]
    print("Duplicate normalized keys:", find_duplicate_claims(submitted_claims))
    print("Python set/dict hashing handles collisions by checking key equality;")
    print("different keys that share a hash are not treated as equal.")

    print("\n3. CLAIM APPROVAL GRAPH")
    stages = {
        "registration": ["assessment"],
        "assessment": ["surveyor", "settlement"],
        "surveyor": ["settlement"],
        "settlement": []
    }
    path = bfs_shortest_path(stages, "registration", "settlement")
    print("Shortest path registration → settlement:", " -> ".join(path))
    loop_graph = {"registration": ["assessment"],
                  "assessment": ["surveyor"],
                  "surveyor": ["registration"]}
    print("Loop detected in sample graph:", has_directed_cycle(loop_graph))

    print("\n4. CONSECUTIVE CLAIM-SPIKE DAYS")
    daily_claims = [80, 105, 120, 135, 90, 110, 115, 130, 140, 95, 101, 102]
    start, length = longest_run_over_threshold(daily_claims, 100)
    print("Daily claims:", daily_claims)
    print(f"Longest run above 100: {length} days (zero-based index {start} to {start + length - 1})")

    print("\n5. MERGE TWO REGIONAL CLAIM LISTS")
    north = [101, 104, 109, 115, 120]
    south = [102, 103, 110, 118]
    print("North region:", north)
    print("South region:", south)
    print("Merged sorted list:", merge_sorted_lists(north, south))


if __name__ == "__main__":
    main()
