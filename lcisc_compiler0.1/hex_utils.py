


def hex_string_to_bytes(hex_string):
    return bytes.fromhex(hex_string)[::-1]#make the indexs always match as sv hex string will run in reverse

def byte_array_grouping(bytes_array,group_size = 4):
    end = []
    for start_index in range(0,len(bytes_array),group_size):
        num = 0
        for offset in range(group_size):
            num = num + bytes_array[start_index+offset] * 256 ** offset
        end.append(int(num))
    return end


def decode_system_verilog_struct(struct_string):

    end = {}    

    word = ""
    while(len(struct_string)>0):
        if(struct_string[0:1] == "'"):
            struct_string = struct_string[1:]
            pass #start of a value
        elif(struct_string[0:1] == "{"):
            struct_string = struct_string[1:]
            pass #start of a strucutre
        elif(struct_string[0:1] == "}"):
            struct_string = struct_string[1:]
            if(end == {}):
                end = word
            break #end of a strucutre
        elif(struct_string[0:1] == ","):
            #remove char end recursion save curent word as a value
            struct_string = struct_string[1:]
            if(end == {}):
                end = word
            break
            pass #start next section
        elif(struct_string[0:1] == ":"):
            #remove recurse and save result in dict
            struct_string = struct_string[1:]
            end[word],struct_string = decode_system_verilog_struct(struct_string)
            word = ""
            pass #key value switch
        else:
            word += struct_string[0]
            struct_string = struct_string[1:]

    return end,struct_string #return the values collected and the remaining string

    
if __name__ == "__main__":
    from pprint import pprint
    pprint(decode_system_verilog_struct("'{target:16,compareOperation:AltB,comparison:'{immediate:1'b0,value:34},increment:'{immediate:1'b1,value:2},setFlag:'{flag:0,condition:1'b1,negate:1'b0},conditionalFlag:'{flag:0,condition:1'b0,negate:1'b0}}")[0])

    pprint(decode_system_verilog_struct("'{immediate:1'b0,value:34}")[0])

    s = '''
        '{
        target:16,
        compareOperation:AltB,
        comparison:'{immediate:1'b0,value:34},
        increment:'{immediate:1'b1,value:2},
        setFlag:'{flag:0,condition:1'b1,negate:1'b0},
        conditionalFlag:'{flag:0,condition:1'b0,negate:1'b0}}
    '''