

import pandas as pd
import os_util
import hex_utils 


def make_csv(dat_file,block_size,endcoding = "dec",reversed=False):
    ending_csv_lines = []
    with open(dat_file,'r') as f:
        for line in f.readlines():
            byte_list = hex_utils.hex_string_to_bytes(line.strip())
            block_list = hex_utils.byte_array_grouping(byte_list,block_size//8)

            if(endcoding == "hex"):
                block_list = [hex(i).replace("0x","") for i in block_list]

            if(reversed):
                block_list= block_list[::-1]
            
            ending_csv_lines.append(block_list)

    c_names = [i for i in range(len(ending_csv_lines[0]))]

    if(reversed):
        c_names= c_names[::-1]

    df = pd.DataFrame(ending_csv_lines,columns=c_names)
    


    return df




if __name__ == "__main__":
    inital_data = make_csv(os_util.find("inital_data.dat","./"),32)
    final_data = make_csv(os_util.find("final_data.dat","./"),32)
    print(inital_data.head())
    print(final_data.head())

    inital_data.to_excel("inital_data.xlsx")
    final_data.to_excel("final_data.xlsx")


    inital_data_hex = make_csv(os_util.find("inital_data.dat","./"),32,endcoding="hex",reversed=True)
    final_data_hex = make_csv(os_util.find("final_data.dat","./"),32,endcoding="hex",reversed=True)
    print(inital_data_hex.head())
    print(final_data_hex.head())

    inital_data_hex.to_excel("inital_data_hex.xlsx")
    final_data_hex.to_excel("final_data_hex.xlsx")