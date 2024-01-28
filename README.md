Hi all,

I've put together this simple bash script that can be run on a clean Ubuntu 22.04 server, and when its finished, it will have transformed the server into a stable, robust live-stream server that works out-of-the-box with HLS, DASHm RTMP.

![Alt text](https://i.imgur.com/ERG9hoj.png "header image")
{apparently I'm better at sharing really useful script than I am at graphic banner design)

Requirements

- A fresh install Ubuntu 22.04.*
- A domain name pointing to your server.
- Reachable from the internet (ports 80 & 443)

When starting the script, it asks you to enter a domain name and your email address. From that point onwards, no further interaction will be required from you. This script will save you at least two hours of doing tedious tasks you copy/paste from a random tutorial. You should run this script before doing anything else on a clean server. Just to avoid potential conflicts with other apps. I just now decided to simply say that a clean server is one of the two requirements for this script te be successfull. The second requirement is really important, and it is completely dependant on you to meet this requirement. YOU need to have a valid domain name pointing to your server, and the world needs to be able to reach your server from the internet in order to obtain certificates. In case you're behind a NAT router, at your home for example, you need to open/forward two ports in your firewall/router to your server. Ports 80 and 443. If the two requirements are both met, you're all good to go. Start the script, and use the extra time you now freed for yourself to go get a cup of coffee or take a walk outside. 

How to run the script

  cd ~ \
  git clone https://github.com/ustoopia/auto-install-livestream-server-hls \
  cd auto-installer \
  sudo bash auto-installer.sh

But this also works

Download the zip file from the Github repository page. Unzip the file, and 
open the folder it contains. Then simply enter: sudo bash auto-installer.sh

In case the script runs in to a fatal error, you might want to run it again and create a log file. You can accomplish this by running the script like this: sudo bash your_script.sh 2>&1 | tee setup_log.txt

On my personal website I posted an article that explains in detail how to get started with the live-stream server. Make sure you check it out before you decide to run this script. https://www.ustoopia.nl

So far I haven't tried it on any other versions of Ubuntu except 22.04. Neither have I tried it on other operating systems. But I will do that in the future. The script is not smart enough to handle different environments, much like the person who created the script, so you're not going to be able to run this on Windows, Mac, or other Linux flavors. This mey change in at some point. Depending on when I get around to it.  

I'm not a coder. And I used a bit of help from an AI to put this script together. In case the script contains any lines that are fundamentally wrong, or far from good, or perhaps dangerous in some way, please let me know, so I can learn. Any form of improvement of the script is of course always welcome. Personally I believe I did quite an OK job! But feel free to point out all the errors that I made and what I should do different. That way I'll learn.
