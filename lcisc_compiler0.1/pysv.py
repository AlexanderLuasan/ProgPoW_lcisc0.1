


#if you are this then you can produce a declaration
#you need to know about the types of things that you have
#ports and their types
class module_declaration_py_sv_base:
    def __init__(self):
        self.ports = {}
        self.paramaters = {}
    def get_sv_module_name(self):
        raise NotImplementedError()
    def port_exists(self,name):
        raise NotImplementedError()
    def port_type(self,name):
        raise NotImplementedError()
    def get_name(self):
        raise NotImplementedError()
    def add_port(self,port_name,wire_name):
        self.ports[port_name] = wire_name
    def add_parameter(self,param_name,sv_value_string):
        self.paramaters[param_name] = sv_value_string
    def create_sv_string(self):
        end = ""

        #start declaration
        end += f"{self.get_sv_module_name()}  \n"

        end += f"#(\n"

        end += ",\n".join([f".{name}({value})" for name,value in self.paramaters.items()])

        end += f") {self.get_name()} (\n"

        #list of connections
        end += ",\n".join([f".{name}({value})" for name,value in self.ports.items()])
       
        end += "\n);\n"
        return end
class module_declaration_py_sv(module_declaration_py_sv_base):
    def __init__(self,SV_type,name,type_port_list):
        declaration_py_sv_base.__init__(self)
        self.module_type = SV_type
        self.name = name
        self.type_port_list = type_port_list
    
    def get_sv_module_name(self):
        return self.module_type
    def port_exists(self,name):
        return name in [n for t,n in self.type_port_list]
    def port_type(self,name):
        for t,n in self.type_port_list:
            if(n == name):
                return t
        return None
    def get_name(self):
        return self.name
    

#this rebesnts a single wire connected in the system
class conection_py_sv_base:
    def __init__ (self):
        pass
    def get_wire_stucture_name(self):#this is the name of the general wire stucutre
        raise NotImplementedError()
    def get_wire_name(self): #this is the name of an individaul wire in the strucutre (will have the index info included)
        raise NotImplementedError()
    def get_module_name_1(self):
        raise NotImplementedError()
    def set_module_name_1(self,name):
        raise NotImplementedError()
    def get_module_name_2(self):
        raise NotImplementedError()
    def set_module_name_2(self,name):
        raise NotImplementedError()
    def get_port_name_1(self):
        raise NotImplementedError()
    def set_port_name_1(self,name):
        raise NotImplementedError()
    def get_port_name_2(self):
        raise NotImplementedError()
    def set_port_name_2(self,name):
        raise NotImplementedError()
    def get_type(self):
        raise NotImplementedError()
    def set_type(self,_type):
        raise NotImplementedError()
    def combind(self,other):
        if(self.get_module_name_1() == None and self.get_port_name_1() == None):
            if(other.get_module_name_1() != None and other.get_port_name_1() != None):
                self.set_module_name_1(other.get_module_name_1())
                self.set_port_name_1(other.get_port_name_1())
            elif(other.get_module_name_2() != None and other.get_port_name_2() != None):
                self.set_module_name_1(other.get_module_name_2())
                self.set_port_name_1(other.get_port_name_2())
        elif(self.get_module_name_2() == None and self.get_port_name_2() == None):
            if(other.get_module_name_1() != None and other.get_port_name_1() != None):
                self.set_module_name_2(other.get_module_name_1())
                self.set_port_name_2(other.get_port_name_1())
            elif(other.get_module_name_2() != None and other.get_port_name_2() != None):
                self.set_module_name_2(other.get_module_name_2())
                self.set_port_name_2(other.get_port_name_2())
        return self
    def sv_string(self):
        return f"{self.get_type()} {self.get_wire_name()}"

    def __str__(self):
        t = self.get_type()
        n = self.get_wire_name()

        return f"{t} {n} {self.get_module_name_1()}.{self.get_port_name_1()}->{self.get_module_name_2()}.{self.get_port_name_2()}"

#this is a producable class that uses the template
class conection_py_sv(conection_py_sv_base):
    def __init__ (self,mod1,port1,wire_name=None,mod2=None,port2=None,wire_type=None):
        conection_py_sv_base.__init__(self)
        self.wire_type = wire_type
        self.wire_name = wire_name
        self.mod1 = mod1
        self.mod2 = mod2
        self.port1 = port1
        self.port2 = port2
    def get_wire_stucture_name(self):
        return self.wire_name
    def get_wire_name(self):
        return self.wire_name
    def set_wire_name(self,name):
        self.wire_name = name
    def get_module_name_1(self):
        return self.mod1
    def set_module_name_1(self,name):
        self.mod1 = name
    def get_module_name_2(self):
        return self.mod2
    def set_module_name_2(self,name):
        self.mod2 = name
    def get_port_name_1(self):
        return self.port1
    def set_port_name_1(self,name):
        self.port1 = name
    def get_port_name_2(self):
        return self.port2
    def set_port_name_2(self,name):
        self.port2 = name
    def get_type(self):
        return self.wire_type
    def set_type(self,_type):
        self.wire_type = _type
        

class array_conection_py_sv(conection_py_sv):

    index_connection_hash = {}

    def __init__ (self,mod1,port1,index_number,wire_name=None,mod2=None,port2=None,wire_type=None):
        super().__init__(mod1,port1,wire_name,mod2,port2,wire_type)
        self.index = index_number

        array_conection_py_sv.index_connection_hash[self.wire_name] = array_conection_py_sv.index_connection_hash.get(self.wire_name,[])+[self.index]
    
    def set_index_number(self,index_number):
        self.index = index_number
    def get_index_number(self,index_number):
        return self.index_name
    def get_wire_stucture_name(self):
        return conection_py_sv.get_wire_name(self)
    def get_wire_name(self):
        return conection_py_sv.get_wire_name(self) + f"[{self.index}]"
    
    def from_base(connection,index):#makes a array connection out of a standard connection
        return array_conection_py_sv(
            mod1 = connection.get_module_name_1(),
            port1 = connection.get_port_name_1(),
            index_number = index,
            wire_name=connection.get_wire_name(),
            mod2=connection.get_module_name_2(),
            port2=connection.get_port_name_2(),
            wire_type=connection.get_type()
        )
    def sv_string(self):
        return f"{self.get_type()} {self.get_wire_stucture_name()}[{max(array_conection_py_sv.index_connection_hash[self.get_wire_stucture_name()])}:0]"


class package_definition_py_sv_base():
    def file_name(self):
        raise NotImplementedError()
    def package_name(self):
        raise NotImplementedError()
    def imports_list(self):
        raise NotImplementedError()
    def internal_sv_string(self):
        raise NotImplementedError()
    def sub_packages(self):
        raise NotImplementedError()
    def write(self):
        with open(self.file_name(),"w") as f:
            f.write(f"package {self.package_name()};\n")
            f.write("".join( [f"import {i}::*;\n" for i in self.imports_list()] ) )
            f.write(self.internal_sv_string())
            f.write(f"endpackage;\n")

            for name,imports,subpkg_string in self.sub_packages():
                f.write(f"package {name};\n")
                f.write("".join( [f"import {i}::*;\n" for i in imports] ) )
                f.write(subpkg_string)
                f.write(f"endpackage;\n")

    
class module_definition_py_sv_base():
    def __init__(self):
        pass
    def file_name(self):
        raise NotImplementedError()
    def get_sv_module_name(self):
        raise NotImplementedError()
    def get_port_names(self):
        raise NotImplementedError()
    def get_port_types(self):
        raise NotImplementedError()
    def get_port_direction(self):
        raise NotImplementedError()
    def get_parameters_names(self):
        raise NotImplementedError()
    def get_parameters_values(self):
        raise NotImplementedError()
    def internal_sv_string(self):
        raise NotImplementedError()
    def imports(self):
        raise NotImplementedError()
    def write(self):
        with open(self.file_name(),"w") as f:

            f.write("".join([f"import {i}::*;\n" for i in self.imports()]))

            f.write(f"module {self.get_sv_module_name()}(\n")

            f.write(",\n".join(
                [
                    f"{dir} {ty} {nm}"
                    for dir,ty,nm in zip(self.get_port_direction(),self.get_port_types(),self.get_port_names())
                ]
            ))
            f.write(");")

            f.write("".join([f"parameter {param} = {value};\n" for param,value in zip(self.get_parameters_names(),self.get_parameters_values())]))

            f.write(self.internal_sv_string())
            f.write(f"endmodule;\n")
    
#if a connection has a type of none 
#look at connections with same name and modules
#if stuff agrees fill it in else return the unsolveable
def solve_connection_types(list_of_connections,list_of_declared):

    invalid = []
    #hash the declared by name
    declared_hash = {}
    for dec in list_of_declared:
        declared_hash[dec.get_name()] = dec

    if(len(list(declared_hash.keys())) != len(list_of_declared)):
        print("double declare")
        
    #hash the connections by name
    connection_hash = {}
    for con in list_of_connections:
        connection_hash[con.get_wire_name()] = connection_hash.get(con.get_wire_name(),[]) + [con]

    #first possiblity the connections them selfs disagree

    for name,cons in connection_hash.items():
        wire_possible_types = list(filter(lambda x: x!=None,map(lambda x: x.get_type(),cons)))
        if(len(wire_possible_types)>1):#more than one declared type
            invalid.append(con)
        elif(len(wire_possible_types)==1):#we should set the type to all the same
            [con.set_type(wire_possible_types[0]) for con in cons]
        else:#everything is None nothing needed we need to grab a type from the connected module
            mod_type = None
            if(cons[0].get_module_name_1()!= None and cons[0].get_port_name_1() != None):
                if(declared_hash[cons[0].get_module_name_1()].port_exists(cons[0].get_port_name_1())):
                    mod_type = declared_hash[cons[0].get_module_name_1()].port_type(cons[0].get_port_name_1())
            if(cons[0].get_module_name_2()!= None and cons[0].get_port_name_2() != None):
                if(declared_hash[cons[0].get_module_name_2()].port_exists(cons[0].get_port_name_2())):
                    mod_type = declared_hash[cons[0].get_module_name_2()].port_type(cons[0].get_port_name_2())
            [con.set_type(mod_type) for con in cons]

    return invalid

        






#all connecions need to have devined ports and types and existing modules
#return the invalid
def validate_connections(list_of_connections,list_of_declared):

    #hash the declared by name
    declared_hash = {}
    for dec in list_of_declared:
        declared_hash[dec.get_name()] = dec

    if(len(list(declared_hash.keys())) != len(list_of_declared)):
        print("double declare")

    #for each connection ensure that there is a port that exists
    in_valid_ports = []

    for con in list_of_connections:
        mod_name_1 = con.get_module_name_1()
        port_name_1 = con.get_port_name_1()

        if(mod_name_1 != None and port_name_1 != None):
            if(declared_hash[mod_name_1].port_exists(port_name_1)):
                #also check type
                if(declared_hash[mod_name_1].port_type(port_name_1) != con.get_type()):
                    in_valid_ports.append(con)
            else:
                in_valid_ports.append(con)
                
        mod_name_2 = con.get_module_name_2()
        port_name_2 = con.get_port_name_2()

        if(mod_name_2 != None and port_name_2 != None):
            if(declared_hash[mod_name_2].port_exists(port_name_2)):
                if(declared_hash[mod_name_2].port_type(port_name_2) != con.get_type()):
                    in_valid_ports.append(con)
            else:
                in_valid_ports.append(con)
    
    return in_valid_ports
    

#assuming every thing is valid use the add port function to setup all the connections
def attach_connections(list_of_connections,list_of_declared):
    #hash the declared by name
    declared_hash = {}
    for dec in list_of_declared:
        declared_hash[dec.get_name()] = dec

    if(len(list(declared_hash.keys())) != len(list_of_declared)):
        print("double declare")

    for con in list_of_connections:
        wire_name = con.get_wire_name()
        mod_name_1 = con.get_module_name_1()
        port_name_1 = con.get_port_name_1()

        if(mod_name_1 != None and port_name_1 != None and wire_name != None):
            declared_hash[mod_name_1].add_port(port_name_1,wire_name)
               
                
        mod_name_2 = con.get_module_name_2()
        port_name_2 = con.get_port_name_2()

        if(mod_name_2 != None and port_name_2 != None and wire_name != None):
            declared_hash[mod_name_2].add_port(port_name_2,wire_name)

    return None
