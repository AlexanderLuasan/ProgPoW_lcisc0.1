


import json
import hex_utils
import excel_util
import os_util


def create_event_list(file_path):
    events = []
    with open(file_path,'r') as f:
        for line in f.readlines():
            event = json.loads(line)
            events.append(event)
    return events


class event(excel_util.cell_base):
    def __init__(self,time,identifier,priority = 1):
        self.identifier = identifier
        self.priority = priority
        self.time = time
    def get_row(self):
        return self.time
    def get_col(self):
        return self.identifier
    def get_value(self):
        raise NotImplementedError
    
                    




class mixed_event(event):
    def __init__(self, time, identifier, priority,event_list):
        super().__init__(time, identifier, priority=priority)
        self.event_list = event_list
    
    def get_value(self):
        return "|".join([x.get_value() for x in self.event_list])

class operation_event(event):
    def __init__(self,time,thread_id,operation_name,arg_struct):
        super().__init__(time,f"thread_{thread_id}")
        self.thread_id = thread_id
        self.operation_name = operation_name
        self.arg_struct = arg_struct
    def get_value(self):
        return self.operation_name

class thread_create_event(event):
    def __init__(self,time,thread_id,thread_status):
        super().__init__(time,f"thread_{thread_id}",priority=100)
        self.thread_id = thread_id
        self.thread_status = thread_status
    def get_value(self):
        return f"init: {self.thread_status}"
    
class thread_delete_event(event):
    def __init__(self,time,thread_id):
        super().__init__(time,f"thread_{thread_id}",priority=100)
        self.thread_id = thread_id


    def get_value(self):
        return f"del"

class thread_fork_event(event):
    def __init__(self,time,thread_id,method,target,created,created_status):
        super().__init__(time,"forks")
        self.thead_id = thread_id
        self.method = method
        self.target = target
        self.created = created
        self.created_stats = created_status

    def get_value(self):
        return f"fork: {self.method} thread_id{self.target} -> {self.created}"

class thread_exec_event(event):
    def __init__(self,time,thread_id,method,target):
        super().__init__(time,"exec")
        self.thead_id = thread_id
        self.method = method
        self.target = target

    def get_value(self):
        return f"exec: {self.method} thread_id{self.target}"

class thread_status(event):
    def __init__(self,time,thread_id,status):
        super().__init__(time,f"thread_{thread_id}",priority=10)
        self.thread_id = thread_id
        self.status = status
    def get_value(self):
        return f"{self.status}"


class read_requset(event):
    def __init__(self, time, channel,requester_id, reciver_id,address ):
        super().__init__(time, f"read_channel_{channel}")
        self.requester_id = requester_id
        self.reciver_id = reciver_id
        self.channel = channel
        self.address = address
    def get_value(self):
        return f"{self.requester_id} reads: {self.address} for {self.reciver_id}"

class read_complete(event):
    def __init__(self, time,requester_id, reciver_id,address ):
        super().__init__(time, f"read_complete")
        self.requester_id = requester_id
        self.reciver_id = reciver_id
        self.address = address
    def get_value(self):
        return f"{self.requester_id} reads: {self.address} for {self.reciver_id}"




class log_write_request(event):
    unit_group = 4
    def __init__(self,time,address,start,after):
        super().__init__(time,f"write")
        self.address = address
        

        start = hex_utils.byte_array_grouping(hex_utils.hex_string_to_bytes(start),log_write_request.unit_group)
        after = hex_utils.byte_array_grouping(hex_utils.hex_string_to_bytes(after),log_write_request.unit_group)

        if(len(start)!=len(after)):
            print("error")
        self.difference_hash = {}
        for i in range(min(len(start),len(after))):
            if(start[i] != after[i]):
                self.difference_hash[i] = (start[i],after[i])
    def get_value(self):
        if(len(list(self.difference_hash.keys()))==0):
            return f"{self.address} no change"
        elif(len(list(self.difference_hash.keys()))<3):
            return f"{self.address} {' '.join([f'{k}:{v[0]}->{v[1]}' for k,v in self.difference_hash.items()])}"
        else:
            return f"{self.address} many changes"

class shared_write(event):
    def __init__(self,time,start,after):
        super().__init__(time,f"shared")
        start = hex_utils.byte_array_grouping(hex_utils.hex_string_to_bytes(start),log_write_request.unit_group)
        after = hex_utils.byte_array_grouping(hex_utils.hex_string_to_bytes(after),log_write_request.unit_group)
        if(len(start)!=len(after)):
            print("error")
        self.difference_hash = {}
        for i in range(min(len(start),len(after))):
            if(start[i] != after[i]):
                self.difference_hash[i] = (start[i],after[i])
    def get_value(self):
        if(len(list(self.difference_hash.keys()))==0):
            return f"no change"
        elif(len(list(self.difference_hash.keys()))<5):
            return f"{' '.join([f'{k}:{v[0]}->{v[1]}' for k,v in self.difference_hash.items()])}"
        else:
            return f"many changes"


def transform_event(event):

    try:
        
        if(event["type"] == "operation"):
            return(operation_event(event["time"],event['thread_id'],event["operation"],event["arguments"]))

        if(event["type"] == "thread_create"):
            return thread_create_event(event["time"],event['thread_id'],event["status"])

        if(event["type"] == "thread_create"):
            return thread_delete_event(event["time"],event['thread_id'])

        if(event["type"] == "thread_delete"):
            return thread_delete_event(event["time"],event['thread_id'])

        if(event["type"] == "thread_fork"):
            return thread_fork_event(event["time"],event['thread_id'],event["method"],event["target"],event["created"],event["created_status"]) 

        if(event["type"] == "thread_exec"):
            return thread_exec_event(event["time"],event['thread_id'],event["method"],event["target"]) 
        
        if(event["type"] == "thread_status"):
            return thread_status(event["time"],event['thread_id'],event["status"]) 
        if(event["type"] == "read_request"):
            return read_requset(event["time"],event["channel"],event['request_id'],event["receive_id"],event["address"])
        if(event["type"] == "read_complete"):
            return read_complete(event["time"],event['request_id'],event["receive_id"],event["address"])
        if(event["type"] == "write_request"):
            return log_write_request(event["time"],event["address"],event["start"],event["after"])

        if(event["type"] == "shared_write"):
            return shared_write(event["time"],event["start"],event["after"])
    except Exception as E:
        print(event)
        raise E


    return None

if __name__ == "__main__":
    print("locating_log_file")
    file = os_util.find("lcisc.log","./")
    print(f"file: {file}")
    events = list(filter(lambda x: x!=None,map(transform_event,create_event_list(file))))


   
        
    


    indexs = excel_util.row_colum_labeler()

    #calculating the rows labels
    
    #add the time rows
    all_times = list(map(lambda x:x.get_row(),events))

    

    for i in range(min(all_times),max(all_times)+10,10):
        indexs.add_row(i)

    #add the best choice column rows
    for col_name in ["shared","write","read_channel_1","read_channel_2","read_complete","exec","forks"]:
        indexs.add_column(col_name)

    #add any missing
    for e in events:
        indexs.add_by_cell(e)

    #finding conflicts
    event_hash = {}
    for e in events:
        event_hash[(e.get_row(),e.get_col())] = event_hash.get((e.get_row(),e.get_col()),[]) + [e]
    
    for k,v in event_hash.items():
        if(len(v)>1):
            events.append(mixed_event(k[0],k[1],10,v))
            for i in sorted(v,key = lambda x:x.priority,reverse=True):
                events.remove(i)

    
            
        

    excel_util.create_work_book("process_log.xlsx",events,indexs)

    
    




