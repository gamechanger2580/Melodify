import uuid
from fastapi import APIRouter, Depends, File, Form, UploadFile
from database import get_db
from sqlalchemy.orm import Session
from middleware.auth_middleware import auth_middleware
import cloudinary
import cloudinary.uploader
from cloudinary.utils import cloudinary_url
from dotenv import load_dotenv
import os

from models.favorite import Favorite
from models.song import Song
from pydantic_schemas.favorite_song import FavoriteSong
from sqlalchemy.orm import joinedload

# Load environment variables from .env file
load_dotenv()
api_key = os.getenv("API_KEY")
api_secret = os.getenv("API_SECRET")
cloud_name = os.getenv("CLOUD_NAME")

router = APIRouter()

# Configuration       
# we used cloudinary storage for uploading song and thubnail(image files) as postgres may not store big files 
# so we will give the link of this to postgreSQL

cloudinary.config( 
    cloud_name = cloud_name, 
    api_key = api_key, 
    api_secret = api_secret, # Click 'View API Keys' above to copy your API secret
    secure=True
)

# we will take color in hex code as it is easier and is in numbers 
@router.post('/upload', status_code = 201)
def upload_song(song: UploadFile = File(...), 
                thumbnail: UploadFile = File(...), 
                artist: str = Form(...), 
                song_name: str = Form(...),
                hex_code: str = Form(...),
                db: Session = Depends(get_db),
                auth_dict = Depends(auth_middleware)):
    # adding external storage service(other than sql) for song and thumbnail and giving link to postgres
    # we will be using cloudinary
    song_id = str(uuid.uuid4())

    song_res = cloudinary.uploader.upload(song.file, resource_type='auto', folder= f'songs/{song_id}')
    # print(song_res['url'])

    thumbnail_res = cloudinary.uploader.upload(thumbnail.file, resource_type='image', folder= f'songs/{song_id}')
    # print(thumbnail_res['url'])

    new_song = Song(
        id = song_id,
        song_name = song_name,
        artist = artist,
        hex_code = hex_code,
        song_url = song_res['url'],
        thumbnail_url = thumbnail_res['url'],
        )

    db.add(new_song)
    db.commit()
    db.refresh(new_song)
    return new_song

@router.get('/list')
def list_songs(db: Session=Depends(get_db), auth_details = Depends(auth_middleware)):
    song = db.query(Song).all()
    return song

@router.post('/favorite')
def favorite_song(song: FavoriteSong, 
                  db: Session=Depends(get_db), 
                  auth_details=Depends(auth_middleware)):
    # song is already favorited by the user
    user_id = auth_details['uid']

    fav_song = db.query(Favorite).filter(Favorite.song_id == song.song_id, Favorite.user_id == user_id).first()

    if fav_song:
        db.delete(fav_song)
        db.commit()
        return {'message': False}
    else:
        new_fav = Favorite(id=str(uuid.uuid4()), song_id=song.song_id, user_id=user_id)
        db.add(new_fav)
        db.commit()
        return {'message': True}

@router.get('/list/favorites')
def list_fav_songs(db: Session=Depends(get_db), auth_details = Depends(auth_middleware)):
    user_id = auth_details['uid']
    fav_song = db.query(Favorite).filter(Favorite.user_id == user_id).options(joinedload(Favorite.song)).all()
    return fav_song