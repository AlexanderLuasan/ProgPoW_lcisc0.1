
import re

all_system_verilog_files = []


def remove_comments(sv_text):
    sv_text = str(sv_text)
    return re.sub(r' *\/\/.*\n?', '', sv_text)



class sv_module:
    def __init__(self,module_declaration_string):
        
        #clean string
        module_declaration_string = remove_comments(module_declaration_string)
        module_declaration_string = module_declaration_string.replace("\n"," ").replace("\t"," ").replace(")"," ) ").replace("("," ( ").replace(";","")
        while (len(module_declaration_string) > len(module_declaration_string.replace("  ", " "))):
            module_declaration_string = module_declaration_string.replace("  "," ")
        

        try:
            intro = module_declaration_string.split("(")[0]
            middle = module_declaration_string.split("(")[1].split(")")[0]

            self.name = intro.split(" ")[1]

            self.ports = []
            for port_string in middle.split(","):
                port_split = port_string.strip().split(" ")
                try:
                    self.ports.append({
                        "direction":port_split[0],
                        "sv_type":port_split[1],
                        "name":port_split[2]
                    })
                except IndexError:
                    self.ports.append({
                        "direction":port_split[0],
                        "sv_type":"logic",
                        "name":port_split[1]
                    })
        except:
            intro = module_declaration_string
            self.name = intro.split(" ")[1]
            self.ports = []
    def port_exists(self,name):
        for port in self.ports:
            if port["name"] == name:
                return True
        return False
    def port_type(self,name):
        for port in self.ports:
            if port["name"] == name:
                return port["sv_type"]


class system_verilog_file:

    def __init__(self,file_path):
        self.path = file_path
        all_system_verilog_files.append(self)

        #find the data about packages
        self.packages = []
        self.imports = []
        self.modules = {}
        with open(self.path,'r') as f:
            #locate packages
            pattern = re.compile("package .+;")
            contents = f.read()
            for match in re.finditer(pattern, contents):
                package_name = match.group().split(" ")[1]
                
                package_name = package_name.replace(";","")

                self.packages.append(package_name)

            #locate imports
            pattern = re.compile("import .+(;|::)")
            for match in re.finditer(pattern, contents):
                import_name = match.group().split(" ")[1]

                import_name = import_name.replace(";","").replace("::","").replace("*","")

                self.imports.append(import_name)
            
            pattern = re.compile("[A-Z_:a-z]*::")
            for match in re.finditer(pattern, contents):
                import_name = match.group().split("::")[0]

                import_name = import_name.replace("::","")

                self.imports.append(import_name)

            
            #locate module delclarations
            pattern = re.compile("module [^;]*;")
            for match in re.finditer(pattern, contents):
                mod = sv_module(match.group())
                self.modules[mod.name] = mod
        self.imports = list(set(self.imports))
    def __del__(self):
        all_system_verilog_files.remove(self)

    def has_module(self,mod_name):
        return mod_name in self.modules.keys()

    def match_path(self,path):
        return path == self.path

    def get_module(self,name):
        return self.modules[name]


if __name__ == "__main__":
    sv_file = system_verilog_file("sv/LCISC.sv")

    print(sv_file.packages,sv_file.imports)