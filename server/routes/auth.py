import bcrypt
from fastapi import Depends, FastAPI, HTTPException, Header
from middleware.auth_middleware import auth_middleware
from models.user import User
import uuid
from pydantic_schemas.user_create import UserCreate
from sqlalchemy.orm import Session
from fastapi import APIRouter
from database import get_db
from pydantic_schemas.user_login import UserLogin
import jwt
from sqlalchemy.orm import joinedload

router = APIRouter()


@router.post('/signup',  status_code=201)
def signup_user(user: UserCreate, db: Session = Depends(get_db)):
    user_db = db.query(User).filter(User.email == user.email).first()

    if user_db:
        raise HTTPException(400, "User with the same email already exists!") 
    
    hashed_password = bcrypt.hashpw(user.password.encode(), bcrypt.gensalt())

    user_db = User(id=str(uuid.uuid4()), name=user.name, email=user.email, password=hashed_password)

    db.add(user_db) 
    db.commit()
    db.refresh(user_db)
    return user_db

@router.post('/login')
def login_user(user : UserLogin ,db: Session = Depends(get_db)):
    # check if the user exist (if there is email already exist in db)
    user_db = db.query(User).filter(User.email == user.email).first()

    # if not exist thorw error msg that user not exist signUP!
    if not user_db:
        raise HTTPException(400, "User with this email does not exist!")
    
    # if the user exist then check the password if correct or not
    isMatched = bcrypt.checkpw(user.password.encode(), user_db.password)

    # else just give error that password is wrong
    if not isMatched:
        raise HTTPException(400, "Password is incorrect!")
    
    # we just need to encode
    # jwt take two arg one is the payload which will be out id as it will give all info of the user
    # just put password_key in the env
    token = jwt.encode({'id': user_db.id}, 'password_key')
    # if matching then return user data
    return {'token': token, 'user': user_db}

# only whent there is url/auth
@router.get('/')
def current_user_data(db: Session=Depends(get_db), user_dict = Depends(auth_middleware)):
    
    user = db.query(User).filter(User.id == user_dict['uid']).options(joinedload(User.favorites)).first()

    if not user:
        raise HTTPException(404, 'User not found!')

    return user