# brid_flow_cb

Logging and analyzing the flow of bird scooters in cottbus


## Usage

run
```
python3 bird_api.py -m yourmail@address.com
```

this will create access and refresh tokens. After that you can use:

```
pyhton3 bird_api.py
```
for requesting and saving Cottbus based bird scooter locations and metadata to `output_timestamp.json`

## Explaination:

all explained here in detail https://github.com/ubahnverleih/WoBike/blob/master/Bird.md

## Quick and dirty:

### get one time validation token 

- bird_api.get_validate_token(youremail)

- the mail should be already registered with bird (at least it did not work to use some disposable mailaddress directly. I was not allowed to create a new account via api)

### use the validationtoken from your inbox to get an access_token and a refresh_token

- bird_api.use_magiclink(validationtoken)
- the access_token is only valid for 1 day and can be refreshed with the refresh_token

### use the access_token to request the locations

- bird_api.get_locations(lat,lon,radius,access_token)

### refresh tokens when accesstoken is expired

- update_accesstoken(refresh_token)
