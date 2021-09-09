import json
import os
import sys

application_path = os.path.dirname(sys.executable)

class Keypresser:
    def __init__(self):
        print("");
    def key_press(self, key):
        data = {}
        try:
            with open('data.json') as json_file:
                data = json.load(json_file)
            data["type"].append(key)
        except:
            print("Something Something in Keypresser")
        try:
            with open('data.json', 'w') as outfile:
                json.dump(data, outfile)
        except:
            print("Something Something in Keypresser 2")