from fastapi import HTTPException, Header
import jwt


def auth_middleware(x_auth_token = Header()):
    #  we have to make statergy to handle if the token is tampered with and will help to not crashing the server
    try: # this should be used for every func so we will make it common for everyone i.e is we will make "middleware"
        # get the user token from the header 
        if not x_auth_token:
            raise HTTPException(401, 'No auth token, access denied!')
        
        # decode the token
        verified_token = jwt.decode(x_auth_token, 'password_key', ['HS256'])
        
    
        if not verified_token:
            raise HTTPException(401, 'Token verification failed, authorization denied')
        
        # get the user id from the token
        uid = verified_token.get('id')
        return {'uid': uid, 'token': x_auth_token}
    except jwt.PyJWTError:
        raise HTTPException(401, 'Invalid token, access denied')

    # get the user data from the db using the user id