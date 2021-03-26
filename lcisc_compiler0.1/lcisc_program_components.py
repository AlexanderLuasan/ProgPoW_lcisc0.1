

class vector_location:
    def __init__(self,offset,offset_size):
        self.offset = offset
        self.offset_size = offset_size
    
    def __str__(self):
        return f"{self.offset_size}+{self.offset}"
    
    

#store a variable
class variable_base:
    def __init__(self,name,bit_size,value = None,assignment = None):
        self.name = name #the name that will be used as reference
        self.bit_size = bit_size #a size in bits
        self.value = value #a string value that will be the location of the memory
        self.assignment = assignment # a string value that will be assignd to the location/const
    
    def set_bitposition(self,bitposition):
        self.bit_position = bitposition

    def check_allignment(self,bitposition):#return if this is a okay place to be located
        return (bitposition%self.bit_size == 0)
    
    def assignment_stagments(self):
        if(self.assignment!= None):
            return [(vector_location(self.bit_position//self.bit_size,self.bit_size),self.assignment)]
        else:
            return []
    def get_native_location(self):
        return [vector_location(self.bit_position//self.bit_size,self.bit_size)]
    
    #return a list of names and the corispoding values
    def get_name_value_pairs(self):
        raise NotImplementedError
    


class constant_type(variable_base):
    def __init__(self,name,assignment):
        super().__init__(name,0,assignment=assignment)
    def get_name_value_pairs(self):#a constant is always replaced with an assignment
        return [(self.name,self.assignment)] # just enter the value saved
    def check_allignment(self, bitposition):
        return True
    def assignment_stagments(self):
        return []
    def get_native_location(self):
        raise NotImplementedError

class u32_spacer(variable_base):
    def __init__(self,name = None,assignment = None):
        super().__init__("",32)
    def get_name_value_pairs(self):
        return []
    def check_allignment(self,bitposition):#return if this is a okay place to be located
        return (bitposition%32 == 0)
    def get_native_location(self):
        raise NotImplementedError
class u32_type(variable_base):
    def __init__(self,name,assignment = None):
        super().__init__(name,32,assignment=assignment)

    def get_name_value_pairs(self):# u32 is repalce with the vector location of the data
        return [(self.name,vector_location(self.bit_position//self.bit_size,self.bit_size))] 



class u64_type(variable_base):
    def __init__(self,name,assignment=None):
        super().__init__(name,64,assignment=assignment)

    def get_name_value_pairs(self):# u64 can be accessed as 64 or 32
            return [
                (self.name,vector_location(self.bit_position//self.bit_size,self.bit_size)),
                (self.name + ".32[0]" ,vector_location(self.bit_position//(self.bit_size//2),self.bit_size//2)), #lower half
                (self.name + ".32[1]" ,vector_location(self.bit_position//(self.bit_size//2)+1,self.bit_size//2)) #high half
                ] 


class u32_vector(variable_base):
    def __init__(self,name,length,assignment = []):
        super().__init__(name,32*length,assignment = assignment)
        self.length = length
    def get_name_value_pairs(self):# u32 is repalce with the vector location of the data
        return [(self.name,vector_location(self.bit_position//32,32))] 
    def check_allignment(self,bitposition):#return if this is a okay place to be located
        return (bitposition%32 == 0)
    def assignment_stagments(self):
        end = []
        if(self.assignment != None):
            for i in range(len(self.assignment)):
                end += [(vector_location(self.bit_position//32+i,32),self.assignment[i])]

        return end
    def get_native_location(self):
        return [vector_location(self.bit_position//32+i,32) for i in range(self.length)]


def add_namespace(name_space,dict_of_replace):
    temp = {}
    for k in dict_of_replace.keys():
        temp[f"{name_space}.{k}"] = dict_of_replace[k]
    for k,v in temp.items():
        dict_of_replace[k] = v
    return dict_of_replace

all_register_templates = {

}

class register_template_base:
    def __init__(self,address_values,name):
        
        self.vars = []
        self.bits_used = 0
        self.address_values = address_values
        self.name = name

        all_register_templates[name] = self
    def get_template(name):
        return all_register_templates[name]
    def add_variable(self,variable_obj):
        while(not variable_obj.check_allignment(self.bits_used)):
            self.add_variable(u32_spacer())

        variable_obj.set_bitposition(self.bits_used)
        self.bits_used = self.bits_used + variable_obj.bit_size
        self.vars.append(variable_obj)
    def replacements(self): #what will this try to replace
        end_dict = {}
        for var in self.vars:
            for name_set in var.get_name_value_pairs():
                if(isinstance(name_set[1],vector_location)):
                    end_dict[name_set[0]] = f"{self.address_values[str(name_set[1].offset_size)]} + {name_set[1].offset}"
                else:
                     end_dict[name_set[0]] = name_set[1]
        end_dict = add_namespace(self.name,end_dict)
        return end_dict
    def replace_args(self,replacement_priority,replacements_dict):#replace args with other template
        for i in range(len(self.vars)):
            for replaceable_target in replacement_priority:
                if( self.vars[i].assignment != None and isinstance(self.vars[i].assignment,str) and self.vars[i].assignment.find(replaceable_target) != -1):
                    
                    self.vars[i].assignment = f" {self.vars[i].assignment} ".replace(
                        "+"," + ").replace("-"," - "
                    ).replace(f" {replaceable_target} ",f" {replacements_dict[replaceable_target]} ").strip()
        

    def assignments(self): #what will this setup for assignemnts this is a locaiton that need to be givent a value
        end = []
        for var in self.vars:
            end = end + var.assignment_stagments()
        return end
    def get_location(self,name):
        for var in self.vars:
            for name_set in var.get_name_value_pairs():
                if(name_set[0] == name):#match
                    return var.get_native_location()


type_names = {
    "const":constant_type,
    "32_t": u32_type,
    "vec_32": u32_vector,
    "64_t":u64_type,
    "0":u32_spacer
}


def solve_single_statement(statement_string):
    statement = statement_string
    for type_name in type_names.keys():
            if(statement[:len(type_name)] == type_name):#found a match
                
                #remove the name
                statement = statement[len(type_name):].strip()

                length = None
                if(type_names[type_name] in [u32_vector]):
                    try:
                        length = int(statement.split(")")[0].replace("(",""))
                        statement = statement.replace(")","|").split("|")[1].strip() # get everything after
                    except:
                        raise Exception(f" could not find vector length: {statement_string}")
                
                assignment = None
                if(len(statement.split("="))==2): #there is an assignement
                    assign_string = statement.split("=")[1].strip()
                    statement = statement.split("=")[0].strip()#leave the name in the statement
                    if(type_names[type_name] in [u32_vector]):#strip the brackets and replace the string with a list
                        assign_string = [i.strip() for i in assign_string.replace("[","").replace("]","").split(",")]

                        
                    assignment = assign_string
                
                name=statement.strip()
                
                complete_statement = None
                if(type_names[type_name] in [u32_vector]):
                    complete_statement = type_names[type_name](name,length,assignment)
                else:
                    complete_statement = type_names[type_name](name,assignment)
                return complete_statement
def decode_template_string(target,content):
        
    statements = content.split(";")
    for statement_orig in statements:
        if(statement_orig.strip() == ""):
            continue
        statement=statement_orig.strip()
        
        complete_statement = solve_single_statement(statement)
                
        target.add_variable(complete_statement)


class global_template(register_template_base):
    def __init__(self,design,content_string = ""):
        name = content_string.split("{")[0].strip().split(" ")[1]
        content = recursive_block(content_string,"{","}")[:-1].strip()
    
        super().__init__({
            "32":"sharedAddress_u32",
            "64":"sharedAddress_u64",
        },name)
        decode_template_string(self,content)


class data_template(register_template_base):
    def __init__(self,design,content_string = ""):
        name = content_string.split("{")[0].split(" ")[1]
        content = recursive_block(content_string,"{","}")[:-1].strip()
    
        super().__init__({
            "32":"dataAddress_u32",
            "64":"dataAddress_u64",
        },name)
        decode_template_string(self,content)
class local_template(register_template_base):
    def __init__(self,name,content_string = ""):
        
        super().__init__({
            "32":"threadAddress_u32",
            "64":"threadAddress_u64",
        },name)
        #decode_template_string(self,content_string)
        








class operation_statement:
    def __init__(self,opcode,args = []):
        self.opcode = opcode
        self.args = args

        self.operation = None
        self.pipe_stage = None
        self.operation_enum_package = None

    def replace_args(self,replacement_priority,replacements_dict):#this function tries to replace the args in the input based on the decared types
        for i in range(len(self.args)):
            self.args[i] = " "+self.args[i].replace(","," , ").replace(";"," ; ").replace(")"," ) ").replace("("," ( ")+" "
            for replaceable_target in replacement_priority:
                if(self.args[i].find(replaceable_target) != -1): #found the value
                    if len(self.args[i].split("="))==1:
                        
                        self.args[i] = self.args[i].replace(f" {replaceable_target} ",f" {replacements_dict[replaceable_target]} ")
                    else:
                        self.args[i] = "=".join(
                            [
                                self.args[i].split("=")[0] ,
                                self.args[i].split("=")[1].replace(replaceable_target,replacements_dict[replaceable_target])
                            ]
                        )
        #aditionaly replace [num] with offset num

        for i in range(len(self.args)):
            self.args[i] = self.args[i].replace("[","+").replace("]","")

        #replace to named arguments if there is an equal sign

        for i in range(len(self.args)):
            if len(self.args[i].split("="))>1:
                self.args[i] = f".{self.args[i].split('=')[0].strip()}({self.args[i].split('=')[1].strip()})"


    def get_opcode(self):
        return self.opcode
    def set_opcode(self,opcode):
        self.opcode = opcode
    def set_operation(self,operation):                    
        self.operation = operation
    def set_pipe_stage(self,pipe_stage):
        self.pipe_stage = pipe_stage
    def set_operation_enum_package(self,package):
        self.operation_enum_package = package

    #produce an sv string the loads the data into the pipestage structure
    def sv_string(self):

        end = ""



        end += self.pipe_stage.sv_wrap_function([f"{self.operation_enum_package}::{self.get_opcode()}",self.operation.sv_wrap_function(",".join(self.args))])

        return end


def recursive_block(base_string,start_char,end_char):
    internal_string = ""
    index = 0
    
    while(index < len(base_string) and base_string[index] != start_char):
        index = index + 1
    level_count = 1
    index = index +1
    
    while(0 != level_count and index < len(base_string)):

        internal_string=internal_string+base_string[index]
        if(base_string[index] == start_char):
            level_count = level_count + 1
        elif(base_string[index] == end_char):
            level_count = level_count - 1
        index = index + 1
    return internal_string

class instruction:

    def __init__(self,design,data_string):

        data_string = data_string.replace("{"," { ").replace("}", " } ").replace(","," , ")

        while(len(data_string) > len(data_string.replace("  "," "))):
            data_string = data_string.replace("  "," ")
        self.creation_parameters = []
        self.register_templates = []
        
        self.operations = []

        self.name = data_string.split("(")[0].split("{")[0].strip().split(" ")[1]
        #print("name:",self.name)

        self.local_names = local_template(self.name)

        self.creation_parameters = [i.strip() for i in recursive_block(data_string.split("{")[0],"(",")")[:-1].split(",") if i.strip() != ""]
        #print(self.creation_parameters)
        
        
        self.internal_block = recursive_block(data_string,"{","}")[:-1].strip()
        

        statements = self.internal_block.split(";")

        for statement in statements:
            statement = statement.strip()
            if(statement == ""):
                continue
            is_var_statement = False
            for var_type in type_names.keys():
                if(statement[:len(var_type)] == var_type):
                    is_var_statement = True
                    break

            is_import_template = False

            if(statement[:len("import")] == "import"):
                is_import_template = True
            
            if(is_var_statement):
                self.local_names.add_variable(solve_single_statement(statement))
            elif(is_import_template):
                template_name = statement[len("import"):].strip().replace(";","").strip().split(" ")[0]
                self.register_templates = self.register_templates + [register_template_base.get_template(template_name)]
            else:#this is an operation statement
                #print(statement)
                opcode=statement.split(" ")[0].strip()
                

                args = statement[len(opcode):].replace(";","").strip().split(",")
                self.operations.append(operation_statement(opcode,args))

        #everything not included in the local
        combind_dict = {}
        for register_template in self.register_templates:
            for k , v in register_template.replacements().items():
                combind_dict[k] = v            
        priority = sorted(list(combind_dict.keys()),key = lambda x: x.count(".")*1000+len(x),reverse=True)
        #do repalcement in the local

        self.local_names.replace_args(priority,combind_dict)
        
        #add the local
        self.register_templates.append(self.local_names)

        #recreate the names
        combind_dict = {}
        for register_template in self.register_templates:
            for k , v in register_template.replacements().items():
                combind_dict[k] = v

        priority = sorted(list(combind_dict.keys()),key = lambda x: x.count(".")*1000+len(x),reverse=True)
        for op in self.operations:
            op.replace_args(priority,combind_dict)

        self.pm = design.get_component(design.program_model_name)

        pipe_stages = self.pm.get_porgramable_pipe_stages()
        print(self.name,len(pipe_stages),">=",len(self.operations))
        for i in range(len(pipe_stages)):
                
            if(i >= len(self.operations)):
                self.operations.append(operation_statement(None))

            valid = pipe_stages[i].check_valid_operation(self.operations[i])
            #print(valid)
            if(valid):
                pipe_stages[i].bind_operation(self.operations[i])
            else:
                self.operations.insert(i,operation_statement(None))
                pipe_stages[i].bind_operation(self.operations[i])
    def sv_string(self):
        end = ""
        end += f"function program_instruction {self.name}("
        end += ",".join(f"input integer {c}" for c in self.creation_parameters)
        end += ");\n"
        end += f"{self.name}.thread_and_instucions = 0;\n"
        #do the assignments
        asignments =  self.local_names.assignments()

        for location_vec,string_val in asignments:
            
            the_type = str(location_vec.offset_size)
            index = str(location_vec.offset)
            
            end += f"{self.name}.thread_and_instucions.thread.u{the_type}[{index}] = {string_val};\n"


        end += f"{self.name}.thread_and_instucions = pack_thread({self.name}.thread_and_instucions,"
        end += self.pm.sv_wrap_function([op.sv_string() for op in self.operations]).replace(",",",\n\t")
        end += ");\n"


        end += "endfunction\n"
        return end    





                    

            #checking for variable statement


if __name__ == "__main__":
    print("hello world")


    a = register_template_base({
            "32":"globalAddress_u32",
            "64":"globalAddress_u64",
        },"g")

    a.add_variable(u32_type("var1"))
    a.add_variable(u64_type("var2"))
    a.add_variable(u32_vector("vec1",3))
    a.add_variable(constant_type("cons1",15))
    a.add_variable(constant_type("cons2",16))
    a.add_variable(u32_type("var3",3))
    a.add_variable(u64_type("var4","cost1"))


    b = global_template(None,'''
        global_template f {
        32_t var1;
        64_t var2;
        vec_32 (3) vec1 ;
        const const1 = 15;
        const const2 = 16;
        32_t var3 = 3;
        64_t var4 = const1;  
        }
    ''')

    print("names")
    for key,value in a.replacements().items():
        print(f"{key}:{str(value)}")

    for key,value in b.replacements().items():
        print(f"{key}:{str(value)}")

    
    

    print("assignments")
    for location,value in a.assignments():
        print(f"{location}:{value}")