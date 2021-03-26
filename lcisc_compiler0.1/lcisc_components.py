
from lcisc_comp_properties import lcisc_conector,lcisc_declarer,lcisc_definer,lcisc_pipe_component,lcisc_pipe_template,lcisc_porgramable_component,lcisc_file_base

from pysv import module_declaration_py_sv_base,conection_py_sv,module_definition_py_sv_base,package_definition_py_sv_base,array_conection_py_sv
import library_index
import json
import re
import pandas as pd
def mk_valid_json(non_valid_json):
    while(len(non_valid_json) > len(non_valid_json.replace("  "," "))):
        non_valid_json = non_valid_json.replace("  "," ")
    return non_valid_json
class lcisc_obj_comp_base:
    def __init__(self,parent_design,content):


        self.design = parent_design
        if(isinstance(content,dict)):
            self.name = content["name"]
            del content["name"]
            self.content = content
        else:

            content = content.replace("\n"," ").replace("\t"," ").replace("{"," { ").replace("}", " } ").replace(":"," : ").replace("["," [ ").replace("]"," ] ").replace(","," , ")

            while(len(content) > len(content.replace("  "," "))):
                content = content.replace("  "," ")
            content = self.design.replace_keywords(content)
            self.name = content.split(" ")[1]

            if(content.split(" ")[2] != "{"):
                raise(LCISC_COMPILE_ERROR(f"unknown syntax {content}"))
            
            while(len(content)>0 and content[0] != "{"):
                content = content[1::]
            if(len(content)<=0):
                raise(LCISC_COMPILE_ERROR(f"missing bracket syntax {content}"))
            #
            try:
                self.content = json.loads(mk_valid_json(content))
            except Exception as e:
                print(mk_valid_json(content))
                raise e
    def __str__(self):
        return self.name + str(self.content)

class lcisc_statement_base():
    def __init__(self,parent_design,data_string):
        self.design = parent_design
        data_string = data_string.replace(";","")
        self.name = data_string.split(" ")[1]
        self.arg_string = data_string.split(" ")[1:]

user_values_defualts = {
    "sharedLength":16,
    "dataLength":16,
    "threadLength":48,
    "flagCount":8,
    "program_instruction_size": 1024,
    "ContextThreadLength":255,
    "DataStorageLength":255
} 

class user_values(lcisc_obj_comp_base,lcisc_definer,package_definition_py_sv_base):
    def __init__(self, parent_design, content):
        lcisc_obj_comp_base.__init__(self,parent_design, content)

        self.path = self.content["path"]

        self.user_values_dict = {}
        for name,default_value in user_values_defualts.items():
            self.user_values_dict[name] = self.content.get(name,default_value)

        
    def file_name(self):
        return self.path
    def package_name(self):
        return "UserValues"
    def imports_list(self):
        return []
    def internal_sv_string(self):
        end = ""

        
        for name,value in self.user_values_dict.items():
            end += f"parameter {name}  = {value};\n"
        

        return end
    def sub_packages(self):
        return []
    
    def definitions(self):
        return [self]


class lib_folder(lcisc_obj_comp_base):
    def __init__(self,parent_design,content):
        lcisc_obj_comp_base.__init__(self,parent_design,content)
        
        try:
            self.index = library_index.library(self.content["path"])
            self.path = self.content["path"]
        except ValueError:
            raise LCISC_COMPILE_ERROR(f"missing path syntax {content}")
        except FileNotFoundError:
            raise LCISC_COMPILE_ERROR(f"can't find {self.content['path']} {content}")
        
    def matching(self,func):
        return self.index.matching(func)

class operation(lcisc_obj_comp_base):
    def __init__(self,parent_design,content):
        lcisc_obj_comp_base.__init__(self,parent_design,content)

        try:
            self.package = self.content["package"]
        except ValueError:
            raise LCISC_COMPILE_ERROR(f"missing package syntax {content}")
        
        self.internal_name = self.package[0].lower() + self.package[1:]
    def operation_name(self):
        return f"{self.package}"
    def operation_function(self):
        return f"{self.internal_name}_f"
    def operation_args(self):
        return f"{self.internal_name}_a"
    def operation_opcode(self):
        return f"{self.internal_name}_o"
    def sv_wrap_function(self,sv_string):
        return f"{self.operation_name()}::{self.operation_opcode()}({sv_string})"
    

    


class pipe_state_decleration(lcisc_pipe_component,module_declaration_py_sv_base,lcisc_porgramable_component):
    def __init__(self,name,pipe_stage_definition):
        super().__init__()
        module_declaration_py_sv_base.__init__(self)
        lcisc_porgramable_component.__init__(self)
        self.pipe_stage_definition = pipe_stage_definition
        self.name = name
        
    def in_port(self,name = None): #return half a connection object
        return conection_py_sv(
            mod1 = self.name,
            port1 = "inState",
            wire_type = "pipeline_pass_structure"
        )
    def out_port(self):#return half a connection object
        return conection_py_sv(
            mod1 = self.name,
            port1 = "outState",
            wire_type = "pipeline_pass_structure"
        )
    def modifyable(self):#can this object take on aditional functions
        return False
    def get_declarations(self): #return a set of declrations for self
        return [self]
    def get_connections(self): #return a set for connections for self
        return []
    def get_sv_module_name(self):
        return self.pipe_stage_definition.get_sv_module_name()
    def port_exists(self,name):
        return name in self.pipe_stage_definition.port_list()
    def port_type(self,name):
        return self.pipe_stage_definition.port_types()[self.pipe_stage_definition.port_list().index(name)]
    def get_name(self):
        return self.name
    def get_stage_names(self):
        return [self.name]
    # lcisc_porgramable_component

    def get_instuction_name(self):
        return self.name
    def get_pipestage_arg_struct(self):
        return self.pipe_stage_definition.pipe_stage_operation_union_struct_name()
    def get_arg_package(self):
        return self.pipe_stage_definition.pipe_stage_package_name()
    def get_operations(self):
        return self.pipe_stage_definition.operations
    def get_wrap_function_name(self):
        return "wrap"

    #how will the module access the function
    def is_indexed_function(self):#will you be accessing with an index number
        return True
    def get_index_parameter_name(self):#need to tell you your number
        return self.pipe_stage_definition.pipe_stage_index_paramater_name()
    def get_access_function_name(self):#I will make a function with this name for you
        return self.pipe_stage_definition.get_access_function_name()
    def get_access_function_package(self):# it will be put in a package with this name
        return self.pipe_stage_definition.get_access_function_package()
    def sv_wrap(self,sv_string):
        return f"{self.get_arg_package()}::{self.get_wrap_function_name()}({sv_string})"
    
    def set_index_number(self,i):
        lcisc_porgramable_component.set_index_number(self,i)
        self.add_parameter(self.get_index_parameter_name(),str(i))




class pipe_stage_package(package_definition_py_sv_base):
    def __init__(self,pipe_stage):
        self.pipe_stage = pipe_stage
        pass
    def file_name(self):
        return self.pipe_stage.path +"/"+self.package_name()+".sv"
    def package_name(self):
        return f"{self.pipe_stage.name}_pkg"
    def imports_list(self):
        return self.pipe_stage.imports()
    def internal_sv_string(self):
        end = ""

        end += "typedef enum {\n"
        for e in self.pipe_stage.enums()[:-1:]:
            end += f"\t{e},\n"
        end += f"\t{self.pipe_stage.enums()[-1]}\n"
        end += f"{'}'} {self.pipe_stage.name}_operation_t;\n"
        

        # find min size section
        #end += "let max(a,b) = (a > b) ? a : b;\n"


        address_space_max_string = "max(0,0)"
        for op in [op for op in self.pipe_stage.operations]:
            address_space_max_string = f"max({address_space_max_string},$bits({op.package}::{op.operation_args()}))"
        address_space_max_string = 70
        end += f"parameter addressSpace = {address_space_max_string};\n"

        for op in [op for op in self.pipe_stage.operations]:
            end += f"typedef struct packed {'{'}logic [addressSpace - $bits({op.package}::{op.operation_args()})-1:0] dead; {op.package}::{op.operation_args()} args;{'}'} {op.operation_name()}_s;\n"

        #operation union
        end += "typedef union packed {\n\tlogic [addressSpace-1:0] all;\n"

        for local_name,operation_obj in [(op.name,op) for op in self.pipe_stage.operations]:
            end += f"\t{operation_obj.operation_name()}_s {local_name};\n"
    
        end +=f"{'}'} {self.pipe_stage.name}_operation_union;\n"
        
        end += f"typedef struct packed {'{'}\n"
        end += f"\t{self.pipe_stage.name}_operation_t operation_code;\n"
        end += f"\t{self.pipe_stage.name}_operation_union operation_args;\n"
        end += f"{'}'} {self.pipe_stage.name}_operation;\n"

        end += f"function {self.pipe_stage.name}_operation wrap({self.pipe_stage.name}_operation_t  opcode, {self.pipe_stage.name}_operation_union operationData);\n"
        end += f"\twrap.operation_code = opcode;\n"
        end += f"\twrap.operation_args.all = 0;\n"
        end += f"\twrap.operation_args = operationData;\n"
        end += f"endfunction;\n"

        end += f"parameter StageSize = $bits({self.pipe_stage.name}_operation);\n"


        end += f"function exe_env_s {self.pipe_stage.name}_process(input {self.pipe_stage.name}_operation stage_operation,input exe_env_s exInState,input thread_id_t thread_id);\n"
        end += f"case (stage_operation.operation_code)\n"
        for local_name,operation_obj in [(op.name,op) for op in self.pipe_stage.operations]:
            end += f"\t{local_name}\t: begin \n"
            end += f"\t\t{self.pipe_stage.name}_process = {operation_obj.package}::{operation_obj.operation_function()}(exInState,stage_operation.operation_args.{local_name}.args);\n"
            end += f"\t\t\t{self.pipe_stage.design.logger_package}::log_operation_call(thread_id,\"{local_name}\",$sformatf(\"%p\",stage_operation.operation_args.{local_name}.args)); "
            end += f"end\n"
        end += f"\t{self.pipe_stage.name}_pkg::no_opp\t: {self.pipe_stage.name}_process = exInState;\n"
        end += f"\tdefault : {self.pipe_stage.name}_process = exInState;\n"
        end += f"endcase;\n"
        end += f"endfunction;\n"
        return end
    def sub_packages(self):
        return []

class pipe_stage_module(module_definition_py_sv_base):
    def __init__(self,pipe_stage):
        super().__init__()
        self.pipe_stage = pipe_stage
    def file_name(self):
        return self.pipe_stage.path +"/"+ self.get_sv_module_name()+".sv"
    def get_sv_module_name(self):
        return self.pipe_stage.get_sv_module_name()
    def get_port_names(self):
        return self.pipe_stage.port_list()
    def get_port_types(self):
        return self.pipe_stage.port_types()
    def get_port_direction(self):
        return self.pipe_stage.port_direction()
    def get_parameters_names(self):
        return self.pipe_stage.parameter_names()
    def get_parameters_values(self):
        return self.pipe_stage.parameter_values()
    def imports(self):
        #standard imports the custom one for the package and the one for the decoder
        return self.pipe_stage.imports() + [f"{self.pipe_stage.name}_pkg"] + [self.pipe_stage.get_access_function_package()]
    def internal_sv_string(self):
        end = ""

        end += f"//variables that hold the execution eviroment not including the system register \n"
        end += f"exe_env_s exInState;\n"
        end += f"exe_env_s nextState;\n"
        end += f"{self.pipe_stage.name}_pkg::{self.pipe_stage.name}_operation stage_operation;\n"
        
        end += f"always_ff @(posedge clk) begin\n"
        
        end += f"if(rst==0 && inState.system.active_thread == 1) begin\n"

        #end += f"exInState.thread = inState.thread;\n"
        #end += f"exInState.data = inState.data;\n"
        #end += f"exInState.shared = inState.shared;\n"
        end += f"exInState = get_execution_environment(inState);\n"

        #end += f"stage_operation = exInState.thread.opcodes[0+addressStart:{self.pipe_stage.name}_pkg::StageSize-1+addressStart];\n"
        end += f"stage_operation = {self.pipe_stage.get_access_function_name()}({self.pipe_stage.pipe_stage_index_paramater_name()},inState);\n"


        end += f"nextState = {self.pipe_stage.name}_pkg::{self.pipe_stage.name}_process(stage_operation,exInState,inState.system.id);\n"
        
        
        #end += f"outState.thread <= #CQ nextState.thread;\n"
        #end += f"outState.data <= #CQ nextState.data;\n"
        #end += f"outState.shared <= #CQ nextState.shared;\n"
        #end += f"outState.system <= #CQ inState.system;\n"
        end += f"outState <= #CQ set_execution_environment(inState,nextState);\n"
        end += f"end else begin\n"
        end += f"outState <= #CQ 0;\n"
        end += f"end\n"
        end += f"end\n"


        return end

class pipe_stage_definition(lcisc_obj_comp_base,lcisc_definer,lcisc_pipe_template,lcisc_file_base):
    def __init__(self,parent_design,content):
        super().__init__(parent_design,content)
        lcisc_obj_comp_base.__init__(self,parent_design,content)
        try:
            self.operations = [self.design.get_component(o) for o in self.content["operations"]]

        except ValueError:
            raise LCISC_COMPILE_ERROR(f"missing operations syntax {content}")
        
        try:
            self.path = self.content["path"]
        except ValueError:
            raise LCISC_COMPILE_ERROR(f"missing path syntax {content}")

        self.mod_def = pipe_stage_module(self)
        self.pkg_def = pipe_stage_package(self)
    
    #--lcisc_file_base
    def file_path(self):
        return self.path+"/"+ self.get_sv_module_name()+".sv"
    #--lcisc_definer--
    def definitions(self):
        return [self.mod_def,self.pkg_def]

    #--lcisc_pipe_template--
    def make_copy(self,name):
        return pipe_state_decleration(name,self)
    def in_port(self, name): #return half a connection object
        return conection_py_sv(
            mod1 = name,
            port1 = "inState",
            wire_type = "pipeline_pass_structure"
        )
    def out_port(self, name):#return half a connection object
        return conection_py_sv(
            mod1 = name,
            port1 = "outState",
            wire_type = "pipeline_pass_structure"
        )
    
    def get_sv_module_name(self):
        return self.name
    def port_list(self):
        return ["inState","outState","clk","rst"]
    def port_types(self):
        return ["pipeline_pass_structure","pipeline_pass_structure","logic","logic"]
    def port_direction(self):
        return ["input","output","input","input"]
    def parameter_names(self):
        return ["program_index"]
    def parameter_values(self):
        return ["0"]
    
    def pipe_stage_operation_union_struct_name(self):
        return f"{self.name}_operation"
    def pipe_stage_package_name(self):
        return f"{self.name}_pkg"
    def pipe_stage_index_paramater_name(self):
        return f"program_index"
    def get_access_function_name(self):
        return f"{self.name}_access_func"
    def get_access_function_package(self):
        return f"universal_access_function_pkg"
    def imports(self):
        #find the things that need to be imported
        #one per operation
        #plus on env
        return [self.design.env]
    def enums(self):
        #no_opp + one for each of the operations included
        return [op.name for op in self.operations] + ["no_opp"]

'''
    def create_file_string(self):
        end = ""
        #imports
        for i in self.imports():
            end += f"import {i}::*;\n"
        
        end += f"package {self.name}_pkg;\n"

        end += "typedef enum {\n"
        for e in self.enums()[:-1:]:
            end += f"\t{e},\n"
        end += f"\t{self.enums()[-1]}\n"
        end += f"{'}'} {self.name}_operation_t;\n"
        

        # find min size section
        end += "let max(a,b) = (a > b) ? a : b;\n"

        end += "address_space = max(0,0);\n"
        for op in [self.design.look_up_operation(op) for op in self.operations]:
            end += f"address_space = max(address_space,$bits({op.package}::{op.operation_args()}));\n"
        

        for op in [self.design.look_up_operation(op) for op in self.operations]:
            end += f"typedef struct packed {'{'}logic [addressSpace - $bits({op.package}::{op.operation_args()})-1:0] dead; {op.package}::{op.operation_args()} args;{'}'} {op.operation_name()}_s;\n"

        #operation union
        end += "typedef union packed {\n\tlogic [addressSpace-1:0] all;\n"

        for local_name,operation_obj in [(op,self.design.look_up_operation(op)) for op in self.operations]:
            end += f"\t{local_name} {op.operation_name()}_s;\n"
    
        end +=f"{'}'} {self.name}_operation_union;\n"
        
        end += f"typedef struct packed {'{'}\n"
        end += f"\t{self.name}_operation_t operation_code;\n"
        end += f"\toperation_union operation_args;\n"
        end += f"{'}'} {self.name}_operation_union;\n"

        end += f"function {self.name}_operation wrap({self.name}_operation_t  opcode, {self.name}_operation_union operationData);\n"
        end += f"\twrap.operation_code = opcode;\n"
        end += f"\twrap.operation_args.all = 0;\n"
        end += f"\twrap.operation_args = operationData;\n"
        end += f"endfunction;\n"

        end += f"parameter StageSize = $bits({self.name}_operation);\n"

        #close pkg
        end += f"endpackage;\n"

        end += f"module {self.name}(\n"

        
        end += f"\tinput  pipeline_pass_structure inState,\n"
        end += f"\toutput pipeline_pass_structure outState,\n"
        end += f"\tinput logic clk,\n"
        end += f"\tinput logic rst);\n"
        end += f"parameter  addressStart = 0;\n"

        end += f"//variables that hold the execution eviroment not including the system register \n"
        end += f"ex_ev_t exInState;\n"
        end += f"ex_ev_t nextState;\n"
        
        end += f"always_ff @(posedge clk) begin\n"
        
        end += f"if(rst==0 && inState.system.active_thread == 1) begin\n"
        end += f"{self.name}_pkg::{self.name}_operation_union stage_operation;\n"
        end += f"exInState.thread = inState.thread;\n"
        end += f"exInState.data = inState.data;\n"
        end += f"exInState.shared = inState.shared;\n"
        end += f"stage_operation = exInState.thread.opcodes[0+addressStart:{self.name}_pkg::StageSize-1+addressStart];\n"
        end += f"case (stage_operation.operation_code)\n"
        for local_name,operation_obj in [(op,self.design.look_up_operation(op)) for op in self.operations]:
            end += f"\t{self.name}_pkg::{local_name}\t: nextState = {operation_obj.operation_function()}(exInState,stage_operation.operation_args.{local_name}.args);\n"
        end += f"\t{self.name}_pkg::no_opp\t: nextState = inState;\n"
        end += f"\tdefault : nextState = inState;\n"
        end += f"endcase;\n"
        
        
        end += f"outState.thread=nextState.thread;\n"
        end += f"outState.data= nextState.data;\n"
        end += f"outState.shared = nextState.shared;\n"
        end += f"outState.system = inState.system;\n"
        end += f"end else begin\n"
        end += f"outState <= 0;\n"
        end += f"end\n"
        end += f"end\n"
        end += f"endmodule;\n"

        return end
    '''
    


class lcisc_sv_module_comp(lcisc_obj_comp_base,lcisc_declarer,module_declaration_py_sv_base,lcisc_file_base):
    def __init__(self,parent_design,content):
        super().__init__(parent_design,content)
        lcisc_declarer.__init__(self)
        module_declaration_py_sv_base.__init__(self)
        self.lib_folder = self.content.get("lib",None)
        self.sv_module_name = self.content["module"]
        self.path = self.content.get("path",None)

        #see if you can find the file that you are looking for
        possible_results = []
        for lib in self.design.get_libraries():
            if(self.lib_folder == None or self.lib_folder == lib.name):
                if(self.path == None):
                    possible_results = possible_results + lib.matching(lambda x: x.has_module(self.sv_module_name))
                else:
                    possible_results = possible_results + lib.matching(lambda x: x.has_module(self.sv_module_name) and x.match_path( lib.path+"/"+ self.path))

        if(len(possible_results)>1):
            raise LCISC_MULTIPLE_FILE_ERROR(f"found multiple files with module {self.sv_module_name}")
        elif(len(possible_results) < 1):
            raise LCISC_MISSING_FILE_ERROR(f"can't find files with module {self.sv_module_name}")
        
        self.module = possible_results[0].get_module(self.sv_module_name)
        self.path = possible_results[0].path
    #lcisc_file_base

    def file_path(self):
        return self.path

    #lcisc_definer
    def declarations(self):
        return [self]
    #module_declaration_py_sv_base
    def get_name(self):
        return self.name
    def get_sv_module_name(self):
        return self.sv_module_name
    def port_exists(self,name):
        return self.module.port_exists(name)
    def port_type(self,name):
        return self.module.port_type(name)




class dispatch(lcisc_sv_module_comp,lcisc_pipe_component,lcisc_porgramable_component,lcisc_definer):
    def __init__(self,parent_design,content):
        super().__init__(parent_design,content)
        lcisc_porgramable_component.__init__(self)
        self.internal_function = self.design.get_component(self.content["stage"])
        self.stage_function_name = self.content["stage_function_name"]
        # self.internal_pipe_stage_ports = self.content["internalconection"]
        # self.dispatch_cons = [
        # conection_py_sv(
        #                     mod1=self.name,
        #                     port1=self.internal_pipe_stage_ports[0],
        #                     wire_name="dispatch_inin_state",
        #                 ).combind(self.internal_pipe_line.in_port()),
        # conection_py_sv(
        #                     mod1=self.name,
        #                     port1=self.internal_pipe_stage_ports[1],
        #                     wire_name="dispatch_inout_state",
        #                 ).combind(self.internal_pipe_line.out_port())
        # ]
    # lcisc_porgramable_section -no longer a section
    # def get_sub_components(self):
    #     return [self,self.internal_pipe_line]





    

    #how will the module access the function

    #definer properites
    def definitions(self):

        class dispatch_operation_package(package_definition_py_sv_base):
            def __init__(self,internal_func,stage_function_name):
                super().__init__()
                self.internal_function = internal_func
                self.stage_function_name = stage_function_name
            def file_name(self):
                return "sv/dispatch_operation.sv"
            def package_name(self):
                return "dispatch_operation"
            def imports_list(self):
                return [self.internal_function.pipe_stage_package_name(),"EV_types"] 
            def internal_sv_string(self):
                end = ""

                end += f"typedef {self.internal_function.pipe_stage_operation_union_struct_name()} pipeStage_operation;\n"
                end += f"function exe_env_s {self.stage_function_name}(input pipeStage_operation stage_operation,input exe_env_s exInState,input thread_id_t thread_id);\n"
                end += f"\t{self.stage_function_name} = {self.internal_function.name}_process(stage_operation,exInState,thread_id)\n;"
                end += f"endfunction;\n"
                return end
            def sub_packages(self):
                return []
        return [dispatch_operation_package(self.internal_function,self.stage_function_name)]


    #lcisc_programable_component
    def get_instuction_name(self):
        return self.name
    def get_pipestage_arg_struct(self):
        return self.internal_function.pipe_stage_operation_union_struct_name()
    def get_arg_package(self):
        return self.internal_function.pipe_stage_package_name()
    def get_operations(self):
        return self.internal_function.operations
    def get_access_function_package(self):# it will be put in a package with this name
        return f"dispatch_access_pkg"

    def get_wrap_function_name(self):
        return "wrap"

    #how will the module access the function
    def is_indexed_function(self):#will you be accessing with an index number
        return False
    def get_index_parameter_name(self):#need to tell you your number
        return None
    def get_access_function_name(self):#I will make a function with this name for you
        return f"dispatch_access_function"

    def sv_wrap(self,sv_string):
        return f"{self.get_arg_package()}::{self.get_wrap_function_name()}({sv_string})"

    #lcisc_conector no longer a conection
    # def connections(self):#return connection between the internal stage
    #     return self.dispatch_cons+self.internal_pipe_line.get_connections()
    
    #override no longer have a second component
    # def declarations(self):
    #     return [self] + self.internal_pipe_line.get_declarations()
    
    #--lcisc_pipe_component
    def in_port(self,name = None): #return half a connection object
        try:
            return conection_py_sv(
                mod1 = self.name,
                port1 = self.content["inState"],
                wire_type = self.port_type(self.content["inState"])
            )
        except Exception as E:
            print("can't find inport for {self.name}")
            raise E
            
    def out_port(self,name = None):#return half a connection object
        try:
            return conection_py_sv(
                mod1 = self.name,
                port1 = self.content["outState"],
                wire_type = self.port_type(self.content["outState"])
            )
        except Exception as E:
            print("can't find outport for {self.name}")
            raise E
            
    def modifyable(self):#can this object be renamed and edited by pipeline
        return False
    def get_declarations(self): #return a set of declrations for self
        return []
    def get_connections(self): #return a set for connections for self
        return []
    def get_pipe_components(self):
        return [self]
    def get_stage_names(self):
        return [self.name]
    def get_pipe_connections(self):
        return []


class disposition(lcisc_sv_module_comp,lcisc_pipe_component,lcisc_porgramable_component):
    def __init__(self,parent_design,content):
        super().__init__(parent_design,content)
        lcisc_porgramable_component.__init__(self)
    #--lcisc_pipe_component
    def in_port(self,name = None): #return half a connection object
        try:
            return conection_py_sv(
                mod1 = self.name,
                port1 = self.content["inState"],
                wire_type = self.port_type(self.content["inState"])
            )
        except Exception as E:
            print("can't find inport for {self.name}")
            raise E
            
    def out_port(self,name = None):#return half a connection object
        try:
            return conection_py_sv(
                mod1 = self.name,
                port1 = self.content["outState"],
                wire_type = self.port_type(self.content["outState"])
            )
        except Exception as E:
            print("can't find outport for {self.name}")
            raise E
    def modifyable(self):#can this object take on aditional functions
        return False
    def get_declarations(self): #return a set of declrations for self
        return []
    def get_connections(self): #return a set for connections for self
        return []
    def get_pipe_components(self):
        return [self]
    def get_stage_names(self):
        return [self.name]
    def get_pipe_connections(self):
        return []

    # lcisc_porgramable_component
    def get_instuction_name(self):
        return self.name
    def get_pipestage_arg_struct(self):
        return "disposition_operation"
    def get_arg_package(self):
        return "Disposition_pkg"
    def get_operations(self):
        return [self.design.get_component(self.content["operation"])]
    def get_access_function_package(self):# it will be put in a package with this name
        return "disposition_access_function_pkg"
    #how will the module access the function
    def is_indexed_function(self):#will you be accessing with an index number
        return False
    def get_index_parameter_name(self):#need to tell you your number
        return None
    def get_access_function_name(self):#I will make a function with this name for you
        return "dispostion_access_function"

    #lcisc_multi_operation_porgramable_component
    def get_wrap_function_name(self):
        return "wrap"
    def get_operations(self):
        
        return [self.design.get_component(self.content["operation"])]


class datainterface(lcisc_sv_module_comp):
    def __init__(self,parent_design,content):
        super().__init__(parent_design,content)
    
class scheduler(lcisc_sv_module_comp):
    def __init__(self,parent_design,content):
        super().__init__(parent_design,content)
class contextcache(lcisc_sv_module_comp):
    def __init__(self,parent_design,content):
        super().__init__(parent_design,content)
class organizationunit(lcisc_sv_module_comp,lcisc_pipe_component,lcisc_porgramable_component):
    def __init__(self,parent_design,content):
        super().__init__(parent_design,content)
class organizationunit_prog(lcisc_sv_module_comp,lcisc_pipe_component,lcisc_porgramable_component):
    def __init__(self,parent_design,content):
        super().__init__(parent_design,content)
    
    def in_port(self,name = None): #return half a connection object
        raise NotImplementedError()
            
    def out_port(self,name = None):#return half a connection object
        try:
            return conection_py_sv(
                mod1 = self.name,
                port1 = self.content["outState"],
                wire_type = self.port_type(self.content["outState"])
            )
        except Exception as E:
            print("can't find outport for {self.name}")
            raise E
    def modifyable(self):#can this object take on aditional functions
        return False
    def get_declarations(self): #return a set of declrations for self
        return []
    def get_connections(self): #return a set for connections for self
        return []
    def get_pipe_components(self):
        return [self]
    def get_stage_names(self):
        return [self.name]
    def get_pipe_connections(self):
        return []

    # lcisc_porgramable_component
    def get_instuction_name(self):
        return self.name
    def get_pipestage_arg_struct(self):
        return "orgunit_operation"
    def get_arg_package(self):
        return "OrgUnit_pkg"
    def get_operations(self):
        return [self.design.get_component(self.content["operation"])]
    def get_access_function_package(self):# it will be put in a package with this name
        return "orgunit_access_function_pkg"
    #how will the module access the function
    def is_indexed_function(self):#will you be accessing with an index number
        return False
    def get_index_parameter_name(self):#need to tell you your number
        return None
    def get_access_function_name(self):#I will make a function with this name for you
        return "org_unit_access_function"

    #lcisc_multi_operation_porgramable_component
    def get_wrap_function_name(self):
        return "wrap"
    def get_operations(self):
        
        return [self.design.get_component(self.content["operation"])]

class interface(lcisc_obj_comp_base,lcisc_conector):
    def __init__(self,parent_design,content):
        super().__init__(parent_design,content)
        lcisc_obj_comp_base.__init__(self,parent_design,content)
        lcisc_conector.__init__(self)
        self.components = self.content["components"]
        self.local_names = self.content["names"]
        try:
            self.connection_matrix = self.content["connections"]
            for comp_index in range(len(self.components)):
                for name_index in range(len(self.local_names)):
                    if(self.connection_matrix[comp_index][name_index] == None):
                        self.connection_matrix[comp_index][name_index] = self.local_names[name_index]
        except:
            self.connection_matrix = [self.local_names for _ in self.components]
        try:
            self.types = self.content["types"] + [None for i in range(len(self.local_names)-len(self.content["types"]))]
        except:
            self.types = [None for _ in self.local_names]
        #self.solve_types()
    
    def connections(self):
        end = []
        
        for name_index in range(len(self.local_names)):
            for comp_index in range(len(self.components)):
                end.append(
                    conection_py_sv(
                        wire_name = self.local_names[name_index],
                        mod1 = self.components[comp_index],
                        port1  = self.connection_matrix[comp_index][name_index],
                        wire_type = self.types[name_index]
                    )
                )
        return end
    '''
    def fill_connections(self,cfunc):
        for name_index in range(len(self.local_names)):
            for comp_index in range(len(self.components)):

                cfunc(self.components[comp_index],self.connection_matrix[comp_index][name_index],self.local_names[name_index])


    def validate_connections(self):
        #find the types for the local names
        for name_index in range(len(self.local_names)):
            con_type = []
            for comp_index in range(len(self.components)):
                comp = self.design.get_component(self.components[comp_index])
                #dose the requested port exist in the module

                if(not comp.port_exists(self.connection_matrix[comp_index][name_index])):
                    raise LCISC_MISSING_PORT_ERROR(f"cant find port {self.connection_matrix[comp_index][name_index]} in {self.components[comp_index]}")
                #what type is the requested connection
                con_type.append(comp.port_type(self.connection_matrix[comp_index][name_index]))
            #are all the ports the same types
            if(len(set(con_type)) != 1):
                raise LCISC_UNCLEAR_TYPE_ERROR(f"connection {self.local_names[name_index]} has multiple types {con_type}")
        return True
    #fill in type array with the first coponent type
    def sv_string(self):
        end = ""
        for con_type,con_name in zip(self.types,self.local_names):
            end += f"{con_type} {con_name};\n"
        return end
    '''

class lcisc_sv_module_comp(lcisc_obj_comp_base):
    def __init__(self,parent_design,content):
        lcisc_obj_comp_base.__init__(self,parent_design,content)
        self.lib_folder = self.content.get("lib",None)
        self.sv_module_name = self.content["module"]
        self.path = self.content.get("path",None)

        #see if you can find the file that you are looking for
        possible_results = []
        for lib in self.design.get_libraries():
            if(self.lib_folder == None or self.lib_folder == lib.name):
                if(self.path == None):
                    possible_results = possible_results + lib.matching(lambda x: x.has_module(self.sv_module_name))
                else:
                    possible_results = possible_results + lib.matching(lambda x: x.has_module(self.sv_module_name) and x.match_path( lib.path+"/"+ self.path))

        if(len(possible_results)>1):
           raise LCISC_MULTIPLE_FILE_ERROR(f"found multiple files with module {self.sv_module_name}")
        elif(len(possible_results) < 1):
            raise LCISC_MISSING_FILE_ERROR(f"can't find files with module {self.sv_module_name}")
        
        self.module = possible_results[0].get_module(self.sv_module_name)
    def get_name(self):
        return self.name
    def get_sv_module_name(self):
        return self.sv_module_name
    def port_exists(self,name):
        return self.module.port_exists(name)
    def port_type(self,name):
        return self.module.port_type(name)





class pipeline(lcisc_obj_comp_base,lcisc_pipe_component):

    def __init__(self,parent_design,content):
        super().__init__(parent_design,content)
        lcisc_obj_comp_base.__init__(self,parent_design,content)
        self.stages = self.content["stages"]
        #figure out section names of my modules
        try:
            self.names = self.content["names"]
        except:
            self.names = [f"{self.name}_{s}" for s in range(len(self.stages))]
        #figure out all of my modules and their full names at my level
        self.stage_objs = []
        self.stage_names = []
        self.name_table = {}
        for section_name,stage_object in zip(self.names,[self.design.get_component(name) for name in self.content["stages"]]):
            if(isinstance(stage_object,lcisc_pipe_template)):
                #if this is a template it will be compied with the stage name later
                self.stage_objs.append(stage_object)
                self.stage_names.append(section_name)
            else:

                for sub_stage,sub_stage_name in zip(stage_object.get_pipe_components(),stage_object.get_stage_names()):
                    self.stage_objs.append(sub_stage)
                    if stage_object.modifyable():
                        self.stage_names.append(section_name+sub_stage_name)
                        self.name_table[(section_name,sub_stage_name)] = section_name+sub_stage_name
                    else:
                        self.stage_names.append(sub_stage_name)
                        self.name_table[(section_name,sub_stage_name)] = sub_stage_name
        #main connections
        self.inter_connects = []
        for s in range(len(self.stage_objs)-1):
            s1 = self.stage_objs[s]
            s2 = self.stage_objs[s+1]
            s1_name = self.stage_names[s]
            s2_name = self.stage_names[s+1]
            self.inter_connects.append(s1.out_port(s1_name).combind(s2.in_port(s2_name)))
        for s in range(len(self.inter_connects)):
            self.inter_connects[s].set_wire_name("n")
        for s in range(len(self.inter_connects)):
            self.inter_connects[s] = array_conection_py_sv.from_base(self.inter_connects[s],s)

        
        
        #extra connections single ported


        #add in the extra ports from bellow and modify the names
        

        self.sub_stage_connections = []
        for section_name,stage_object in zip(self.names,[self.design.get_component(name) for name in self.content["stages"]]):
             if(isinstance(stage_object,lcisc_pipe_component)):
                for con in stage_object.get_pipe_connections():
                    self.sub_stage_connections.append(con)
                    #replace name
                    self.sub_stage_connections[-1].set_module_name_1(self.name_table[(section_name,self.sub_stage_connections[-1].get_module_name_1())])

        #create storge lists for the differnt returns
        #this way they won't be declared multiple times
        #lists of pointers for differnt stages of the compliation process
        self.declared_stage_objs = []
            #list of declarable object this object is in charge of declaring
            #should be just the pipe line section copies without the dispatch or disposition
        self.porgramable_sections = []
            #list of programable components and sections
            #this will be given to the program model to create the decoder and encoder
            #this is also used to check the program linting/syntax check
        #swich names where possible
        for stage_obj,stage_name in zip(self.stage_objs,self.stage_names):
            if(isinstance(stage_obj,lcisc_porgramable_component)):
                self.porgramable_sections.append(stage_obj)
            if(isinstance(stage_obj,lcisc_pipe_template)):
                stage_copy = stage_obj.make_copy(stage_name)
                self.declared_stage_objs.append(stage_copy)
                self.porgramable_sections.append(stage_copy)
            else:
                self.declared_stage_objs.extend(stage_obj.get_declarations())

        


       



    # lcisc_pipe_component
    def in_port(self,name = None):
        return self.declared_stage_objs[0].in_port()#the conection at the start of pipe
    def out_port(self,name = None):
        return self.declared_stage_objs[-1].out_port() #the connection at the end of pipe
    def get_declarations(self): #return a set of declrations for self
        return self.declared_stage_objs
    def get_connections(self): #return a set for connections for self
        return self.inter_connects+self.sub_stage_connections+self.get_pipe_connections()
    def get_pipe_components(self):
        return self.stage_objs
    def get_stage_names(self):
        return self.stage_names
    def modifyable(self):
        return True
    def get_pipe_connections(self):
        
        try:
            ported_connects = []
            extra_port_names = self.content["port_names"]
            extra_port_wire_names = self.content["wire_names"]

            for port_name,wire_name in zip(extra_port_names,extra_port_wire_names):
                for stage_obj,stage_name in zip(self.stage_objs,self.stage_names):
                    ported_connects.append(
                        conection_py_sv(
                            mod1=stage_name,
                            port1=port_name,
                            wire_name=wire_name,
                            wire_type=None,
                        )
                    )
            return ported_connects
        except KeyError:
            return []
    #lcisc_porgramable_section
    def get_sub_components(self):
        return self.porgramable_sections

'''
class pipeline(lcisc_obj_comp_base,lcisc_pipe_component):
    def __init__(self,parent_design,content):
        lcisc_obj_comp_base.__init__(self,parent_design,content)
        self.stages = self.content["stages"]
        try:
            self.names = self.content["names"]
        except:
            self.names = [f"{self.name}_{s}" for s in range(len(self.stages))]

        self.stage_objs = []

        for name,stage_object in zip(self.names,[self.design.get_component(name) for name in self.content["stages"]]):
            if(isinstance(stage_object,lcisc_pipe_template)):
                self.stage_objs.append(stage_object.make_copy(name))
            else:
                for sub_stage in stage_object.get_pipe_components():
                    self.stage_objs.append(sub_stage)

        self.inter_connects = []
        for s in range(len(self.stage_objs)-1):
            s1 = self.stage_objs[s]
            s2 = self.stage_objs[s+1]
            self.inter_connects.append(s1.out_port().combind(s2.in_port()))
        
        #set names of the inter_connects

        for i in range(len(self.inter_connects)):
            self.inter_connects[i].set_wire_name("n"+str(i))

        #create a set of pipeline connections
        print(self.names)
        print(self.stage_objs)

        for i in self.get_declarations():
            print(i.name)

        print(self.inter_connects)
        

    #lcisc_pipe_component
    def in_port(self):
        return self.stage_objs[0].in_port()#the conection at the start of pipe
    def out_port(self):
        return self.stage_objs[-1].out_port() #the connection at the end of pipe
    def modifyable(self):#can this object take on aditional functions
        return False#not dealing with it now
    def get_declarations(self): #return a set of declrations for self
        #get the decleration from each element
        declare = []

        for stage_num in range(len(self.stage_objs)):
            s_declared = self.stage_objs[stage_num].get_declarations()
            section_name = self.names[stage_num]
            for i in range(len(s_declared)):
                s_declared[i].name = section_name + s_declared[i].name
            declare.extend(s_declared)
        return declare
    def get_connections(self): #return a set for connections for self
        conections = []
        for s_connect,section_name in zip([s.get_connections() for s in self.stage_objs],self.names):
            for i in range(len(s_connect)):
                s_connect[i].set_module_name_1(section_name + s_connect[i].get_module_name_1)
                s_connect[i].set_module_name_2(section_name + s_connect[i].get_module_name_2)
            conections.extend(s_connect)
        return conections + self.inter_connects
    def get_pipe_components(self):
        return self.stage_objs
'''




class program_model(lcisc_obj_comp_base,lcisc_definer,package_definition_py_sv_base):
    def __init__(self,parent_design,content):
        super().__init__(parent_design,content)

        self.target_section = self.design.get_component(self.content["target_section"]).get_sub_components()


        self.pipe_sections = self.target_section
        done = False
        index = 0
        while(index < len(self.pipe_sections)):
            print(self.pipe_sections[index])
            if(isinstance(self.pipe_sections[index],lcisc_porgramable_component)):
                index = index + 1
            else:
                print("not a valid type")

        for i,obj in enumerate(self.pipe_sections):
            obj.set_index_number(i)

        #creating the list of imports

        self.imports = list(set(sum([[s.get_arg_package()] for s in self.pipe_sections if s.needs_data()],[])))

        self.imports = self.imports + [self.design.env]
        self.pipeline_pass_structure = self.design.exe_evn_sv_type
        self.thread_register = "thread_program_stuct_t"
        self.path = self.content["path"]

    def get_porgramable_pipe_stages(self):
        #lcisc_porgramable_component and needs_data
        return [i for i in self.pipe_sections if i.needs_data()]
    # -package_definition_py_sv_base
    def file_name(self):
        return self.path+"/"+"program_encoder.sv"
    def package_name(self):
        return "program_encoder"
    def imports_list(self):
        return self.imports
    def program_instruction_struct_name(self):
        return "program_instruction_struct_t"
    def program_encoder_function_name(self):
        return "program_encode"
    def internal_sv_string(self):
        end = ""


        #create the full program stucture
        #packed stuct with an entry for every step in the program

        end += f"typedef struct packed {'{'}\n\t"
        end +=    ";\n\t".join([s.declaration_sv_string() for s in self.pipe_sections if s.needs_data()])
        end += f";\n{'}'} {self.program_instruction_struct_name()};\n"

        #create the encoder function
        #from each individual chunk create merge the stuctures together

        end += f"function {self.program_instruction_struct_name()} {self.program_encoder_function_name()}(\n\t"
        end +=    ",\n\t".join([s.declaration_sv_string() for s in self.pipe_sections if s.needs_data()])
        end += f");\n"

        #inside the encoder function
        end += ";\n".join([f"{self.program_encoder_function_name()}.{s.get_instuction_name()} = {s.get_instuction_name()}" for s in self.pipe_sections if s.needs_data()])

        end += ";\nendfunction;\n"

        #create packing and depacking strucutre

        end += f"function {self.pipeline_pass_structure} pack({self.pipeline_pass_structure} inital, {self.program_instruction_struct_name()} instruction);\n"
        end += f"pack = inital;\n"
        #end += f"pack.thread.opcodes[0+{self.design.flag_count_param}:$bits({self.program_instruction_struct_name()})+{self.design.flag_count_param}] = instruction;\n"
        end += f"pack.instuctions = instruction;\n"
        end += f"endfunction;\n"

        end += f"function {self.program_instruction_struct_name()} depack({self.pipeline_pass_structure} pass_struct);\n"
        #end += f"depack = pass_struct.thread.opcodes[0+{self.design.flag_count_param}:$bits({self.program_instruction_struct_name()})+{self.design.flag_count_param}];\n"
        end += f"depack = pass_struct.instuctions;\n"
        end += f"endfunction;\n"
        
        #small thread packers
        end += f"function {self.thread_register} pack_thread({self.thread_register} inital, {self.program_instruction_struct_name()} instruction);\n"
        end += f"pack_thread = inital;\n"
        #end += f"pack_thread.opcodes[0+{self.design.flag_count_param}:$bits({self.program_instruction_struct_name()})+{self.design.flag_count_param}] = instruction;\n"
        end += f"pack_thread.instuctions = instruction;\n"
        end += f"endfunction;\n"

        end += f"function {self.program_instruction_struct_name()} depack_thread({self.thread_register} thread);\n"
        #end += f"depack_thread = thread.opcodes[0+{self.design.flag_count_param}:$bits({self.program_instruction_struct_name()})+{self.design.flag_count_param}];\n"
        end += f"depack_thread = thread.instuctions\n;"
        end += f"endfunction;\n"
       



        return end
    def sub_packages(self):
        #create individual access functions

        #hash the programable components by access funciton name
        access_func_hash = {}

        for s in self.pipe_sections:
            if(s.needs_data()):
                access_func_hash[s.get_access_function_name()] = access_func_hash.get(s.get_access_function_name(),[]) + [s]
        
        #validate indexable

        for k,v in access_func_hash.items():
            if(len(v)>1):
                if(list(set([s.is_indexed_function() for s in v])) != [True]):
                    raise Exception("there are access function request that are multiple and not indexed")
                if(len(list(set([s.get_pipestage_arg_struct() for s in v]))) != 1):
                    raise Exception("mutiple return types requested with this funciton")
                if(len(list(set([s.get_access_function_package() for s in v]))) != 1):
                    raise Exception("multiple packages requested")
        # generate access functions
        #

        package_hash = {}
        
        for access_function_name,pipe_components in access_func_hash.items():
            required_imports = [self.package_name()]
            package_name = pipe_components[0].get_access_function_package()
            required_imports = required_imports + sum([[s.get_arg_package()] for s in pipe_components],[]) + [self.design.env]
            end = ""
            end += f"function {pipe_components[0].get_pipestage_arg_struct()} {access_function_name}("
            if(pipe_components[0].is_indexed_function()):
                end += f"integer index_number,"
            end += f"{self.pipeline_pass_structure} pass_struct);\n"

            #inside function

            #depack

            end += f"{self.program_instruction_struct_name()} unpacked_instuction_data = depack(pass_struct);\n"
            

            #if index use a case statement
            if(pipe_components[0].is_indexed_function()):
                end += f"case(index_number)\n"
                for pipe_component in pipe_components:
                    end += f"{pipe_component.get_index_number()}:{access_function_name} = unpacked_instuction_data.{pipe_component.get_instuction_name()};\n"
                end += f"endcase\n"
            else:
                for pipe_component in pipe_components:
                    end += f"{access_function_name} = unpacked_instuction_data.{pipe_component.get_instuction_name()};\n"
            
            end += f"endfunction;\n"
            package_hash[package_name] = package_hash.get(package_name,[]) + [{
                "name": package_name,
                "imports" : required_imports,
                "internal_string": end
            }]
        #merge similar package names
        sub_package_objects = []
        for keys,values in package_hash.items():
            merge_string = "\n".join([v["internal_string"] for v in values])
            merge_imports = list(set(sum([v["imports"] for v in values],[])))
            sub_package_objects.append((keys,merge_imports,merge_string))
        return sub_package_objects
    # lcisc_definer
    def definitions(self):
        return [self]


    def sv_wrap_function(self,args):
        
        return f"{self.program_encoder_function_name()}({','.join(args)})"

class lcisc_external_port(lcisc_statement_base):
    def __init__(self,design,data_string):
        super().__init__(design,data_string)
        self.direction = "input"
        if("output" in self.arg_string):
            self.direction = "output"
        
# an instruction element hold program information
# a serries of commands that need to be decorded
from lcisc_program_components import register_template_base
        
class lcisc_program(lcisc_obj_comp_base,lcisc_definer,package_definition_py_sv_base):
    def __init__(self,parent_design,data_string):
        super().__init__(parent_design,data_string)
        #lcisc_obj_comp_base.__init__(parent_design,data_string)

        #find all program_instructions
        self.instructions = self.design.get_components("instruction")

        #order the inputs 
        instruction_order = list(self.content["instructions"].keys())

        #create a structre with instruction names with number

        self.executing_list = self.content["execute"]

        self.completed_instrucitons = []


        for index,instuction_name in enumerate(instruction_order):
            
            

            instruction_base = self.content["instructions"][instuction_name]["instruction"]
            try:
                arg_list = self.content["instructions"][instuction_name]["args"]
            except:
                arg_list = []
            
            for i in range(len(arg_list)):
                try:
                    int(arg_list[i])
                except:
                    try:
                        arg_list[i] = instruction_order.index(arg_list[i])
                    except:
                        raise Exception("unknown_argument")

            self.completed_instrucitons.append(
                {
                    "name":instuction_name,
                    "index":index,
                    "instruction": instruction_base,
                    "arguments": [str(a) for a in arg_list]
                }
            )
        #figure out the imports
        self.imports = []

        #self.imports = self.imports + self.design.get_component(self.design.program_model_name).imports_list()
        #self.imports = self.imports + [op.operation_name() for op in self.design.get_components("operation")]
        self.imports = self.imports + [self.design.program_pkg] + [self.design.operation_pkg] +[self.design.env]
        self.imports = self.imports + [self.design.get_component(self.design.program_model_name).package_name()]
        self.imports = self.imports + ["ContextCache_pkg"]+["DataInterface_pkg"]

        #make a dictionary for the data assignment

        self.data_modifcations = {}
        #a file with inital values
        self.data_file = self.content.get("data_file",None)
        self.encoding = self.content.get("encoding","int")
        self.data_table = None
        if(self.data_file):
            if(self.data_file.split(".")[-1] == "xlsx"):
                self.data_table = pd.read_excel(self.data_file,header=0,index_col=0,engine='openpyxl')
            elif(self.data_file.split(".")[-1] == "csv"):
                self.data_table = pd.read_csv(self.data_file,header=0,index_col=0)
        try:
            print(self.data_table.head(20))
            print(self.data_table.columns)
            print(self.data_table[0])
        except:
            pass
        for k,v in self.content.get("data",{}).items():
            if_statement_condition = k

            template = register_template_base.get_template(v["template"])

            for target_location,value in v["data_function"].items():
                loc_vecs = template.get_location(target_location)

                if(not isinstance(value,list)):
                    value = [value]
                
                values = [str(i) for i in value]

                for loc_vec,v in zip(loc_vecs,values):
                    self.data_modifcations[if_statement_condition] = self.data_modifcations.get(if_statement_condition,[]) + [{
                        "location":loc_vec,
                        "value": v
                    }]
        
                
            





    #lcisc_definer
    def definitions(self):
        return [self]

    #package_definition_py_sv_base
    def file_name(self):
        return self.content["path"] + "/" + self.name + ".sv"
    def package_name(self):
        return self.name
    def imports_list(self):
        return self.imports
    def internal_sv_string(self):
        end = ""

        #end += "".join([f"import {op.operation_name()}::{op.operation_opcode()};\n" for op in self.design.get_components("operation")])



        end += "\n".join([i.sv_string() for i in self.instructions])

        end += "\nfunction program_data program_threads();\n"
        #end += "\nprogram_threads = 0;\n"

        for instruction in self.completed_instrucitons:

            end += f"program_threads.program_threads[{instruction['index']}] = {instruction['instruction']}({','.join(instruction['arguments'])}); //{instruction['name']}\n"

        #set length
        end += f"program_threads.length = {len(self.completed_instrucitons)};\n"

        #set all threads to template
        end += f"for(int i=0;i<program_threads.length;i++) begin \n"
        end += f"program_threads.program_threads[i].status = ContextCache_pkg::template;\n"
        end += f"end \n"


        #set up the executing methods
        for exe_inc in self.executing_list:
            for ins in self.completed_instrucitons:
                if(ins["name"] == exe_inc):
                    end += f"program_threads.program_threads[{ins['index']}].status = ContextCache_pkg::work_queue;\n"

        end += "endfunction\n"

        end += f"function automatic void  data_initlize(ref data_register_union_t memory [DataStorageLength-1:0]);\n"

        #initalize data with file

        if(isinstance(self.data_table,pd.DataFrame)):
            print("loading from file")
            for col_name in self.data_table.columns:
                for row_name in range(len(self.data_table[col_name])):

                    value = self.data_table[col_name][row_name]
                    if(self.encoding == "hex"):
                        value = int(value,16)
                    if(value!=0):
                        #print("col_name:",col_name)
                        #print("row_name:",row_name)
                        #print("value:",value)
                        end += f"memory[{row_name}].u32[{col_name}] = {value};\n"

        end += f"for(int i=0;i<DataStorageLength;i++) begin\n"

        #add the data modifications

        for if_statement,changes in self.data_modifcations.items():
            end += f"if({if_statement}) begin\n"
            for change in changes:

                end += f"memory[i].u{change['location'].offset_size}[{change['location'].offset}] = {change['value']};\n"

            end += f"end\n"

        end += f"end\n"

        end += f"endfunction\n"
        return end
    def sub_packages(self):
        return []