
## About IRIS TTS Application
This is an application to do Text to Speech 

## Installation
1. Clone/git pull the repo into any local directory

```
$ git clone https://github.com/yurimarx/iris-tts.git
```

2. Open a Docker terminal in this directory and run:

```
$ docker-compose build
```

3. Run the IRIS container:

```
$ docker-compose up -d 
```

4. Go to your Postman (or other similar REST client) and config the request like this image:

![Request TTS input](https://github.com/yurimarx/iris-tts/raw/main/postman.png "Request TTS input")

- Method: POST
- URL: http://localhost:52773/iris-tts/texttoaudio 
- Body: raw

5. Click send and get a response with a player to play the mp3 file, like picture above


# Credits
This application used gTTS project
