from PIL import Image
import numpy
import math

pallet = [
    (0, 0, 0),
    (29, 43, 83),
    (126, 37, 83),
    (0, 135, 81),
    (171, 82, 54),
    (95, 87, 79),
    (194, 195, 199),
    (255, 241, 232),
    (255, 0, 77),
    (255, 163, 0),
    (255, 236, 39),
    (0, 228, 54),
    (41, 173, 255),
    (131, 118, 156),
    (255, 119, 168),
    (255, 204, 170)
]

hex_pallet = [
    0xFF000000,
    0xFF532B1D,
    0xFF53257E,
    0xFF518700,
    0xFF3652AB,
    0xFF4F575F,
    0xFFC7C3C2,
    0xFFE8F1FF,
    0xFF4D00FF,
    0xFF00A3FF,
    0xFF27ECFF,
    0xFF36E400,
    0xFFFFAD29,
    0xFF9C7683,
    0xFFA877FF,
    0xFFAACCFF
]


def load_and_compress_images(sheets, outfilename):
    w = 128
    h = 128
    img = numpy.empty((w, h), numpy.uint32)
    img.shape = h, w
    img.fill(hex_pallet[0])

    for sheet in sheets:
        infilename = sheet["file"]
        tw = sheet["tw"]
        th = sheet["th"]
        bw = sheet["bw"]
        layers = sheet["layers"]
        offset_x = sheet["x"]
        offset_y = sheet["y"]

        src_img = Image.open(infilename)
        src_img.load()
        src_npdata = numpy.asarray(src_img, dtype="int32")
        sh, sw = src_npdata.shape[0], src_npdata.shape[1]
        rows = int((sh - bw) / (th + bw))
        cols = int((sw - bw) / (tw + bw))

        l_cols = int(math.ceil(cols / layers))

        rw = math.floor(w / tw)  # tiles per row

        for r in range(rows):
            for c in range(l_cols):

                ti = r * l_cols + c  # tile index
                tc = ti % rw  # tile column
                tr = math.floor(ti / rw)  # tile index

                for y in range(th):
                    for x in range(tw):
                        pixel_pallet = 0

                        for l in range(layers):

                            sx = bw + x + l * (tw + bw) + c * (tw + bw) * layers  # source pixel x position
                            sy = bw + y + r * (th + bw)  # source pixel y position
                            src_color = src_npdata[sy, sx]

                            if layers == 4:
                                if src_color[0] == 0 and src_color[1] == 0 and src_color[2] == 0:
                                    pixel_pallet += int(math.pow(2, l))
                            elif layers == 2:
                                ld = 4
                                if src_color[0] == 0 and src_color[1] == 0 and src_color[2] == 0:
                                    pixel_pallet += int(math.pow(4, l))
                                elif src_color[0] == 127 and src_color[1] == 127 and src_color[2] == 127:
                                    pixel_pallet += int(math.pow(7, l)) + 1
                                elif src_color[0] == 255 and src_color[1] == 255 and src_color[2] == 255:
                                    pixel_pallet += int(math.pow(10, l)) + 2

                        color = hex_pallet[pixel_pallet]
                        tx = x + tc * tw
                        ty = y + tr * th
                        px = tx + offset_x
                        py = ty + offset_y
                        img[py, px] = color

    img = Image.frombuffer('RGBA', (w, h), img, 'raw', 'RGBA', 0, 1)
    img.save(outfilename)


def convert255x3to0xFFFFFFFF(sequence):
    value = 255 + sequence[2] * 256 + sequence[1] * 256 * 256 + sequence[0] * 256 * 256 * 256
    raw = hex(value)
    return raw


sheets = [
    {
        "file": "C:\\Users\\johna\\Desktop\\5x5.png",
        "tw": 5,
        "th": 5,
        "bw": 1,
        "x": 0,
        "y": 0,
        "layers": 4
    }, {
        "file": "C:\\Users\\johna\\Desktop\\3x5.png",
        "tw": 3,
        "th": 5,
        "bw": 1,
        "x": 0,
        "y": 5,
        "layers": 4
    }, {
        "file": "C:\\Users\\johna\\Desktop\\Prince - Classic RPG\\Sheets\\EnemySheet2.png",
        "tw": 16,
        "th": 12,
        "bw": 1,
        "x": 0,
        "y": 10,
        "layers": 2
    }
]

combined_path = "C:\\Users\\johna\\AppData\\Roaming\\pico-8\\carts\\combined.png"
load_and_compress_images(sheets, combined_path)

n = "normal"
g = "god"
l = "light"
d = "dark"
f = "fire"
e = "elec"
a = "air"
i = "ice"
w = "water"
b = "blood"
r = "rock"
p = "plant"
v = "variable"

elements = ""+\
    "nnnnnnnnnnnn"+\
    "vvvvvvvvvvvv"+\
    "vvvvvvfffeee"+\
    "aaapppwwwiii"+\
    "rrrbbblllddd"+\
    "gggnnnnnffee"+\
    "aappwwiirrbb"+\
    "llddggfeapwi"+\
    "rbldgg"
