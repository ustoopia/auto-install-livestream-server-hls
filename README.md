AUTO-HLS-LIVESTREAM-SERVER-INSTALLER

I've put together this simple bash script that takes care of installing all the building blocks that are used to build a livestream server. It also configures the server so that you'll have a working livestream server right out-of-the-box. Saving you a lot of time of manually having to perform a bunch of tasks. \
I made sure that the script will run flawlessly when used on a clean install of Ubuntu (22.04). So far I've only tested it on Ubuntu 22.04, so I have no idea if it will work on other versions, or other operating systems. I plan to do some testing at one point, with the idea of eventually have this script work on different operating systems. But for now, while work is still in progress, Ubuntu 22.04 is good, and the scripts works great. \

Two things that you will still have to do yourself, is first to make sure the machine you want to run it on is a Ubuntu 22.04.* . Preferably a fresh, brand new install of the operating system. Second thing is an important requirement, you will need to have a valid domain pointing to your server, and the server needs to be reachable from the internet using this domain name. In case you are on a home network, you'll need to open/forward two ports in your router to the server. Ports 80 and 443. This is so valid certificates can be requested and used to secure NginX and the HLS streams.

![Alt text](https://i.imgur.com/ERG9hoj.png "header image")

Requirements
============
- A fresh install Ubuntu 22.04.*
- A domain name pointing to your server.
- Reachable from the internet (ports 80 & 443)

How to run the script
=====================
sudo bash auto-installer.sh

You will be prompted to input your e-mail address and your domain name. The script will take of everything else. When it requests the certificates it will require some interaction from you in order to continue. \
I am not a programmer, and not particulary good with code either. I used a little help of AI to put this script together. In case the script contains any lines that are wrong, less ideal, or dangerous, please let me know so I can learn from it. Any form of improvement of the script is of course always good. Personally I believe I did quite an OK job, for a person who can't even write code. 
