I got hired!
============



an image:

![Source image](https://raw.github.com/tothebeat/wiredtree-hireme/master/wiredtree.png)

becomes a 72 inch wide and 16 inch tall poster:

![Action Shot with a photobombing cat](https://raw.github.com/tothebeat/wiredtree-hireme/master/action_shot_with_cat.jpg)

Background
==========

In recent times, photo development labs like Snapfish and Shutterfly have advertised very 
low prices for 4"x6" photo prints, often as low as 9 American cents per print. We can use 
this to our advantage to create poster-size photographic quality prints for much cheaper 
than getting a traditional print of continuous poster material. At $0.09/print, that's 
$0.54/square foot, or only $43.20 to cover an entire wall 8 feet tall and 10 feet wide with
an image with an effective resolution of 36000 pixels wide and 28800 pixels high!

This script processes one chunk of the source file into a print at a time. This avoids the
memory intensive approach of first resizing the image to hundreds of megapixels and then
cropping it. By cropping and then resizing, we may sacrifice a little bit of accuracy but 
be far more memory efficient in the process. 


Syntax
------
<pre>
  usage: image_mosaic.py [-h] -i FILE_PATH -mw INCHES -mh INCHES

  Decompose an image into chunks intended to be printed on 4"x6" photo prints
  and reassembled into a poster-sized mosaic display.

  optional arguments:
    -h, --help    show this help message and exit
    -i FILE_PATH  The path to the source image.
    -mw INCHES    Max width of resulting poster, in inches.
    -mh INCHES    Max height of resulting poster, in inches.
</pre>

Caveats
-------

Of course, assembling a picture from a collection of prints like this will not have the 
same level of quality as a single continuous piece of material. 

Photo labs seem to be highly variable about how accurately they crop prints. Expect to 
see crooked unions at the shared edges of prints.

The script may also not be extremely precise about splitting the image into chunks, but 
I think this gets lost anyway in the bad cropping done by photo labs.

I haven't come up with a system for reassembling the prints besides treating it like a 
fun little puzzle. With 48 prints used in the example, it took me 10 minutes to 
assemble while referring to the original images on my monitor.


### copyrights
Some mumbojumbo should go here saying that the [WiredTree] [1] logo used in the example picture 
retains the copyright of the original owner, that sort of thing and so on. I used it here
because I want them to hire me for a [Junior Python Developer job] [2] they have open. 

  [1]: http://www.wiredtree.com/  "WiredTree"
  [2]: http://chicago.craigslist.org/chc/sof/3717165739.html "Junior Python Developer job"
