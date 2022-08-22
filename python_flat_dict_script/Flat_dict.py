'''
Author : Vikrant Subhash Yedave
Script Name : Flat_dict.py
Script task : To pass the input as dictionary and Key and retieve the Value

'''

import flatdict

## The purpose of this function is to convert the nested dictionary object to a flat Dictionary
## This function will take the input as nested dictionary object and pass the key to retrieve the Value
## if the function gets invalid object then the function will exit

def convert_To_Flat_Object(data, key):
    object1=data
    print (type(object1))
    key=key
    if (isinstance(object1, dict)):
        
        flat_object = flatdict.FlatDict(object1,delimiter='/')
        print (flat_object[key])
        
        
    else:
        print("Object1 is not a dictionary")
        exit
    
 
#data = {"x" : {"y" : {"z" : {"p" : {"q" : "r"}}}}}
#Key = "x/y/z/p/q"

data = [1,2,3]
key = 1

convert_To_Flat_Object(data, key)


