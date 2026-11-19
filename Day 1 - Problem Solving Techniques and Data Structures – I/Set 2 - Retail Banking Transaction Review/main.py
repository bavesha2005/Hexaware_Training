from dataclasses import dataclass
from datetime import datetime, timedelta
from collections import deque
import csv, time

@dataclass
class Transaction:
    transactionId: int
    account: str
    amount: int
    merchant: str
    postedAt: datetime

def load_transactions(path="transactions.csv"):
    with open(path,newline="",encoding="utf-8") as f:
        return [Transaction(int(r["transactionId"]),r["account"],int(r["amount"]),r["merchant"],datetime.fromisoformat(r["postedAt"])) for r in csv.DictReader(f)]

def binary_search(a,target):
    lo,hi=0,len(a)-1; comparisons=0
    while lo<=hi:
        mid=(lo+hi)//2; comparisons+=1
        if a[mid]==target: return mid,comparisons
        if a[mid]<target: lo=mid+1
        else: hi=mid-1
    return -1,comparisons

def linear_search(a,target):
    comparisons=0
    for i,x in enumerate(a):
        comparisons+=1
        if x==target: return i,comparisons
    return -1,comparisons

def insertion_sort(items):
    a=items[:]
    for i in range(1,len(a)):
        key=a[i]; j=i-1
        while j>=0 and a[j].postedAt>key.postedAt:
            a[j+1]=a[j]; j-=1
        a[j+1]=key
    return a

def merge_sort(items):
    if len(items)<=1:return items[:]
    mid=len(items)//2; left=merge_sort(items[:mid]); right=merge_sort(items[mid:])
    out=[];i=j=0
    while i<len(left) and j<len(right):
        if left[i].postedAt<=right[j].postedAt:out.append(left[i]);i+=1
        else:out.append(right[j]);j+=1
    return out+left[i:]+right[j:]

def duplicate_postings(items):
    # Sorted time-window sweep + hash buckets; compare only same account/amount/merchant.
    buckets={}; found=[]
    for tx in sorted(items,key=lambda x:x.postedAt):
        key=(tx.account,tx.amount,tx.merchant)
        prior=buckets.setdefault(key,[])
        for old in prior:
            if (tx.postedAt-old.postedAt).total_seconds()<=60: found.append((old,tx))
        prior.append(tx)
    return found

class Queue:
    def __init__(self): self.data=[]; self.head=0
    def enqueue(self,x):self.data.append(x)
    def dequeue(self):
        if self.empty():raise IndexError("empty queue")
        x=self.data[self.head];self.head+=1;return x
    def empty(self):return self.head==len(self.data)

class Stack:
    def __init__(self):self.data=[]
    def push(self,x):self.data.append(x)
    def pop(self):
        if not self.data:raise IndexError("empty stack")
        return self.data.pop()

def divide_min_max(a):
    if len(a)==1:return a[0],a[0]
    if len(a)==2:return (a[0],a[1]) if a[0]<=a[1] else (a[1],a[0])
    mid=len(a)//2; lo1,hi1=divide_min_max(a[:mid]);lo2,hi2=divide_min_max(a[mid:])
    return min(lo1,lo2),max(hi1,hi2)

def run():
    txs=load_transactions()
    ids=sorted(t.transactionId for t in txs)
    n=100000
    # The assignment's 100,000-ID comparison exercise is independent of the smaller sample file.
    ids=list(range(1,n+1))
    for label,target in [("best",ids[n//2]),("average",ids[n//3]),("worst",n+1)]:
        bi,bc=binary_search(ids,target); li,lc=linear_search(ids,target)
        print(f"Task 1 | {label}: binary comparisons={bc}, linear comparisons={lc}, binary index={bi}")
    customer= [t for t in txs if t.account=="ACCT-001"]
    t=time.perf_counter(); ins=insertion_sort(customer); ins_ms=(time.perf_counter()-t)*1000
    t=time.perf_counter(); mer=merge_sort(customer); mer_ms=(time.perf_counter()-t)*1000
    print(f"Task 2 | statement rows={len(customer)} | insertion={ins_ms:.3f} ms | merge={mer_ms:.3f} ms | stable tie order={ [x.transactionId for x in ins if x.postedAt==ins[0].postedAt] }")
    print("Task 3 | duplicate postings:",len(duplicate_postings(txs)))
    q=Queue()
    for x in ["review-1","review-2","review-3"]:q.enqueue(x)
    s=Stack();s.push("adjustment-1");s.push("adjustment-2")
    print("Task 4 | queue next:",q.dequeue(),"| reverse last adjustment:",s.pop())
    amounts=[t.amount for t in txs]
    t=time.perf_counter(); lo,hi=divide_min_max(amounts); dc=(time.perf_counter()-t)*1000
    t=time.perf_counter(); blo,bhi=min(amounts),max(amounts); brute=(time.perf_counter()-t)*1000
    print(f"Task 5 | divide-conquer min={lo} max={hi} ({dc:.3f} ms) | scan min={blo} max={bhi} ({brute:.3f} ms)")

if __name__=="__main__":run()
