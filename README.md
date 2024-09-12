# 🎶 Melodify <br>
Melodify is a feature-rich music application that allows users to upload, listen to, and manage their songs in a smooth and enjoyable environment. Built with a modern tech stack and structured using the MVVM architecture, the app provides a seamless user experience for music lovers.

# 💻 Tech Stack
<p align="center"> <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" /> <img src="https://img.shields.io/badge/PostgreSQL-%23316192.svg?style=for-the-badge&logo=PostgreSQL&logoColor=white" alt="PostgreSQL" /> <img src="https://img.shields.io/badge/Cloudinary-%231A84C4.svg?style=for-the-badge&logo=Cloudinary&logoColor=white" alt="Cloudinary" /> <img src="https://img.shields.io/badge/Hive-%23FFA000.svg?style=for-the-badge&logo=Hive&logoColor=white" alt="Hive" /> </p>
Frontend: Built using Flutter (Dart) <br>
Backend: Flask (Python) <br>
Database: PostgreSQL for cloud storage, Hive for local storage <br>
Media Storage: Cloudinary for song storage <br>

# 🎵 Features <br>
Upload Songs: Easily upload your music tracks to the app with a user-friendly interface.<br>
Listen to Songs: Play your favorite songs directly within the app.<br>
Add to Favorites: Mark songs as favorites for quick access.<br>
Create Playlists: Organize your music into personalized playlists.<br>
View Library: Browse through your music library with ease.<br>
Select Themes for Songs: Add a unique theme while uploading songs to enhance the visual experience.<br>

# 📸 Screenshots<br>
Home Page:<br>
Home Page:
<p align="center"> <img src="https://github.com/user-attachments/assets/47d8b67e-7ba1-4ae6-90b3-562dc4c06fce" width="300" alt="Home Page" /> </p>
<br>
Music Player: <br>
![flutter_02](https://github.com/user-attachments/assets/99e29563-9bc9-4c12-8bf6-8fe939b0411e)
![flutter_03](https://github.com/user-attachments/assets/c7dd41cf-305c-45ef-845c-11035d6534b5)
<br>
Library Page: <br>
![flutter_04](https://github.com/user-attachments/assets/b613d72e-dd15-425a-8f82-78689f150191)


<br>
# 🛠️ Configuration
PostgreSQL Setup <br>
Make sure you have PostgreSQL installed locally and running. <br>

Create a database called musicApp.  <br>

In the database.py file, update the connection string with your PostgreSQL credentials: <br>

- DATABASE_URI = 'postgresql://<username>:<password>@localhost:5432/musicApp'
- Replace <username> and <password> with your PostgreSQL credentials.

Cloudinary Setup <br>
Create an account on Cloudinary. <br>

Get your Cloud Name, API Key, and API Secret from the Cloudinary Dashboard. <br>

You can configure your Cloudinary credentials in the song.py file like this: <br>

import cloudinary <br>
cloudinary.config( <br>
  cloud_name = "<your-cloud-name>", <br>
  api_key = "<your-api-key>", <br>
  api_secret = "<your-api-secret>"<br>
)<br>
Alternatively, you can store these values in a .env file: <br>

Create a .env file in the root of your project: <br>
CLOUD_NAME=<your-cloud-name> <br>
API_KEY=<your-api-key><br>
API_SECRET=<your-api-secret><br>

Update your song.py to load these values using the dotenv package:<br>
from dotenv import load_dotenv <br>
import os <br>
load_dotenv() <br>

cloudinary.config( <br>
  cloud_name = os.getenv("CLOUD_NAME"), <br>
  api_key = os.getenv("API_KEY"), 
  api_secret = os.getenv("API_SECRET")<br>
)<br>

# 🌟 Getting Started
Clone the repository: <br>

git clone https://github.com/yourusername/melodify.git <br>
cd melodify<br>

Install dependencies:<br>
flutter pub get<br>

Run the app: <br>
flutter run


