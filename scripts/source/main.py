#Define the imports
import twitch
import keypresser
import json
import os
import sys

application_path = os.path.dirname(sys.executable)

t = twitch.Twitch();
k = keypresser.Keypresser();

#Enter your twitch username and oauth-key below, and the app connects to twitch with the details.
#Your oauth-key can be generated at http://twitchapps.com/tmi/

#username = "wituz";
#key = "oauth:codehere";
f = open("setup.json", "r").read()
info_dict = json.loads(f)
username = info_dict["username"].strip()
key = info_dict["oauth-key"].strip()
#print("user: " + username)
#print("key: " + key)
t.twitch_connect(username, key);

#The main loop
while True:
    #Check for new mesasages
    new_messages = t.twitch_recieve_messages();

    if not new_messages:
        #No new messages...
        continue
    else:
        for message in new_messages:
            #Wuhu we got a message. Let's extract some details from it
            msg = message['message'].lower()
            username = message['username'].lower()
            print(username + " said something in chat!");

            #This is where you change the keys that shall be pressed and listened to.
            #The code below will simulate the key q if "q" is typed into twitch by someone
            #.. the same thing with "w"
            #Change this to make Twitch fit to your game!

            with open('accepted_commands.txt') as ff:
                if msg in ff.read():
                    k.key_press(msg[1:]);