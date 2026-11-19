from dataclasses import dataclass
from datetime import datetime, timedelta
from collections import deque
import csv, random, time

@dataclass
class Order:
    orderId: int
    customerId: int
    amount: int
    createdAt: datetime

def load_orders(path="orders.csv"):
    with open(path, newline="", encoding="utf-8") as f:
        return [Order(int(r["orderId"]), int(r["customerId"]), int(r["amount"]),
                      datetime.fromisoformat(r["createdAt"])) for r in csv.DictReader(f)]

def linear_search(items, target):
    for item in items:
        if item.orderId == target: return item
    return None

def binary_search(items, target):
    lo, hi = 0, len(items)-1
    while lo <= hi:
        mid = (lo+hi)//2
        if items[mid].orderId == target: return items[mid]
        if items[mid].orderId < target: lo = mid+1
        else: hi = mid-1
    return None

def bubble_sort_desc(items):
    a = items[:]
    passes = []
    for i in range(min(3, len(a)-1)):
        for j in range(len(a)-1-i):
            if a[j].amount < a[j+1].amount: a[j], a[j+1] = a[j+1], a[j]
        passes.append([x.amount for x in a[:5]])
    for i in range(3, len(a)-1):
        for j in range(len(a)-1-i):
            if a[j].amount < a[j+1].amount: a[j], a[j+1] = a[j+1], a[j]
    return a, passes

def merge_sort_desc(items):
    if len(items) <= 1: return items[:]
    mid = len(items)//2
    left, right = merge_sort_desc(items[:mid]), merge_sort_desc(items[mid:])
    out=[]; i=j=0
    while i<len(left) and j<len(right):
        if left[i].amount >= right[j].amount: out.append(left[i]); i+=1
        else: out.append(right[j]); j+=1
    return out+left[i:]+right[j:]

def duplicate_orders(items):
    seen = {}
    duplicates=[]
    for o in items:
        key=(o.customerId, o.amount, o.createdAt.replace(second=0, microsecond=0))
        if key in seen: duplicates.append((seen[key], o))
        else: seen[key]=o
    return duplicates

class Stack:
    def __init__(self): self._data=[]
    def push(self, value): self._data.append(value)
    def pop(self):
        if not self._data: raise IndexError("pop from empty stack")
        return self._data.pop()
    def is_empty(self): return not self._data

class Queue:
    def __init__(self): self._data=[]; self._front=0
    def enqueue(self, value): self._data.append(value)
    def dequeue(self):
        if self.is_empty(): raise IndexError("dequeue from empty queue")
        value=self._data[self._front]; self._front+=1
        if self._front > 32 and self._front*2 >= len(self._data):
            self._data=self._data[self._front:]; self._front=0
        return value
    def is_empty(self): return self._front >= len(self._data)

def greedy_change(amount, denominations):
    result={}
    for d in sorted(denominations, reverse=True):
        count, amount = divmod(amount, d)
        if count: result[d]=count
    return result if amount == 0 else None

def dp_change(amount, denominations):
    inf=amount+1; dp=[0]+[inf]*amount; prev=[None]*(amount+1)
    for value in range(1, amount+1):
        for coin in denominations:
            if coin <= value and dp[value-coin]+1 < dp[value]:
                dp[value]=dp[value-coin]+1; prev[value]=coin
    if dp[amount] == inf: return None
    result={}
    while amount:
        coin=prev[amount]; result[coin]=result.get(coin,0)+1; amount-=coin
    return result

def run():
    orders=load_orders()
    target=orders[-1].orderId
    sorted_orders=sorted(orders, key=lambda x:x.orderId)
    t=time.perf_counter(); linear_search(orders,target); linear_ms=(time.perf_counter()-t)*1000
    t=time.perf_counter(); binary_search(sorted_orders,target); binary_ms=(time.perf_counter()-t)*1000
    print(f"Task 1 | records={len(orders)} | target={target} | linear={linear_ms:.4f} ms | binary={binary_ms:.4f} ms")
    sample=orders[:10000]
    t=time.perf_counter(); bubble, passes=bubble_sort_desc(sample); bubble_ms=(time.perf_counter()-t)*1000
    t=time.perf_counter(); merged=merge_sort_desc(sample); merge_ms=(time.perf_counter()-t)*1000
    t=time.perf_counter(); builtin=sorted(sample,key=lambda x:x.amount,reverse=True); builtin_ms=(time.perf_counter()-t)*1000
    print(f"Task 2 | bubble={bubble_ms:.2f} ms | merge={merge_ms:.2f} ms | built-in={builtin_ms:.2f} ms | same_order={ [x.amount for x in merged]==[x.amount for x in builtin] }")
    print("  Bubble first-three-pass top-five amounts:", passes)
    print("Task 3 | duplicate pairs:", len(duplicate_orders(orders)))
    st=Stack(); st.push("amount:100"); st.push("amount:125"); print("Task 4 | custom stack undo:", st.pop())
    q=Queue()
    for oid in [101,102,103]: q.enqueue(oid)
    print("  custom queue dispatch:", [q.dequeue(),q.dequeue(),q.dequeue()])
    builtin_stack=[]; builtin_stack.append("edit-A"); builtin_stack.append("edit-B")
    builtin_queue=deque([101,102,103])
    print("  built-ins:", builtin_stack.pop(), [builtin_queue.popleft() for _ in range(3)])
    print("Task 5 | amount=6, denominations=[1,3,4] | greedy:", greedy_change(6,[1,3,4]), "| DP:", dp_change(6,[1,3,4]))

if __name__ == "__main__": run()
