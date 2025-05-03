![Alt text](https://i.imgur.com/ERG9hoj.png "header image")
(obviously, creating graphic banners like this is not my biggest talent)

Hi all,

I've put together a bash script that can run on a clean Ubuntu 22.04 server, and when its finished, it will have transformed the server into a stable, robust live-stream server that works out-of-the-box with HLS, DASH, RTMP.
Requirements

- A fresh install Ubuntu 22.04 / 24.04
- A domain name pointing to your server.
- Reachable from the internet (ports 80 & 443)

When you run the script, it asks you for a domain name and your email address. From that point onwards, no further interaction will be required from you. This script will save you at least two hours of doing tedious tasks you copy/paste from a random tutorial. You should run this script before doing anything else on a clean server. Just to avoid potential conflicts with other apps. I just now decided to simply say that a clean server is one of the two requirements for this script te be successfull. The second requirement is really important, and it is completely dependant on YOU to meet this requirement. YOU need to have a valid domain name pointing to your server, and the world needs to be able to reach your server from the internet in order to obtain certificates. In case you're behind a NAT router, at your home for example, you need to open/forward two ports in your firewall/router to your server. Ports 80 and 443. If the two requirements are both met, you're all good to go. Start the script, and use the extra time you now freed for yourself to go get a cup of coffee or take a walk outside. I uploaded a video where I show the script and how it works.

https://www.youtube.com/watch?v=n_GUCEwNpq8

[![Link to YouTube](https://img.youtube.com/vi/n_GUCEwNpq8/0.jpg)](https://www.youtube.com/watch?v=n_GUCEwNpq8)

How to run the script

  git clone https://github.com/ustoopia/auto-install-livestream-server-hls \
  cd auto-install-livestream-server-hls \
  sudo bash auto-installer.sh

But this also works:

Download the zip file from the Github repository page. Unzip the file, and 
open the folder it contains. Then simply enter: sudo bash auto-installer.sh

In case the script runs in to a fatal error, you might want to run it again in debug mode. You can accomplish this by running the script like this: sudo bash your_script.sh 2>&1 | tee setup_log.txt

On my personal website I posted an article that explains in detail how to get started with the live-stream server that the script built for you. Make sure you check it out before you decide to run this script. [https://www.ustoopia.nl](https://www.ustoopia.nl/technical/use-this-script-to-automate-the-setup-of-a-live-stream-server-on-ubuntu-22-04/)

So far I haven't tried it on anything else but just Ubuntu 22.04. In its current form it is not going to be able to correcly run on any other OS.

I'm not a coder. And I used a bit of help from an AI to put this script together. In case the script contains any lines that are fundamentally wrong, or far from good, or perhaps dangerous in some way, please let me know, so I can learn. Any form of improvement of the script is of course always welcome. Personally I believe I did quite an OK job! But feel free to point out all the errors that I made and what I should do different. That way I'll learn.
