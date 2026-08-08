# Tube Archivist

Tube Archivist is a self-hosted YouTube video archiving platform that lets you download, index, and browse your collection locally. This role deploys Tube Archivist together with Redis and Elasticsearch on the ServicesHost VM using Docker containers.

This application is quite heavy, it takes approximately 2GB RAM idle. Personally, the fact that its usability is tied to its own interface doesn't make it a interesting choice for me. For example, it uses Youtube ids as folder and file names (`Tube Archivist/UCn1PmZTHSektXZhwDZN3xjw/spPFjETD1hQ.mp4`), if I want to preserve a channel and then share it with somebody else this naming scheme make things really difficult. I saw that there is a [user script](https://github.com/SurvlandMC/YA-ta-helper) that copies the videos and rename them, but, to be honest, I prefer an out-of-the-box solution.

![Really weird](/docs/images/tubearchivist/Screenshot_20260807_200258.png)


## Useful links

- https://github.com/tubearchivist/tubearchivist
- https://docs.tubearchivist.com/
