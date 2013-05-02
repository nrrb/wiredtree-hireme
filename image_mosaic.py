#!/usr/bin/python
# -*- coding: utf-8 -*-

# @Author: Nick Bennett
# @Email:  nick271828@gmail.com
#
#     __  ___
#    / / / (_)_______     ____ ___  ___
#   / /_/ / / ___/ _ \   / __ `__ \/ _ \
#  / __  / / /  /  __/  / / / / / /  __/
# /_/ /_/_/_/   \___/  /_/ /_/ /_/\___( )
#                                     |/
#  _       ___               ________               __
# | |     / (_)_______  ____/ /_  __/_______  ___  / /
# | | /| / / / ___/ _ \/ __  / / / / ___/ _ \/ _ \/ /
# | |/ |/ / / /  /  __/ /_/ / / / / /  /  __/  __/_/
# |__/|__/_/_/   \___/\__,_/ /_/ /_/   \___/\___(_)

from PIL import Image
import os.path
import argparse

_DESCRIPTION = ('Decompose an image into chunks intended '
                'to be printed on 4"x6" photo prints and '
                'reassembled into a poster-sized mosaic '
                'display.')

# Size of the individual photo prints composing the output mosaic
_PRINT_WIDTH = 6
_PRINT_HEIGHT = 4
# How much is this going to cost?
_PRINT_COST = 0.09
# Assumed DPI of the print, this is somewhat arbitrary
_PRINT_DPI = 300


def parse_arguments():
    parser = argparse.ArgumentParser(description=_DESCRIPTION)
    parser.add_argument('-i',
                        metavar='FILE_PATH',
                        dest='image_path',
                        required=True,
                        help='The path to the source image.')
    parser.add_argument('-mw',
                        metavar='INCHES',
                        dest='max_width',
                        required=True,
                        type=int,
                        help='Max width of resulting poster, in inches.')
    parser.add_argument('-mh',
                        metavar='INCHES',
                        dest='max_height',
                        required=True,
                        type=int,
                        help='Max height of resulting poster, in inches.')
    parser.add_argument('-o',
                        metavar='OUTPUT_PATH',
                        dest='output_path',
                        required=False,
                        help=('Desired path for output files. This must '
                              'exist! Defaults to current directory.'))
    return parser.parse_args()


if __name__ == '__main__':
    import sys

    args = parse_arguments()
    try:
        img = Image.open(args.image_path)
    except IOError, e:
        print 'Oh dear, we seem to have run into a snag opening your file...'
        print e
        sys.exit(1)
    basef, extf = os.path.splitext(args.image_path)
    output_path = args.output_path or '.'

    aspect_ratio = float(img.size[0]) / float(img.size[1])

    # Resize the poster to maintain the aspect ratio of the image
    if float(args.max_width) / float(args.max_height) > aspect_ratio:
        # The desired poster is too wide, keep the height and
        # scale down the width
        poster_height = args.max_height
        poster_width = int(float(poster_height) * aspect_ratio)
    else:
        # The desired poster is either too tall or just right,
        # in either case it's safe to keep the width and
        # scale down the height
        poster_width = args.max_width
        poster_height = int(float(poster_width) / aspect_ratio)
    # Figure out how many prints we need to make this poster
    prints_wide = poster_width / _PRINT_WIDTH
    prints_high = poster_height / _PRINT_HEIGHT
    if poster_width % _PRINT_WIDTH != 0:
        prints_wide = prints_wide + 1
    if poster_height % _PRINT_HEIGHT != 0:
        prints_high = prints_high + 1

    # Now start breaking the image into chunks and blowing them up
    chunk_width = float(img.size[0])/float(prints_wide)
    chunk_height = float(img.size[1])/float(prints_high)
    for print_y in range(prints_high):
        chunk_y1 = int(float(print_y) * chunk_height)
        chunk_y2 = int(float(print_y + 1) * chunk_height)
        for print_x in range(prints_wide):
            chunk_x1 = int(float(print_x) * chunk_width)
            chunk_x2 = int(float(print_x + 1) * chunk_width)
            chunk = img.crop((chunk_x1, chunk_y1, chunk_x2, chunk_y2))
            chunk = chunk.resize((_PRINT_WIDTH * _PRINT_DPI,
                                  _PRINT_HEIGHT * _PRINT_DPI))
            output_filename = '%s-%dx%d-print%dx%d%s' % (basef,
                                                         prints_high,
                                                         prints_wide,
                                                         print_y,
                                                         print_x,
                                                         extf)
            output_filename = os.path.join(output_path, output_filename)
            chunk.save(output_filename)
            print output_filename
