from pydantic import BaseModel

# pydantic schema
class UserCreate(BaseModel):
    name: str
    email: str
    password: str