import requests

def get_validate_token(email):

    apiaddress = "https://api-auth.prod.birdapp.com/api/v1/auth/email"
    headers =   {"User-Agent":"Bird/4.119.0(co.bird.Ride; build:3; iOS 14.3.0) Alamofire/5.2.2",
                "Device-Id":"0c571d30-2c0c-4cf7-8487-7dda9bc52af6",
                "Platform":"ios",
                "App-Version":"4.119.0",
                "Content-Type":"application/json"}
    
    body = {"email":email}

    r = requests.post(apiaddress,json=body,headers=headers)
    print(r.text)
    try:
        if(r.json()["validation_required"]):
            print("Check your mail. This only works if you already have an account")
            return(True)
    
    except Exception as e:
        print("Something went wrong")
        return(False)

def use_magiclink(token):

    apiaddress = "https://api-auth.prod.birdapp.com/api/v1/auth/magic-link/use"

    headers =   {"User-Agent":"Bird/4.119.0(co.bird.Ride; build:3; iOS 14.3.0) Alamofire/5.2.2",
                "Device-Id":"0c571d30-2c0c-4cf7-8487-7dda9bc52af6",
                "Platform":"ios",
                 "App-Version":"4.119.0",
                "Content-Type":"application/json"}

    body = {"token":token}

    r = requests.post(apiaddress,json=body,headers=headers)


    print(r.text)

    return
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

    print(r.text)
    return(r)
