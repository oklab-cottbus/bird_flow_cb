import time
import json
import getopt
import sys 
import requests
import os

def get_validate_token(email):

    apiaddress = "https://api-auth.prod.birdapp.com/api/v1/auth/email"
    headers =   {"User-Agent":"Bird/4.119.0(co.bird.Ride; build:3; iOS 14.3.0) Alamofire/5.2.2",
                "Device-Id":"0c571d30-2c0c-4cf7-8487-7dda9bc52af6",
                "Platform":"ios",
                "App-Version":"4.119.0",
                "Content-Type":"application/json"}
    
    body = {"email":email}

    print(body)
    r = requests.post(apiaddress,json=body,headers=headers)
    return(r)

def use_magiclink(token):

    apiaddress = "https://api-auth.prod.birdapp.com/api/v1/auth/magic-link/use"

    headers =   {"User-Agent":"Bird/4.119.0(co.bird.Ride; build:3; iOS 14.3.0) Alamofire/5.2.2",
                "Device-Id":"0c571d30-2c0c-4cf7-8487-7dda9bc52af6",
                "Platform":"ios",
                 "App-Version":"4.119.0",
                "Content-Type":"application/json"}

    body = {"token":token}

    r = requests.post(apiaddress,json=body,headers=headers)

    return(r)

def update_accesstoken(refresh_token):

    apiaddress = "https://api-auth.prod.birdapp.com/api/v1/auth/refresh/token"

    headers = {
            "User-Agent":"Bird/4.119.0(co.bird.Ride; build:3; iOS 14.3.0) Alamofire/5.2.2",
            "Device-Id":"0c571d30-2c0c-4cf7-8487-7dda9bc52af6",
            "Platform":"ios",
            "App-Version":"4.119.0",
            "Content-Type": "application/json",
            "Authorization": "Bearer " + refresh_token}

    r = requests.post(apiaddress,headers=headers)

    return(r)

def get_locations(lat,lon,radius,access_token):

    apiaddress = "https://api-bird.prod.birdapp.com/bird/nearby?latitude="+lat+"&longitude="+lon+"&radius="+radius

    headers =   {
            "Authorization": "Bearer " + access_token,
            "User-Agent":"Bird/4.119.0(co.bird.Ride; build:3; iOS 14.3.0) Alamofire/5.2.2",
            "legacyrequest":"false",
            "Device-Id":"0c571d30-2c0c-4cf7-8487-7dda9bc52af6",
            "App-Version":"4.119.0",
            "location":'{"latitude":'+lat+',"longitude":'+lon+',"altitude":500,"accuracy":65,"speed":-1,"heading":-1}'}

    r = requests.get(apiaddress,headers=headers)

    return(r)


if __name__ == "__main__":

    mail =""
    vali_token =""
    argv = sys.argv[1:]
    
    try:
        options, args = getopt.getopt(argv, "m:t:",
                                   ["mail",
                                    "validation-token"])
    except:
        print("unkown Arguments. Try -mail or -validation-token")
     
    for name, value in options:
        if name in ['-m', '--mail']:
            mail = value
        elif name in ['-t', '--validation-token']:
            vali_token = value
    
    if mail != "":
        response = get_validate_token(mail)
        if response.status_code == 200:
            vali_token = input("Enter validation-token")
        else:
            print(response.text)
    
    if vali_token !="":
    
        response = use_magiclink(vali_token)
        
        if response.status_code == 200:
            print(response.text)
            with open("tokens.json","w") as output:
                json.dump(response.json(),output)
        else:
            print(response.text)

    with open("tokens.json","r") as jsoninput:
            tokens = jsoninput.read()

    access_token = json.loads(tokens)["access"]
    refresh_token = json.loads(tokens)["refresh"]
   
    current_locations = get_locations(lat="51.7567447",lon="14.3357307",radius = "5000", access_token = access_token)
    if current_locations.status_code == 200:
        with open("database/output_"+str(round(time.time()))+".json","w") as output:
            json.dump(current_locations.json(), output)
    else:
        response = update_accesstoken(refresh_token)
        if response.status_code == 200:
                    print(response.text)
                    with open("tokens.json","w") as output:
                        json.dump(response.json(),output)
