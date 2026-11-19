from dataclasses import dataclass
from datetime import datetime, timedelta
import csv, time

@dataclass
class Appointment:
    patientId: int
    urgency: int
    arrival: datetime
    start: int
    end: int

def load_appointments(path="appointments.csv"):
    with open(path,newline="",encoding="utf-8") as f:
        return [Appointment(int(r["patientId"]),int(r["urgency"]),datetime.fromisoformat(r["arrival"]),int(r["start"]),int(r["end"])) for r in csv.DictReader(f)]

def linear_search(a,target):
    for x in a:
        if x.patientId==target:return x
    return None

def binary_search(a,target):
    lo,hi=0,len(a)-1
    while lo<=hi:
        mid=(lo+hi)//2
        if a[mid].patientId==target:return a[mid]
        if a[mid].patientId<target:lo=mid+1
        else:hi=mid-1
    return None

def selection_sort(items):
    a=items[:]; swaps=0
    for i in range(len(a)):
        best=i
        for j in range(i+1,len(a)):
            if (a[j].urgency,a[j].arrival)<(a[best].urgency,a[best].arrival):best=j
        if best!=i:a[i],a[best]=a[best],a[i];swaps+=1
    return a,swaps

def quick_sort(items):
    a=items[:]; swaps=[0]
    def sort(lo,hi):
        if lo>=hi:return
        pivot=(a[hi].urgency,a[hi].arrival); i=lo
        for j in range(lo,hi):
            if (a[j].urgency,a[j].arrival)<=pivot:
                if i!=j:a[i],a[j]=a[j],a[i];swaps[0]+=1
                i+=1
        if i!=hi:a[i],a[hi]=a[hi],a[i];swaps[0]+=1
        sort(lo,i-1);sort(i+1,hi)
    sort(0,len(a)-1);return a,swaps[0]

def duplicate_slots(items):
    seen=set();dups=[]
    for a in items:
        key=(a.patientId,a.start,a.end)
        if key in seen:dups.append(key)
        else:seen.add(key)
    return dups

class Queue:
    def __init__(self):self.data=[];self.head=0
    def enqueue(self,x):self.data.append(x)
    def dequeue(self):
        if self.head>=len(self.data):raise IndexError("empty queue")
        x=self.data[self.head];self.head+=1;return x

class Stack:
    def __init__(self):self.data=[]
    def push(self,x):self.data.append(x)
    def pop(self):
        if not self.data:raise IndexError("empty stack")
        return self.data.pop()

def weighted_interval_dp(items):
    # Appointment intervals are measured in integer minutes from shift start.
    a=sorted(items,key=lambda x:x.end)
    p=[]
    for i,x in enumerate(a):
        j=i-1
        while j>=0 and a[j].end>x.start:j-=1
        p.append(j)
    dp=[0]*(len(a)+1)
    for i in range(1,len(a)+1):
        # Value = number of appointments; durations are used to determine compatibility.
        dp[i]=max(dp[i-1],1+dp[p[i-1]+1])
    chosen=[];i=len(a)
    while i>0:
        if 1+dp[p[i-1]+1]>dp[i-1]:
            chosen.append(a[i-1]);i=p[i-1]+1
        else:i-=1
    return list(reversed(chosen)),dp[-1]

def run():
    appts=load_appointments()
    ordered=sorted(appts,key=lambda x:x.patientId)
    target=ordered[-1].patientId
    t=time.perf_counter()
    for _ in range(1000):linear_search(appts,target)
    lin=(time.perf_counter()-t)*1000
    t=time.perf_counter()
    for _ in range(1000):binary_search(ordered,target)
    binms=(time.perf_counter()-t)*1000
    print(f"Task 1 | records={len(appts)} | 1000 lookups linear={lin:.2f} ms | binary={binms:.2f} ms")
    small=appts[:2000]
    t=time.perf_counter();sel,ss=selection_sort(small);sms=(time.perf_counter()-t)*1000
    t=time.perf_counter();quick,qs=quick_sort(small);qms=(time.perf_counter()-t)*1000
    print(f"Task 2 | 2000 rows | selection swaps={ss}, time={sms:.2f} ms | quick swaps={qs}, time={qms:.2f} ms")
    print("  Selection first three placements:",[(x.patientId,x.urgency) for x in sel[:3]])
    print("Task 3 | duplicate patient-slot keys:",len(duplicate_slots(appts)))
    q=Queue()
    for token in ["W-01","W-02","W-03"]:q.enqueue(token)
    st=Stack();st.push(201);st.push(202)
    print("Task 4 | next walk-in:",q.dequeue(),"| recent patient back:",st.pop())
    chosen,count=weighted_interval_dp(appts[:30])
    greedy=sorted(appts[:30],key=lambda x:x.end)
    greedy_chosen=[];end=-1
    for x in greedy:
        if x.start>=end:greedy_chosen.append(x);end=x.end
    print(f"Task 5 | DP max appointments={count} | greedy earliest-finish count={len(greedy_chosen)}")

if __name__=="__main__":run()
