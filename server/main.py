from fastapi import FastAPI
from routes import auth, song
from models.base import Base
from database import engine
app = FastAPI()

# now we have to do /auth/signup or /auth/signin
app.include_router(router=auth.router, prefix='/auth')
# for uploading and playing song
app.include_router(song.router, prefix='/song')

Base.metadata.create_all(engine)
