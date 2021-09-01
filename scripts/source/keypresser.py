import json
import os
import sys

application_path = os.path.dirname(sys.executable)

class Keypresser:
    def __init__(self):
        print("");
    def key_press(self, key):
        data = {}
        with open('data.json') as json_file:
            data = json.load(json_file)
        data["type"].append(key)
        with open('data.json', 'w') as outfile:
            json.dump(data, outfile)