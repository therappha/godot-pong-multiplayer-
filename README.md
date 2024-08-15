This is my first game ever made, most of it is just hardcoded, but as someone who published the same game a lot of times says "it just works"
There is no comments on the code because i don't know how to properly do it yet;

Default port is 5008, game will try to port map with upnp a new port which you can choose in the start menu, but if you do not have upnp set on in your router it will only work locally, or you can enter as client and let some friend host;

Host starts as player 2;

To enter the game you can locally open 2 instances and just click host and join, it will work, but if you re trying to play it with a friend, you need to give him your public ip adress which you can find in https://www.whatismyip.com/;

I did use chatgpt to get some understanding of how to do the ball bounce on the ground, I had the idea of how to make it in my head, but not how to code it properly (I wasn't understading the lerp() function;

Ball size varies size on purpose, but it hit the ground at different sizes, i don't see this as a problem because it add some randomness in ball movement;
