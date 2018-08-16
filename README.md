# Cleverreach

Ruby wrapper for Cleverreach REST-API.


## install


## use

`credentials = Cleverreach::Credentials.new(client_id, username, password)`

`doidata = Cleverreach::Doidata.new(form_id, request.remote_ip, request.original_url, request.user_agent)`

`cleverreach = Cleverreach::API.new(credentials, doidata)`