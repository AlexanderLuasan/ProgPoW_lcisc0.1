


import re
from typing import List,Dict
import library_index
import system_verilog
import vivado
from compiler import recursive_compile

#from lcisc_program import lcisc_track_component,lcisc_track_pipeline,program_model

from lcisc_components import lib_folder,operation,pipe_stage_definition,disposition,dispatch,datainterface,scheduler,contextcache,organizationunit,interface,pipeline,program_model,lcisc_external_port,lcisc_program,organizationunit_prog,user_values,user_values_defualts
from lcisc_comp_properties import lcisc_conector,lcisc_declarer,lcisc_definer,lcisc_pipe_template,lcisc_file_base

from lcisc_program_components import instruction,data_template,global_template
from pysv import validate_connections,solve_connection_types,attach_connections
'''


class pipelineblock(program_model):
    def __init__(self,parent_design,pipeline_name):
        program_model.__init__(self,parent_design,pipeline_name)
    def unique_strucutres(self):#the value in the name to comp dict
        return list(set([v for k,v in self.name_to_comp.items()]))
    def create_sv_string_pipeline_pass_structure(self):
        return f"{self.design.exe_evn_sv_type} pipeline_inter_connects [{self.pipe_length()}:0];\n"
    def get_pipe_stages(self):
        stage_list = []
        for stage_name in self.track_names:
            l_comp = self.name_to_comp[stage_name]
            if(l_comp.need_declaration()):
                stage_list.append(pipe_stage_delcration(stage_name,l_comp))
        return stage_list
    def get_pipe_conections(self,confunc):
        #connect input to out puts using the pipeline_inter_connect

        for stage_index in range(len(self.track_names)-1):
            object_1_name = self.track_names[stage_index]
            object_2_name = self.track_names[stage_index+1]
            
            out_port = self.name_to_comp[object_1_name].out_port()
            in_port = self.name_to_comp[object_2_name].in_port()
            
            #if these are not managed by pipeline you need to use their own personal names
            if(not self.name_to_comp[object_1_name].need_declaration()):
                object_1_name = self.name_to_comp[object_1_name].get_name()
            if(not self.name_to_comp[object_2_name].need_declaration()):
                object_2_name = self.name_to_comp[object_2_name].get_name()

            confunc(
                object_1_name,out_port,
                f"pipeline_inter_connects[{stage_index}]",
                in_port, object_2_name
                )
            




        #create pipe_stage_delcration for each step in the pipeline


#returns a set of strings based on two rules
#end with a semi colon
#named object with a {}
#
'''

"""
takes the string containing the content of the .lcisc file, and creates a list
of string, each string being a global declaration
"""
def strip_comments(start_string):
    #look for a double slash
    #remove untill an enter
    end_string = ""
    in_comment = False
    block_comment = False
    while(len(start_string)>0):
        if(in_comment):
            if not block_comment:
                if(start_string[0]=="\n"):
                    in_comment = False
            else:
                if(start_string[:2] == "*/"):
                    in_comment = False
                    block_comment = False
                    start_string = start_string[2:]
                    continue
        else:
            if(start_string[:2] == "//"):
                in_comment = True
            if(start_string[:2] == "/*"):
                in_comment = True
                block_comment = True

        if(not in_comment):
            end_string = end_string + start_string[0]
        start_string = start_string[1:]
    return end_string


def extract_components(content_string: str) -> List[str]:
    #content_string = content_string.replace("\n"," ").replace("\t"," ").replace("{"," { ").replace("}", " } ").replace(":"," : ").replace("["," [ ").replace("]"," ] ").replace(","," , ")

    #while(len(content_string) > len(content_string.replace("  "," "))):
    #    content_string = content_string.replace("  "," ")
    #print(content_string)

    content_string = strip_comments(content_string)
    #print(content_string)
    components = []
    component = ""
    index = 0
    depth = 0

    while(len(content_string)>index):
        component = component + content_string[index]

        if(content_string[index] == ";"):
            if(depth < 1):
                components.append(component)
                component = ""

        elif(content_string[index] == "{"):
            depth = depth + 1
        elif(content_string[index] == "}"):
            depth = depth - 1
            if(depth < 1):
                components.append(component)
                component = ""
        
        
        index = index + 1
    components.append(component)
    return [c.strip() for c in components]

lcisc_key_words = ["path","package","operations","module","lib","names","components","connections","stage","stages","port_names","wire_names","target_section"
,"instructions","instruction","args","operation","execute","data","template","data_function","inState","outState","stage_function_name","data_file","encoding"]


lcisc_system_wires = ["clk","rst","halt","user_insert","incoming_user_thread","incoming_user_status","user_insert_id","active"]
lcisc_system_wires_out = ["active"]
lcisc_key_words.extend(lcisc_system_wires)
lcisc_key_words.extend(lcisc_system_wires_out)

lcisc_key_words.extend(list(user_values_defualts.keys()))

lcsic_types =           ["lib_folder","operation","pipe_stage","dispatch","disposition","datainterface","scheduler","contextcache","organizationunit","interface","pipeline","program_model", 
"instruction","global_template","data_template","external_port","program","organizationunit_prog","user_values"]

lcisc_constructors =    [lib_folder  , operation , pipe_stage_definition , dispatch , disposition , datainterface , scheduler , contextcache , organizationunit , interface , pipeline,program_model,
instruction,global_template,data_template,lcisc_external_port,lcisc_program,organizationunit_prog,user_values]




"""
Class that takes the path to the lcisc file, and extracts the 
"""
class lcsic_design:
    def __init__(self,path,pipe_line_name,program_module_name,program_name,cycles = 3000):
        self.env :str = "EV_types"
        self.exe_evn_sv_type :str = "pipeline_pass_structure"
        self.program_model_name = program_module_name
        self.main_pipe_line = pipe_line_name
        self.main_program_name = program_name
        self.program_pkg = "Programing"
        self.operation_pkg = "Operation_pkg"
        self.logger_package = "debuglogger"

        self.flag_count_param = "flagCount"
        self.cycles = cycles
        #what will need to be compiled
        self.required_modules = []
        #compoents is a dict of type name -> List[constructor classes]
        self.compoents = {}
        #extract the lcsic components

        
        comps = []
        with open(path,'r') as f:
            content = f.read()
            #comps = list of global declarations found in argument file
            comps = extract_components(content)

        """next, we enclose all global declarations in quotations, to make valid json"""
        for comp in comps:
            #comp = self.replace_keywords(comp)

            for key_word,constructor in zip(lcsic_types,lcisc_constructors):
                if(comp.split(" ")[0] == key_word):
                    self.compoents[key_word] = self.compoents.get(key_word,[])+[constructor(self,comp)]

        
        
        #from the components produce the sv parts
        """
        PYSV_components will now be a dict of str -> 
        """
        self.PYSV_components = {}
        for module_type in lcsic_types:
            for module in self.get_components(module_type):

                if(isinstance(module,lcisc_definer)):
                    self.PYSV_components["definition"] = self.PYSV_components.get("definition",[]) + module.definitions()
                if(isinstance(module,lcisc_declarer)):
                    self.PYSV_components["declaration"] = self.PYSV_components.get("declaration",[]) + module.declarations()
                if(isinstance(module,lcisc_conector)):
                    self.PYSV_components["connection"] = self.PYSV_components.get("connection",[]) + module.connections()
                if(isinstance(module,lcisc_file_base)):
                    self.required_modules.append(module.file_path())
        
        self.PYSV_components["declaration"].extend(self.get_component(self.main_pipe_line).get_declarations())
        self.PYSV_components["connection"].extend(self.get_component(self.main_pipe_line).get_connections())

        
        #solve the connection stuff

        print(solve_connection_types(self.PYSV_components["connection"],self.PYSV_components["declaration"]))
        a = validate_connections(self.PYSV_components["connection"],self.PYSV_components["declaration"])
        attach_connections(self.PYSV_components["connection"],self.PYSV_components["declaration"])

        for i,definition in enumerate(self.PYSV_components["definition"]):
            print(i)
            definition.write()

        


    def get_components(self,_type:str):
        return self.compoents.get(_type,[])
    def get_sv_components(self,_type):
        return self.PYSV_components.get(_type,[])
    def get_operations(self):
        return self.compoents["operation"]

    """
    takes the string representing a global declaration.
    encapsulates known keywords in the global declaration text with quotation makes,
    so the declaration is valid json
    """
    def replace_keywords(self,s):

        parts = s.split('"')
        for i in range(0,len(parts),2):

            for word in lcisc_key_words:
                parts[i] = parts[i].replace(f" {word} ",f" \"{word}\" ")

            for component_type in lcsic_types:
                for word in sorted([comp.name for comp in self.compoents.get(component_type,[])],reverse=True):
                    parts[i] = parts[i].replace(f" {word} ",f" \"{word}\" ")

            
        
        return '"'.join(parts)
    
    def look_up_operation(self,name):
        for op in self.get_operations():
            if op.name == name:
                return op

    def get_libraries(self):
        return self.compoents.get("lib_folder",[])

    def get_component(self,name):
        for component_type in lcsic_types:
            for comp in self.compoents.get(component_type,[]):
                if comp.name == name:
                    return comp

    def create_lcisc_sv_string(self):
        end = ""
        #imports

        #context_cache_package
        #data_interface_package

        end +=f"import {self.env}::*;\n"

        end +=f"import ContextCache_pkg::*;\n"
        end +=f"import DataInterface_pkg::*;\n"
        

        end += f"module LCISC (\n"

        #connection_declaration
        connection_hash = {}
        for connection in self.PYSV_components["connection"]:
            connection_hash[connection.get_wire_stucture_name()] = connection_hash.get(connection.get_wire_stucture_name(),[]) + [connection]
        
        #connections in external ports
        port_list = []
        external_port_names = lcisc_system_wires
        for con_name, con_objs in connection_hash.items():
            if(con_name in external_port_names):
                if(con_name in lcisc_system_wires_out):
                    port_list.append(f"\toutput {con_objs[0].sv_string()}")
                else:
                    port_list.append(f"\tinput {con_objs[0].sv_string()}")
        end += ",\n".join(port_list)
        end += "\n);\n"
        for con_name, con_objs in connection_hash.items():
            if(con_name not in external_port_names):
                end += f"{con_objs[0].sv_string()};\n"
        

        #module declaration
        for module in self.PYSV_components["declaration"]:
            print(f"making {module.name}")
            end += module.create_sv_string()

        #pipe_line_strucutre

        #for mod in self.pm.get_pipe_stages():
        #    end += mod[1].create_sv_string(mod[0])

        end += "\nendmodule;"

        return end
    def create_lcisc_tb_sv_string(self):
        end = ""


        end += f"import {self.program_pkg}::*;\n"
        end += f"import {self.env}::*;\n"
        end += f"import {self.main_program_name}::*;\n"
        end += f"import {self.logger_package}::*;\n"
        end +=f"import ContextCache_pkg::*;\n"
        end +=f"import DataInterface_pkg::*;\n"
        end += "module LCISC_TB;\n"
        #declare capture_names

        connection_hash = {}
        for connection in self.PYSV_components["connection"]:
            connection_hash[connection.get_wire_stucture_name()] = connection_hash.get(connection.get_wire_stucture_name(),[]) + [connection]
        


        external_port_names = lcisc_system_wires
        for con_name, con_objs in connection_hash.items():
            if(con_name in external_port_names):
                end += f" {con_objs[0].sv_string()};\n"
        
        end += f"program_data runingProgram;\n"

        end += f"LCISC DUT( \n"

        port_con_list = []
        for con_name, con_objs in connection_hash.items():
            if(con_name in external_port_names):
                port_con_list.append(f".{con_name}({con_name})")
        end += ",\n".join(port_con_list)
        end += ");\n"



        end += f"initial begin\nrst = 1;\nhalt = 1;\nuser_insert = 0;\nincoming_user_thread = 0;\n"
        end += f"incoming_user_status = ContextCache_pkg::no_thread;#10;\n"

        end += f"rst = 0;halt = 1;"

        end += f"$display(\"reset\");\n"

        end += f"clear_log();\n"

        end += f"{self.main_program_name}::data_initlize(DUT.datainterface_main.memory);\n"

        end += f"$display(\"memory set\");\n"

        end += f"inital_write_memory(DUT.datainterface_main.memory);\n"

        end += f"$display(\"inital memory written\");\n"

        end += f"runingProgram = {self.main_program_name}::program_threads();\n"

        end += f"for(int i=0;i<runingProgram.length;i++) begin\n"
        end += f"user_insert = 1;\n"
        end += f"incoming_user_status = runingProgram.program_threads[i].status;\n"
        end += f"incoming_user_thread = runingProgram.program_threads[i].thread_and_instucions;\n"
        end += f"#10;\n"
        end += f"end\n"

        
        

        end += f"incoming_user_thread = 0;\n"
        end += f"user_insert = 0;\n"

        end += f"$display(\"program written\");\n"
        end += f"halt = 0;\n"
        end += f"$display(\"program running\");\n"

        end += f"for(int i=0;i<{self.cycles*10};i+=1000) begin \n"

        end += f"$display(\"cycle %d\",i);\n"
        end += f"#1000;\n"
        end += f"end\n"

        end += f"final_write_memory(DUT.datainterface_main.memory);\n"
        end += f"$stop();\n"


        end += f"end\n"

        end += "always begin\n"
        end += "clk <= 0;#5;\n"
        end += "clk <= 1;#5;\n"
        end += "end\n"

        end += "endmodule;"


        return end

if __name__ == "__main__":
    import sys

    print(sys.argv)
    design_file = sys.argv[1]
    pipe_line = sys.argv[2]
    encoder = sys.argv[3]
    program_name = sys.argv[4]
    cycles = 3000
    try:
        cycles = int(sys.argv[5])
    except IndexError:
        pass

    a = lcsic_design(design_file,pipe_line,encoder,program_name,cycles=cycles)

    #print(a.compoents["pipeStage"][0].create_file_string())
    print()
    #print(a.get_component("datainterface_main").module.ports)
    #a.compoents["interface"][2].validate_connections()
    #print(a.compoents["interface"][2].sv_string())

    print("here")
    #print(a.get_component("l").internal_sv_string())

    #print(a.create_lcisc_sv_string())
    with open("sv/LCISC.sv",'w') as f:
        f.write(a.create_lcisc_sv_string())
    
    with open("sv/LCISC_tb.sv",'w') as f:
        f.write(a.create_lcisc_tb_sv_string())

    #recreate libraries with new files
    final_libs = []
    for lib_path in [lib.path for lib in a.get_components("lib_folder")]:
        final_libs.append(library_index.library(lib_path))

    device_file = system_verilog.system_verilog_file("sv/LCISC.sv") 
    main_file = system_verilog.system_verilog_file("sv/LCISC_tb.sv")

    #submodule_list = [system_verilog.system_verilog_file(i) for i in a.required_modules]

    #files = recursive_compile([main_file,device_file]+submodule_list,final_libs)

    #compiler.make_project_file("main.prj",files)
    #for f in files:
    #   print(f)
    #  vivado.compile_sv(f)


    #vivado.elab_sim("LCISC_TB","lcisc")

    #vivado.simulate("lcisc")
    #print([str(p) for p in a.compoents["pipeline"]])

    #pm = program_model(a,"all")

    #pm.display()