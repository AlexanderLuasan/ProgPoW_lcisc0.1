



class lcisc_conector:
    def __init__(self):
        pass
    def connections(self):
        raise NotImplementedError()
class lcisc_definer:
    def __init__(self):
        pass
    def definitions(self):
        raise NotImplementedError()

class lcisc_declarer:
    def __init__(self):
        pass
    def declarations(self):
        raise NotImplementedError()

class lcisc_file_base:
    def __init__(self):
        pass
    def file_path(self):
        raise NotImplementedError

#this thing can go inside a pipeline
class lcisc_pipe_component:
    def __init__(self):
        pass
    def in_port(self, name = None): #return half a connection object
        raise NotImplementedError()
    def out_port(self,name = None):#return half a connection object
        raise NotImplementedError()
    def modifyable(self):#can this object take on aditional functions
        raise NotImplementedError()
    #return stuff to be given to lcsic
    def get_declarations(self): #return a set of declrations for self
        raise NotImplementedError()
    def get_connections(self): #return a set for connections for self
        raise NotImplementedError()
    #return stuff to be given to the stage above
    def get_pipe_components(self):
        raise NotImplementedError()
    def get_stage_names(self):
        raise NotImplementedError()
    def get_pipe_connections(self):
        raise NotImplementedError()
    
class lcisc_pipe_template:
    def __init__(self):
        pass
    def make_copy(self):#produce a modifyable copy of the template as a lcisc_pip_component
        raise NotImplementedError()
    def in_port(self, name): #return half a connection object
        raise NotImplementedError()
    def out_port(self, name):#return half a connection object
        raise NotImplementedError()





#be able to add the parameter for your access function
#is a pointer to a declarable object
class no_opp():
    def sv_wrap_function(self,sv_string):
        return "0"
class lcisc_porgramable_component():
    def __init__(self):
        self.index_number = -1

    def get_instuction_name(self):
        raise NotImplementedError
    def get_pipestage_arg_struct(self):
        raise NotImplementedError
    def get_arg_package(self):
        raise NotImplementedError
    
    def needs_data(self):
        if(self.get_access_function_name()) == None:
            return False
        if(self.get_pipestage_arg_struct()==None):
            return False
        if(self.get_arg_package()==None):
            return False
        return True


    #how will the module access the function
    def is_indexed_function(self):#will you be accessing with an index number
        raise NotImplementedError
    def set_index_number(self,i):
        self.index_number = i
    def get_index_number(self):
        return self.index_number
    def get_index_parameter_name(self):#need to tell you your number
        raise NotImplementedError
    def get_access_function_name(self):#I will make a function with this name for you
        raise NotImplementedError
    def get_access_function_package(self):# it will be put in a package with this name
        raise NotImplementedError
    
    #stuff used to create the system verilog
    #sting to be used when it is an input to a function or structure
    def declaration_sv_string(self):
        return f"{self.get_arg_package()}::{self.get_pipestage_arg_struct()} {self.get_instuction_name()}"

    def get_operations(self):#list of operation pointers
        raise NotImplementedError
    def get_wrap_function_name(self): #string
        raise NotImplementedError
    #link the operation and the current stage to the 
    def bind_operation(self,operation_class):
        
        if(operation_class.get_opcode() == None):
            operation_class.set_pipe_stage(self)
            operation_class.set_operation_enum_package(self.get_arg_package())
            operation_class.set_operation(no_opp())
            operation_class.set_opcode("no_opp")
            return True
        operation_and_names = [(op.name,op) for op in self.get_operations()]
        for name,op in operation_and_names:
            if operation_class.get_opcode() == name:
                operation_class.set_operation(op)
                operation_class.set_operation_enum_package(self.get_arg_package())
                operation_class.set_pipe_stage(self)
                return True
        return False

    def check_valid_operation(self,operation_class):

        if(operation_class.get_opcode() == None):
            return True 
        operation_and_names = [(op.name,op) for op in self.get_operations()]
        for name,op in operation_and_names:
            if operation_class.get_opcode() == name:
                return True
        return False
    
    def sv_wrap_function(self,function_args):
        return f"{self.get_arg_package()}::{self.get_wrap_function_name()}({', '.join(function_args)})"




'''
class lcisc_multi_operation_porgramable_component(lcisc_porgramable_component):

    def __init__(self):
        super.__init__()
        lcisc_porgramable_component.__init__(self)

    def get_operations(self):#list of operation pointers
        raise NotImplementedError
    def get_wrap_function_name(self): #string
        raise NotImplementedError
    #link the operation and the current stage to the 
    def bind_operation(self,operation_class):
        if(isinstance(operation_class,no_opp)):
            operation_class.set_pipe_stage(self)
            operation_class.set_operation(no_opp_response())
            return True
        operation_and_names = [(op.name,op) for op in self.get_operations()]
        for name,op in operation_and_names:
            if operation_class.get_opcode() == name:
                operation_class.set_operation(op)
                operation_class.set_pipe_stage(self)
                return True
        return False

    def check_valid_operation(self,operation_class):

        if(isinstance(operation_class,no_opp)):
            return True 
        operation_and_names = [(op.name,op) for op in self.get_operations()]
        for name,op in operation_and_names:
            if operation_class.get_opcode() == name:
                return True
        return False
'''
'''
class lcsic_single_operation_programable_component(lcisc_porgramable_component):
    def get_opcode_function_name(self):
        raise NotImplementedError 
    def get_operation_class(self):
        raise NotImplementedError
    def bind_operation(self,operation_class):
        if(isinstance(operation_class,no_opp)):
            operation_class.set_pipe_stage(self)
        operation_class.set_operation(self.get_operation_class())
        operation_class.set_pipe_stage(self)
    def check_valid_operation(self,operation_class):
        return True
'''
'''
steps for caculating the programing object

find the largest sections
recures to find a list of all components

use that list to find the differnt pacakges and arg_structs needed

the definition
import packages

make one encoding function and stucture that is very large

create the many decoding functions that are required

this allows us to create the definition file


'''