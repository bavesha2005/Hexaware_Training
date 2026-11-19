import unittest
from insurance_claims import (
    ClaimBST, find_duplicate_claims, bfs_shortest_path,
    has_directed_cycle, longest_run_over_threshold, merge_sorted_lists
)


class TestInsuranceClaims(unittest.TestCase):
    def test_empty_bst(self):
        tree = ClaimBST()
        self.assertEqual(tree.inorder(tree.root), [])
        self.assertFalse(tree.search(10))

    def test_bst_duplicate_insert(self):
        tree = ClaimBST()
        tree.insert(10)
        tree.insert(10)
        self.assertEqual(tree.inorder(tree.root), [10])

    def test_duplicate_claim_case_and_spaces(self):
        claims = [("POL 10", "2026-01-01"), ("pol 10", "2026-01-01")]
        self.assertEqual(find_duplicate_claims(claims), [("pol10", "2026-01-01")])

    def test_empty_duplicate_input(self):
        self.assertEqual(find_duplicate_claims([]), [])

    def test_bfs_path(self):
        graph = {"a": ["b", "c"], "b": ["d"], "c": ["d"], "d": []}
        self.assertEqual(bfs_shortest_path(graph, "a", "d"), ["a", "b", "d"])

    def test_unreachable_path(self):
        graph = {"a": [], "b": []}
        self.assertIsNone(bfs_shortest_path(graph, "a", "b"))

    def test_cycle(self):
        self.assertTrue(has_directed_cycle({"a": ["b"], "b": ["a"]}))
        self.assertFalse(has_directed_cycle({"a": ["b"], "b": []}))

    def test_empty_run(self):
        self.assertEqual(longest_run_over_threshold([]), (0, 0))

    def test_threshold_is_strict(self):
        self.assertEqual(longest_run_over_threshold([100, 101, 100, 102]), (1, 1))

    def test_merge_empty_lists(self):
        self.assertEqual(merge_sorted_lists([], []), [])

    def test_merge_one_empty(self):
        self.assertEqual(merge_sorted_lists([1, 3], []), [1, 3])

    def test_merge_duplicates(self):
        self.assertEqual(merge_sorted_lists([1, 2, 2], [2, 3]), [1, 2, 2, 2, 3])


if __name__ == "__main__":
    unittest.main(verbosity=2)
