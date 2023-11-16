# lambda-transcode

This project is a POC for a lambda transcode solution

The idea is to reduce the cost of a transcode and improve the speed of the transcocde too

Idea behind that

![Idea](idea.png)

The architecture for this kind of project:

![Architecture](architecture.png)

Idea to improve this POC
- Dynamic Parameters
- Video transcode
- Verify the audio file in output
- Change parameters (chunk size, ...) to optimize the speed of transcode
- More CPU for lambda transcode
- GPU when AWS will change the lambda GPU possibility